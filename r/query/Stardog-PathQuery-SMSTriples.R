###############################################################################
# FILE: Stardog-PathQuery-SMSTriples.R
# DESC: Path query to the CTDasRDF triples created by SMS mapping
#       
# SRC : 
# IN  : triplestore database CTDasRDFSMS
# OUT : 
# REQ : Stardog running: 1. on port  5820
#       2. with --disable-security option during start
# SRC : 
# NOTE:
# TODO: Adjust code for use in a new version of CollapsibeTree-Shiny.R to use
#       paths instead of SPARQL.
###############################################################################
library(plyr)     #  rename
library(reshape)  #  melt
library(SPARQL)
library(visNetwork)
setwd("C:/_gitHub/CTDasRDF/r")
source("validation/Functions.R")  # IRI to prefix and other fun

# Make these parameters in RShiny YUI
startNode <- "cdiscpilot01:Person_01-701-1015"
hops      <- 2  # Max of 3 in RShiny UI, else performance issues?

# Query StardogTriple Store ----
endpoint <- "http://localhost:5820/CTDasRDFSMS/query"

queryOnt = paste0("
  PREFIX cdiscpilot01: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#> 
  PATHS START ?s = ", startNode, "  END ?o VIA ?p  MAX LENGTH ", hops, " ")

qd <- SPARQL(endpoint, queryOnt)
triplesDf <- qd$results

# Remove artifacts from Stardog path query. complete.cases did not work here
triplesDf <- triplesDf[!is.na(triplesDf[,1]),]

triplesDf <- triplesDf[, c("s", "p", "o")]
triplesDf <- IRItoPrefix(sourceDF=triplesDf, colsToParse=c("s", "p", "o"))


# -----------------------------------------------------------------------------
#---- Nodes Construction
# Get the unique list of nodes 
# Combine Subject and Object into a single column
# "id.vars" is the list of columns to keep untouched. The unamed ones (s,o) are 
# melted into the "value" column.
nodeList <- melt(triplesDf, id.vars=c("p" ))

# A node can be both a Subject and a Predicate so ensure a unique list of node names
#  by dropping duplicate values.
nodeList <- nodeList[!duplicated(nodeList$value),]

# Rename to ID for use in visNetwork and keep only that column
nodeList <- rename(nodeList, c("value" = "id" ))
nodes<- as.data.frame(nodeList[c("id")])


# Assign groups used for icon types and colours
# Order is important.
# p:Person_1
# nodes$group[nodes$id == "p:Person_1"]    <- "Person"  # Works
nodes$group[grepl("cdiscsdtm", nodes$id, perl=TRUE)] <- "SDTMTerm"  #
nodes$group[grepl("study", nodes$id, perl=TRUE)] <- "Study"  #
nodes$group[grepl("CDISCPILOT01", nodes$id, perl=TRUE)] <- "CDISCPilot"  #
nodes$group[grepl("Person_", nodes$id, perl=TRUE)] <- "Person"  #


# Assign labels used for mouseover
nodes$title <- nodes$id
nodes$label <- nodes$id

nodes$size <- 30

#---- Edges
# Create list of edges by keeping the Subject and Predicate from query result.
edges<-rename(triplesDf, c("s" = "from", "o" = "to"))
edges$arrows <- "to"
# edges$label <-"Edge"   # label : text always present
edges$title <- edges$p  # title: present when mouseover edge.
edges$length <- 500


# physics=FALSE = motion turned off & can drag and drop nodes.

visNetwork(nodes, edges, width= "100%") %>%
    # visPhysics(solver = "forceAtlas2Based", forceAtlas2Based = list(gravitationalConstant = -10))%>%
    #centralGravity = 0.3
    visPhysics(stabilization = FALSE, 
               barnesHut = list(
                 gravitationalConstant = -1000,
                 centralGravity        = .5,
                 springConstant        = 0.001,
                 springLength          = 100,
                 damping               = .1,
                 avoidOverlap          = 1)) %>%
    visEdges(smooth=FALSE) %>%
    visGroups(groupname = "Person", color = "darkblue") %>%
    visGroups(groupname = "SDTMTerm", color = "red")  %>%
    visGroups(groupname = "Study", color = "yellow")  %>%
    visGroups(groupname = "CDISCPilot", color = "green") 
    
    #visNodes(shadow = TRUE, physics=FALSE) 






