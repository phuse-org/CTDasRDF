#______________________________________________________________________________
# FILE : /CTDasRDF/vis/r/Person-FNGRAPH.R
# DESC: Create JSON file of the CDISCPILOT01.TTL for consumption by CDISCPILOT01-FNGraph.html
#         fpr vis. representation of the data.  
# REQ  : TTL data file 
# NOTES: visNetwork docs and examples: http://dataknowledge.github.io/visNetwork/
#        For D3js, node ID must start at 0 and progress from there.
#        Node and Edge Types are coded as Upppercase for consistent implmentation 
#          in the CSS
# VIS  : http://localhost:8000/SDTMasRDF/vis/d3/DataRelations-FNGraph.html
# INPUT: /SDTMasRDF/data/rdf/study.ttl
#                           /code.ttl
#                        ....etc., uploaded to Virtuoso & served on localhost
# OUT  : /SDTMasRDF/vis/d3/data/DataRelations-FNGraph.JSON  
#        
# TODO : !! ERROR:  Predicates not merged to nodes properly.
#
#______________________________________________________________________________
library(rrdf)     # Read / Create RDF
library(reshape)  # melt
library(plyr)     # various goodies
library(jsonlite) # Nice, clean JSON creation

setwd("C:/_github/CTDasRDF")

#-- Local endpoint
endpoint = "http://localhost:8890/sparql"

allPrefix <- "data/config/prefixes.csv"  # List of prefixes

# Prefixes from config file ----
prefixes <- as.data.frame( read.csv(allPrefix,
  header=T,
  sep=',' ,
  strip.white=TRUE))
# Create individual PREFIX statements
prefixes$prefixDef <- paste0("PREFIX ", prefixes$prefix, ": <", prefixes$namespace,">")
 


## Set a limit for the queries during development or "" for all triples
limit = ""
# limit = "limit 1000"

# Currently only looking at code, study, time, protocol namespaces
query =' 
PREFIX x: <http://foo.foo.org/x>
SELECT ?s ?p ?o 
WHERE {
    cdiscpilot01:Person_1 (x:foo|!x:bar)* ?s . 
    ?s ?p ?o . 
}'
query<-paste0(paste(prefixes$prefixDef, collapse=""),query, limit)

sourceTTL <- load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")
triples = as.data.frame(sparql.rdf(sourceTTL, query))



    #FOR virtuoso triples = as.data.frame(sparql.remote(endpoint, query))
# Remove cases where O is missing in the Ontology source(atrifact from TopBraid)
triples <-triples[!(triples$o==""),]

# subject node type set manually, post-query
#triples$srcType <- 'NA'  # Default unassigned
#triples$srcType[grepl('code:', triples$s)] <- 'code' 
#triples$srcType[grepl('study:', triples$s)] <- 'study'      
#triples$srcType[grepl('time:', triples$s)] <- 'time' 
#triples$srcType[grepl('Person_', triples$s)] <- 'person' 

# NODES -----------------------------------------------------------------------
# Get the unique list of nodes as needed by the JSON file:
# Combine Subject and Object into a single column
# "id.vars" is the list of columns to keep untouched. The unamed ones are 
# melted into the "value" column.
nodeList <- melt(triples, id.vars=c("p" ))   # subject, object into 1 column.

# A node can be both a Subject and an Object so ensure a unique list of node names
#  by dropping duplicate values.
nodeList <- nodeList[!duplicated(nodeList$value),]

# Rename column value to 'name' for use in nodes list for JSON
colnames(nodeList)<-c("p", "var", "name")  # column name should be name, not value.
nodeList <-arrange(nodeList,name)  # sort prior to adding ID value. (not necessary, of course)

# Create the node ID values starting at 0 (as req. by D3JS)
id<-0:(nrow(nodeList)-1) 
nodeList<-data.frame(id, nodeList)  




# nodeCategory used for grouping in the FN graph. Assign grouping based on type
#   Make this smarter later: sort on unique type and assign index value.
#   Must now be updated manually when a new node type appears. Boo. Bad code.Bad!
nodeList$nodeCategory <- '0'      
nodeList$nodeCategory[grepl('CODE',  nodeList$type)] <- '1'      
nodeList$nodeCategory[grepl('STUDY', nodeList$type)] <- '2'      
nodeList$nodeCategory[grepl('TIME',  nodeList$type)] <- '3'      
head(nodeList)



# TODO : CHANGE TO A recode/switch here
# subject node type set manually, post-query
nodeList$type <- 'NA'  # Default unassigned
nodeList$type[grepl('code:', nodeList$name)] <- 'code' 

