###############################################################################
# FILE : Person-VisNetwork.R
# DESCR: 
# SRC  : 
# KEYS : 
# NOTES:  for formatting visNetwork see my personal collection at:
#          codeEg/visNetwork/visNetwork-EgFromDoc.R
#       here for example dataframe: https://cran.r-project.org/web/packages/visNetwork/vignettes/Introduction-to-visNetwork.html
#
# INPUT: cdiscpilot01.TTL  (OR) local endpoint graph SDTMTORDF
#      : 
# OUT  : 
# REQ  : 
# TODO : add mouseover labels to nodes
#        add mouseover labels to edges
#        add special icon for Person
#        add different colours 
#        change background colour to dark
###############################################################################
library(plyr)  #  rename
library(reshape)  #  melt
library(rrdf)
library(visNetwork)

# Select all the information associated with Obs113
query = 'PREFIX CDISCPILOT01: <http://example.org/cdiscpilot01#> 
PREFIX study: <http://example.org/study#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX cdiscsdtm: <http://rdf.cdisc.org/sdtm-terminology#>
PREFIX code:  <http://www.example.org/code#>
PREFIX custom: <http://www.example.org/custom#>
prefix time:  <http://www.w3.org/2006/time#>
prefix country: <http://psi.oasis-open.org/iso/3166#>
prefix x: <http://example.org/bogus>


SELECT ?s ?p ?o 
FROM <http://localhost:8890/SDTMTORDF>
where { CDISCPILOT01:Person_1 (x:foo|!x:bar)* ?s . 
?s ?p ?o . 
}'


#-- Local Endpoint 
#rdfSource = "http://localhost:8890/sparql"  # local EP
#DMTriples = as.data.frame(sparql.remote(rdfSource, query))  # for local EP

#-- Local TTL file
setwd("C:/_gitHub/SDTM2RDF")
rdfSource = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")


DMTriples = as.data.frame(sparql.rdf(rdfSource, query))
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

# Rename to ID for use in visNetwork and keep only that column
nodeList <- rename(nodeList, c("value" = "id" ))
nodes<- as.data.frame(nodeList[c("id")])


# Assign groups used for icon types and colours
# p:Person_1
# nodes$group[nodes$id == "p:Person_1"]    <- "Person"  # Works
nodes$group[grepl("Person_", nodes$id, perl=TRUE)] <- "Person"  #
nodes$group[grepl("cdiscsdtm", nodes$id, perl=TRUE)] <- "SDTMTerm"  #

# Assign labels used for mouseover
nodes$title <- nodes$id


nodes$size <- 30

#---- Edges
# Create list of edges by keeping the Subject and Predicate from query result.
edges<-rename(DMTriples, c("s" = "from", "o" = "to"))
edges$arrows <- "to"
# edges$label <-"Edge"   # label : text always present
edges$title <- edges$p  # title: present when mouseover edge.
edges$length <- 500


# physics=FALSE = motion turned off & can drag and drop nodes.

visNetwork(nodes, edges, width= "100%") %>%
    # visPhysics(solver = "forceAtlas2Based", forceAtlas2Based = list(gravitationalConstant = -10))%>%
    visGroups(groupname = "Person", color = "darkblue") %>%
    visGroups(groupname = "SDTMTerm", color = "red")  %>%
    visNodes(shadow = TRUE, physics=FALSE)  %>%
    visHierarchicalLayout(direction = "LR")

