###############################################################################
# FILE: Stardog-PathQuery-SMSTriples-visNetork.R
# DESC: Path query to the CTDasRDF triples created by SMS mapping 
#       
# SRC : 
# IN  : triplestore graph:  CTDasRDFSMS
# OUT : 
# REQ : Stardog running: 1. on port  5820
#                        2. with --disable-security option during start
# SRC : 
# NOTE: See here for Legend construction: C:\_gitHub\CTDasRDF\r\vis\SMSMap-Vis.R
#     COLOR PALETTE
#     Background:  grey: #919191
#     Yellow node: #FFBD09
#     Blue node: #2C52DA
#     Bright. Turq:  #3DDAFD
#     Green node: #008D00
#     BlueGreen node: #1C5B64
#     DK red node: #870922
#     Br red node: #C71B5F
#     Purp Node: #482C79
#     Br. Or Node: #FE7900
# TODO: 
#       Change label color in Legend
#  
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
# Nodes Construction ----

#-- Legend Nodes Legend ----
# Yellow node: #FFBD09
# Blue node: #2C52DA
# Bright. Turq:  #3DDAFD
# Green node: #008D00
# BlueGreen node: #1C5B64
# DK red node: #870922
# Br red node: #C71B5F
# Purp Node: #482C79
# Br. Or Node: #FE7900

lnodes <- read.table(header = TRUE, text = "
label        color.border color.background
cdiscpilot01 'black'       '#2C52DA'      
cdo1p        'black'       '#008D00'      
code         'black'       '#1C5B64'
study        'black'       '#FFBD09'   
custom       'black'       '#C71B5F'   
")

lnodes$shape <- "box"
lnodes$title <- "Legend"


# -- Nodes: Data ----
# Get the unique list of nodes 
#   Combine Subject and Object into a single column
#   "id.vars" is the list of columns to keep untouched. The unamed ones (s,o) are 
#   melted into the "value" column.
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
nodes$color.background <- "white"
nodes$color.border     <- "black"


# Nodes color based on prefix
nodes$color.background[ grepl("cdiscpilot01:", nodes$id, perl=TRUE) ] <- "#2C52DA"
nodes$color.background[ grepl("cd01p:",        nodes$id, perl=TRUE) ] <- '#008D00'   
nodes$color.background[ grepl("code:",         nodes$id, perl=TRUE) ] <- '#1C5B64'
nodes$color.background[ grepl("study:",        nodes$id, perl=TRUE) ] <- '#FFBD09'  
nodes$color.background[ grepl("custom:",        nodes$id, perl=TRUE) ] <- '#C71B5F'  

#cdiscpilot01 'black'       '#2C52DA'      
#cdo1p        'black'       '#008D00'      
#code         'black'       '#1C5B64'
#study        'black'       '#FFBD09'      


#---- Edges
# Create list of edges by keeping the Subject and Predicate from query result.
edges<-rename(triplesDf, c("s" = "from", "o" = "to"))
edges$arrows <- "to"
# edges$label <-"Edge"   # label : text always present
edges$title <- edges$p  # title: present when mouseover edge.
edges$length <- 500


#---- Visualize 
visNetwork(nodes, edges, width= "100%", height=1100, background = "#919191") %>%
    
  visIgraphLayout(layout = "layout_nicely",
                  physics = FALSE) %>%  

  visIgraphLayout(avoidOverlap = 1) %>%

  # visEdges(smooth=FALSE, color="#808080") %>%
  visEdges(smooth=FALSE)  %>%


# Legend
#   Examples at : https://datastorm-open.github.io/visNetwork/legend.html  
  visLegend(addNodes  = lnodes, 
            useGroups = FALSE,
            width     =  .2,
            stepY     = 60)

  





