###############################################################################
# FILE: Person-MultLevel-VisNetwork-ForceNetwork.R
# DESC: Visualization of the nodes connected to Person_1 as a FN graph
#       Traverse the graph outward from Person_1
# SRC : 
# DOCS:  https://cran.r-project.org/web/packages/visNetwork/visNetwork.pdf 
#
# IN  : cdiscpilot01.TTL  (OR) local endpoint graph
# OUT : 
# REQ :
# SRC :
# NOTE: OUTDATED. NOT WORKING WITH CURRENT GRAPH 2018-10-14
#       Loads prefixes from  prefixes.csv. Must also add the bogus 'x' prefix
#       to allow path traversal.
#       For use in Workshop Demo to show vis of actual RDF "Person" data.
# TODO: Convert into Shiny app that allows selection of Person?  (Not now: limited
#       data in the test dataset)
###############################################################################
library(plyr)     #  rename
library(reshape)  #  melt
library(rrdf)
library(visNetwork)

setwd("C:/_github/CTDasRDF")
allPrefix <- "data/config/prefixes.csv"  # List of prefixes

prefixes <- as.data.frame( read.csv(allPrefix,
  header=T,
  sep=',' ,
  strip.white=TRUE))
# Create individual PREFIX statements
prefixes$prefixDef <- paste0("PREFIX ", prefixes$prefix, ": <", prefixes$namespace,">")

# Note addition of prefix 'x' needed for traversal
query = paste0(paste(prefixes$prefixDef, collapse=""),
  "PREFIX x: <http://example.org/bogus>
  SELECT ?s ?p ?o 
  FROM <http://localhost:8890/CTDasRDF>
  WHERE { cdiscpilot01:Person_1 (x:foo|!x:bar)* ?s . 
    ?s ?p ?o . 
  } LIMIT 20")


# Two options: Can use either a SPARQL endpoint (Triplestore) or TTL file.
#-- A. Endpoint 
#rdfSource = "http://localhost:8890/sparql"  # local EP
#DMTriples = as.data.frame(sparql.remote(rdfSource, query))  # for local EP

#-- B. TTL file
rdfSource = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")

DMTriples = as.data.frame(sparql.rdf(rdfSource, query))

# Remove any rows that have a blank Object. 
DMTriples<-DMTriples[!(DMTriples$o==""),]

# Remove duplicates from the query
DMTriples <- DMTriples[!duplicated(DMTriples),]

#---- Nodes Construction
# Unique list of nodes by combine Subject and Object into a single column
#   "id.vars" is the list of columns to keep untouched. The unamed ones (s,o) are 
#   melt into the "value" column.
nodeList <- melt(DMTriples, id.vars=c("p" ))

# A node can be both Subject and Object. Ensure a unique list of node names
#   by dropping duplicate values.
nodeList <- nodeList[!duplicated(nodeList$value),]

# Rename to ID for use in visNetwork and keep only that column
nodeList <- rename(nodeList, c("value" = "id" ))
nodes<- as.data.frame(nodeList[c("id")])

# Assign groups used for icon types and colours
# Order is important.
nodes$group[grepl("sdtm-terminology", nodes$id, perl=TRUE)] <- "SDTMTerm"  
nodes$group[grepl("study",            nodes$id, perl=TRUE)] <- "Study"  
nodes$group[grepl("code",             nodes$id, perl=TRUE)] <- "Code"  
nodes$group[grepl("custom",           nodes$id, perl=TRUE)] <- "Custom"  
nodes$group[grepl("CDISCPILOT01",     nodes$id, perl=TRUE)] <- "CDISCPilot"  
nodes$group[grepl("Person_",          nodes$id, perl=TRUE)] <- "Person"  
nodes$group[! grepl(":",              nodes$id, perl=TRUE)] <- "Literal"
nodes$group[ grepl("T\\d+:\\d+",      nodes$id, perl=TRUE)] <- "Literal"# Time values
nodes$group[ grepl("rdfs:",           nodes$id, perl=TRUE)] <- "Rdf"
# temporary kludge that fails if a literal has a colon. Close enough for development.
nodes$shape <- ifelse(grepl(":",      nodes$id), "ellipse", "box")

# Assign labels used for mouseover and for label
nodes$title <- nodes$id
nodes$label <- gsub("\\S+:", "", nodes$id)

#---- Edges
# Create list of edges by keeping the Subject and Predicate from query result.
edges<-rename(DMTriples, c("s" = "from", "o" = "to"))

# Edge values
#   use edges$label for values always present
#   use edges$title for values only present on mouseover
edges$title <-gsub("\\S+:", "", edges$p)   # label : text always present

# Graph selectible by ID or Group. 
visNetwork(nodes, edges, height = "500px", width = "100%") %>%
  visOptions(selectedBy = "group", 
             highlightNearest = TRUE, 
             nodesIdSelection = TRUE) %>%
    visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 0.5)),
             smooth = list(enabled = FALSE, type = "cubicBezier", roundness=.8)) %>%
    visGroups(groupname = "Person",    color = "#ffff33") %>%
    visGroups(groupname = "SDTMTerm",  color = "#99FF99") %>%
    visGroups(groupname = "Study",     color = "#A3A3C2") %>%
    visGroups(groupname = "Code",      color = "#99C2C2") %>%
    visGroups(groupname = "Custom",    color = "#FFB280") %>%
    visGroups(groupname = "CDISCPilot",color = "#8080FF") %>%
    visGroups(groupname = "Rdf",       color = "#c68c53") %>%
    visGroups(groupname = "Literal",   color = list(background="white", border="black")) %>%
    #  Higher damping = less motion between interations
    visPhysics(stabilization=FALSE, barnesHut = list(
                                       avoidOverlap=1,
                                       gravitationalConstant = -3000,
                                       springConstant = 0.0004,
                                       damping = 0.9,
                                       springLength = 40
                                       ))  