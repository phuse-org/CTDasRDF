###############################################################################
# FILE : Person-1Level-DiagrammeR.R
# DESCR: Visualization of the nodes directly connected to Person_1 using DiagrammeR
# SRC  : 
# KEYS : 
# NOTES:  Testing DiagrammeR. 
#         
# INPUT: cdiscpilot01.TTL  (OR) local endpoint graph SDTMTORDF
# OUT  : 
# REQ  : 
# TODO : !! tooltip not working: Shows node ID
###############################################################################
library(plyr)  #  rename
library(reshape)  #  melt
library(rrdf)
library(DiagrammeR)

# Select all the information associated with Obs113
query = 'PREFIX CDISCPILOT01: <http://example.org/cdiscpilot01#> 
PREFIX study: <http://example.org/study#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX cdiscsdtm: <http://rdf.cdisc.org/sdtm-terminology#>
PREFIX code:  <http://www.example.org/code#>
PREFIX custom: <http://example.org/custom#>
prefix time:  <http://www.w3.org/2006/time#>
prefix country: <http://psi.oasis-open.org/iso/3166#>
prefix x: <http://example.org/bogus>


SELECT ?s ?p ?o 
FROM <http://localhost:8890/SDTMTORDF>
where { CDISCPILOT01:Person_1 ?p ?o . 
BIND ("CDISCPILOT01:Person_1" AS ?s)
}'


#-- Local Endpoint 
#rdfSource = "http://localhost:8890/sparql"  # local EP
#DMTriples = as.data.frame(sparql.remote(rdfSource, query))  # for local EP

#-- Local TTL file
setwd("C:/_gitHub/SDTMasRDF")
rdfSource = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")

DMTriples = as.data.frame(sparql.rdf(rdfSource, query))

# Remove any rows that have a blank Object. 
DMTriples<-DMTriples[!(DMTriples$o==""),]

# Remove duplicates from the query
DMTriples <- DMTriples[!duplicated(DMTriples),]

#---- Nodes Construction
# Get the unique list of nodes 
# Combine Subject and Object into a single column
# "id.vars" is the list of columns to keep untouched. The unamed ones (s,o) are 
# melted into the "value" column.
nodeList <- melt(DMTriples, id.vars=c("p" ))

# A node can be both a Subject and a Predicate so ensure a unique list of node names
#  by dropping duplicate values.
nodeList <- nodeList[!duplicated(nodeList$value),]

# DiagrammeR requires an integer ID value. Create based on row.
nodeList$id <- 1:nrow(nodeList)

    # Rename to ID for use in visNetwork and keep only that column
    # nodeList <- rename(nodeList, c("value" = "id" ))
nodes<- as.data.frame(nodeList[c("id", "value")])


# Assign groups used for icon types and colours
# Order is important.
# p:Person_1
# nodes$group[nodes$id == "p:Person_1"]    <- "Person"  # Works
nodes$group[grepl("cdiscsdtm", nodes$value, perl=TRUE)] <- "SDTMTerm"  #
nodes$group[grepl("study", nodes$value, perl=TRUE)] <- "Study"  #
nodes$group[grepl("CDISCPILOT01", nodes$value, perl=TRUE)] <- "CDISCPilot"  #
nodes$group[grepl("Person_", nodes$value, perl=TRUE)] <- "Person"  #
nodes$group[! grepl(":", nodes$value, perl=TRUE)] <- "Literal"  #
# temporary kludge that fails if a literal has a colon. Close enough for development.
nodes$shape <- ifelse(grepl(":", nodes$value), "ellipse", "box")

# Set node colors
nodes$fillcolor[grepl("CDISCPILOT01", nodes$value, perl=TRUE)] <- "#1AA2DC"  #

nodes$fontcolor <- "black"


nodes$tooltip <- nodes$value
# Assign labels used for mouseover and for label
nodes$label <- gsub("CDISCPILOT01:|study:|custom:","",nodes$value, perl=TRUE)

edges<-DMTriples

# Merge ID on subject (s)  field as the 'from' node
edges <- merge (edges, nodes, by.x="s", by.y="value")
names(edges)[names(edges) == 'id'] <- 'from'

# Merge ID on subject (o) field as the 'to' node
edges <- merge (edges, nodes, by.x="o", by.y="value")
names(edges)[names(edges) == 'id'] <- 'to'
names(edges)[names(edges) == 'p'] <- 'rel'

edges <- edges[,c("from", "rel", "to")]

graph <- 
    create_graph(
        nodes_df = nodes,
        edges_df = edges
    )
render_graph(graph = graph,
    layout = "fr")






