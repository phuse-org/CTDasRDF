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
  PREFIX cdiscpilot01: <http://w3id.org/phuse/cdiscpilot01#> 
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
label        color.border color.background font.color
Start        'red'         'yellow'       'black'
cdiscpilot01 'black'       '#2C52DA'      'white'
cdo1p        'black'       '#008D00'      'white'
code         'black'       '#1C5B64'      'white'
study        'black'       '#FFBD09'      'white'
custom       'black'       '#C71B5F'      'white'
literal      'black'       'white'        'black'
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

# Lablels for mouseover
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

# Finally, change the start node to larger size and special color
nodes$color.background[ grepl(startNode,  nodes$id, perl=TRUE) ] <- 'yellow'  
nodes$color.border[ grepl(startNode,  nodes$id, perl=TRUE) ]     <- 'red'  
nodes$size[ grepl(startNode,  nodes$id, perl=TRUE) ]             <- 60  

#---- Edges
# Create list of edges by keeping the Subject and Predicate from query result.
edges<-rename(triplesDf, c("s" = "from", "o" = "to"))
edges$arrows <- "to"
# edges$label <-"Edge"   # label : text always present
edges$title <- edges$p  # title: present when mouseover edge.
edges$length <- 500  # Could make this dynamic for large vs small graphs based on dataframe size...

edges$color <- "black"  # default and for literals
edges$color[ grepl("cdiscpilot01:", edges$to, perl=TRUE) ] <- "#2C52DA"
edges$color[ grepl("cd01p:",        edges$to, perl=TRUE) ] <- '#008D00'   
edges$color[ grepl("code:",         edges$to, perl=TRUE) ] <- '#1C5B64'
edges$color[ grepl("study:",        edges$to, perl=TRUE) ] <- '#FFBD09'  
edges$color[ grepl("custom:",       edges$to, perl=TRUE) ] <- '#C71B5F'  




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

  





