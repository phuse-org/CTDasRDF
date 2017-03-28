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
library(visNetwork)
library(plyr)
library(jsonlite)
library(visNetwork)

#-- Local TTL file
setwd("C:/_gitHub/SDTMasRDF")

C:\_gitHub\SDTMasRDF\data\rdf\study.ttl
rdfSource = load.rdf("data/rdf/study.TTL", format="N3")

# Select all the information associated with Obs113
query = 'PREFIX EG:    <http://www.example.org/cdiscpilot01#>
PREFIX RDFS: <http://www.w3.org/2000/01/rdf-schema#>
SELECT *
WHERE{
?s ?p ?o .
}'

# Remove any rows that have a blank Object. 
triples<-triples[!(triples$o==""),]

# Remove duplicates from the query
triples <- triples[!duplicated(triples),]

#---- Nodes Construction
# Unique list of nodes by combine Subject and Object into single column
# "id.vars" is the list of columns to keep untouched. The unamed ones (s,o) are 
# melted into the "value" column.
nodeList <- melt(triples, id.vars=c("p" ))

# A node can be both a Subject and a Predicate so ensure a unique list of node names
#  by dropping duplicate values.
nodeList <- nodeList[!duplicated(nodeList$value),]

# Rename to ID for use in visNetwork and keep only that column
nodeList <- rename(nodeList, c("value" = "id" ))
nodes<- as.data.frame(nodeList[c("id")])

# Assign groups used for icon types and colours
#nodes$group[grepl("Person_", nodes$id, perl=TRUE)] <- "Person"  
#nodes$group[! grepl(":", nodes$id, perl=TRUE)] <- "Literal"  
#nodes$group[ grepl('^[0-9]{4}-', nodes$id, perl=TRUE)] <- "Date"  
#nodes$group[grepl('^HISPANIC|^WHITE|^M$|^F$|^Place|^Pbo|^USA', nodes$id, perl=TRUE)] <- "CODED"  

# Kludge the shape based on if the value has colon (non-literal) 
#nodes$shape <- ifelse(grepl(":", nodes$id), "ellipse", "box")

# Assign labels used for mouseover and for label
nodes$title <- nodes$id
nodes$label <- nodes$id

#---- Edges Construction
# Create list of edges by keeping the Subject and Predicate from query result.
edges<-rename(triples, c("s" = "from", "o" = "to"))
edges$title <- edges$p  # title: present when mouseover edge.

#------------------------------------------------------------------------------
#---- Visualize 
visNetwork(nodes, edges, width="1500px", height="1000px") %>%
    visNodes(font=list(size="20"),
             borderWidth=1,
             physics=FALSE) %>%
    visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 0.5)),
             smooth = list(enabled = FALSE, type = "cubicBezier", roundness=.8))
    #visGroups(groupname = "Person", color = "#feb24c") %>%
    #visGroups(groupname = "Date", color = "#99FF99")  %>%
    #visGroups(groupname = "SDTMTerm", color = "#CC00FF")  %>%
    #visGroups(groupname = "CODED", color = "#EB99FF") %>%
    #visGroups(groupname = "Literal", color = list(background="white", border="black"))