# Study.  Not that Time is coded to STUDY because it is used for events within the study timeframe
nodeList$type[grepl('study:|custom:Visit|time:', nodeList$name)] <- 'study'      
nodeList$type[grepl('study:has|study:outcome|time:has|study:groupID|study:actualArm', nodeList$p)] <- 'study'      

nodeList$type[grepl('rdfs:', nodeList$name)] <- 'rdfs' 

nodeList$type[grepl('Person_', nodeList$name)] <- 'person' 
nodeList$type[grepl('sdtmterm:', nodeList$name)] <- 'sdtm' 
# Measurements and outcomes
nodeList$type[grepl('cdiscpilot01:C67153|Blood|Weight|Temperature|Height|Pulse', nodeList$name)] <- 'measure' 

nodeList$type[grepl('Rule', nodeList$name)] <- 'rule' 

# Literals. Not Clustered. Appear before assign of measure as measure grep re-assigns some of these later
nodeList$type[grepl(':label|:prefLabel|:date|study:seq|study:reasonNotDone|sponsordefinedID', nodeList$p)] <- 'literal'
nodeList$type[grepl('true', nodeList$name)] <- 'literal'   # Not clustered


nodeList$type[grepl('code:hasValue', nodeList$p)] <- 'measure' 

# different types of flags 
nodeList$type[grepl('Flag', nodeList$p)] <- 'flag'      # Not clustered
nodeList$type[grepl('Flag|RandomizationBAL', nodeList$name)] <- 'flag'  # Not clustered


# nodeCategory used for grouping in the FN graph. Assign grouping based on type
#   Make this smarter later: sort on unique type and assign index value.
#   Must now be updated manually when a new node type appears. Boo. Bad code.Bad!
# Types that are NOT clustered: literal
nodeList$nodeCategory <- '0'      
nodeList$nodeCategory[grepl('study',   nodeList$type)] <- '1'      
nodeList$nodeCategory[grepl('sdtm',    nodeList$type)] <- '2'      
nodeList$nodeCategory[grepl('measure', nodeList$type)] <- '3'      
nodeList$nodeCategory[grepl('rule',    nodeList$type)] <- '4'      

#head(nodeList)





nodes<-data.frame(id=nodeList$id,
                  type=nodeList$type,
                  label=nodeList$name,
                  nodeCategory=nodeList$nodeCategory)

# Removed the following. Not needed in Vis.
#DEL nodeID=nodeList$id,
#DEL name=nodeList$name,

# EDGES -----------------------------------------------------------------------
# Now assign the node ID numbers to the Subject and Object nodes
#-- Subject Nodes, ID becomes the subject ID node
#   Assign node ID values to the Subject nodes
edgesList <- merge (triples, nodeList, by.x="s", by.y="name")
# id becomes the subject node id
edgesList<-rename(edgesList, c("id" = "subjectID", "p.x" = "predicate"))
edgesList<-edgesList[c("s", "subjectID", "predicate", "o")] #TW NEW

#-- Object Nodes
#   Assign node ID values to the Object nodes
edgesList <- merge (edgesList, nodeList, by.x="o", by.y="name")
# p is renamed to "value" for use in LINKS dataframe. "value" is needed above here.
edgesList<-rename(edgesList, c("id"="objectID", "p"="value"))
edgesList<-edgesList[c("s", "subjectID", "predicate", "o", "objectID")] #TW NEW

# Construct edgeType: remove prefix, convert to upper case for use in CSS 
 edgesList$edgeType<-tolower(sub(":(\\w+)","",edgesList$predicate))
# edgesList$edgeType<-"type"  # Default to see all edges at the start.

# 2. make the EDGES dataframe that contains: subject, predicate, value columns
#   subject, predicate,
#  named edges instead of links to match D3jS in .html file
# A final rename to names needed in the D3js. 
#   TODO: Make the renames earlier and get rid of this statement.
edgesList<-rename(edgesList, c("subjectID"="source", "objectID"="target", "predicate"="value", "edgeType"="edgeType"))
edges<- as.data.frame(edgesList[c("source", "target", "value", "edgeType")])

#-- Combine the nodes and edges into a single dataframe for conversion to JSON
all <- list(nodes=nodes,
            edges=edges)
# Write out to JSON
fileConn<-file("./vis/d3/data/Person-FNGraph.JSON")
writeLines(toJSON(all, pretty=TRUE), fileConn)
close(fileConn)
