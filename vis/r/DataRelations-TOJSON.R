###############################################################################
# -----------------------------------------------------------------------------
# FILE : /SDTMasRDF/vis/r/DataRelations-FNGraph.R
# DESCR: Create JSON file consumed by DataRelations-FNGraph.html for display of 
#        relations between the triples in study.ttl, code.ttl, etc.
# SRC  : 
# REF  : 
# NOTES: visNetwork docs and examples: http://dataknowledge.github.io/visNetwork/
#        For D3js, node ID must start at 0 and progress from there.
#        Previous use from Neo4j used the original NEO4j IDs to merge the generated ID 
#        in the NODES dataset into the EDGES dataframe, then use the generated ID's  
#        for the from and to in the JSON.
# INPUT: /SDTMasRDF/data/rdf/study.ttl
#                           /code.ttl
#                        ....etc.
# OUT  : /SDTMasRDF/vis/d3/data/DataRelations-FNGraph.JSON  
# REQ  :
#        
# TODO : 
#
#
###############################################################################
library(rrdf)
library(reshape)  #  melt
library(visNetwork)
library(plyr)
library(jsonlite)
library(visNetwork)

#-- Local TTL file
setwd("C:/_gitHub/SDTMasRDF")

rdfSource = load.rdf("data/rdf/study.TTL", format="N3")

# Select all the information associated with Obs113
query = 'PREFIX EG:    <http://www.example.org/cdiscpilot01#>
PREFIX RDFS: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX BRIDG_4.1.1.owl: <file:/Users/Frederik/Downloads/BRIDG_4.1.1.owl.xml>
PREFIX arg: <http://spinrdf.org/arg#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX schema: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/ct/schema#>
PREFIX sdtm-terminology: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/sdtm-terminology#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX smf: <http://topbraid.org/sparqlmotionfunctions#>
PREFIX sp: <http://spinrdf.org/sp#>
PREFIX spin: <http://spinrdf.org/spin#>
PREFIX spl: <http://spinrdf.org/spl#>
PREFIX study: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/study#>
PREFIX time: <http://www.w3.org/2006/time#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

SELECT *
WHERE{
?s ?p ?o .
} LIMIT 100'

triples = as.data.frame(sparql.rdf(rdfSource, query))


# NEW 
# Get the unique list of nodes as needed by the JSON file:
# Combine Subject and Object into a single column
# "id.vars" is the list of columns to keep untouched. The unamed ones are 
# melted into the "value" column.
nodeList <- melt(dmObs, id.vars=c("p", "srcType", "srcGroup" ))   # subject, object into 1 column.

# A node can be both a Subject and a Predicate so ensure a unique list of node names
#  by dropping duplicate values.
nodeList <- nodeList[!duplicated(nodeList$value),]

# Rename the columns 
# TODO: DROP ones not needed!
colnames(nodeList)<-c("p", "srcType", "group", "var", "name")  # column name should be name, not value.

# Rename column value to name for use in nodes list for JSON
nodeList <-arrange(nodeList,name)  # sort

# Delete the artifact nodes where var=edgeType
nodeList <-nodeList[!(nodeList$var=="edgeType"),]

# Create the node ID values starting at 0 (as req. by D3JS)
id<-0:(nrow(nodeList)-1)   # Generate a list of ID numbers
nodeList<-data.frame(id, nodeList)  
nodeList

# Attach the ID values to Subject Nodes
edgesList <- merge (dmObs, nodeList, by.x="s", by.y="name")


edgesList<-rename(edgesList, c("id"="source"))

# Attach ID values to Object Nodes
edgesList <- merge (edgesList, nodeList, by.x="o", by.y="name")
# p is renamed to "value" for use in LINKS dataframe. "value" is needed above here.


edgesList<-rename(edgesList, c("id"="target", "p"="value"))
head(edgesList)

# Reorder for pretty-pretty
edgesList<-edgesList[c("s", "source", "value", "o", "target", "edgeType")]

# In code above, create "nodes" instead of nodesList
# 1. Make the NODES dataframe 

#nodeList$type<- ifelse(grepl(nodeList$name, tf:hss), 'Person', '')

#!!!!!!!!!!!!!!!!!!! 
#TODO  SET THE TYPES HERE for NODE TYPE!!! 


nodeList$type[grepl('pers:pers', nodeList$name)] <- 'person'      
nodeList$type[grepl('sdtmc:C', nodeList$name)]<- 'cdisc'  
nodeList$type[grepl('code:', nodeList$name)]  <- 'code'  

# Later change the following to RegX of code:<UppercaseLetter> to detect
#   all the codelist classes.
nodeList$freq <-60  # a default value for node size

# nodeList$freq[grepl('code:Sex', nodeList$name)]  <- nodeList$freq*2;
# THis appears to work!!
nodeList$freq[grepl('code:[A-Z]', nodeList$name)]  <- nodeList$freq*2;


nodes<-data.frame(id=nodeList$id,
                  nodeID=nodeList$id,
                  name=nodeList$name,
                  type=nodeList$type,
                  label=nodeList$name,
                  freq=nodeList$freq,
                  group=nodeList$group)
# Later can be set based on number of obs, etc.
#nodes$nodesize=4  #

# 2. make the EDGES dataframe that contains: source, target, value columns
#   source, target,
#  named edges instead of links to match D3jS in .html file
edges<- as.data.frame(edgesList[c("source", "target", "value", "edgeType")])



# Predicates
# edges$type<-"FROM" #  DEFAULT 
# edges$type[grepl('person', edges$edgeType)]  <- 'persEdge'  
edges$type<-edges$edgeType

# Combine the nodes and edges into a single dataframe for conversion to JSON
all <- list(nodes=nodes,
            edges=edges)
# Write out to JSON
fileConn<-file("./data/dm-ToJSON.JSON")
writeLines(toJSON(all, pretty=TRUE), fileConn)
close(fileConn)