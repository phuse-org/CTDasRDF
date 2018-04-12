###############################################################################
# FILE: Person-3DNetwork-TripleStore.R
# DESC: 3D Network Visualization of the nodes connected to Person_1
#        Data: Traverse the graph outward from Person_1 using SPARQL
# SRC : Eg code: https://github.com/nstrayer/network3d
# DOCS: http://livefreeordichotomize.com/2018/04/09/network3d---a-3d-network-visualization-and-layout-library/
#
# IN  : Stardog graph CTDasRDFOnt
# OUT : 3D Network graph. View in Google Chrome. Will not show up in RStudio viewer.Set your OS 
#       default browser to chrome following instructions:
#         https://support.google.com/chrome/answer/95417?co=GENIE.Platform%3DDesktop&hl=en
# INSTALL: Package is not in CRAN.
#   library(devtools)
#   devtools::install_github('nstrayer/network3d')
# NOTE: Loads prefixes from  prefixes.csv. 
#       Bogus 'x' prefix needed for path traversal in SPARQL query
# Data:  vertices : id (name) (color) (size)
#        edges: source target
#
# TODO: Person_1 is hard coded, Must change to new naming convention in APR 2018
#       
###############################################################################
library(network3d)
library(dplyr)     #  rename
library(reshape)  #  melt
library(SPARQL)
library(tidyverse)

setwd("C:/_gitHub/CTDasRDF/r")
source("validation/Functions.R")

epOnt = "http://localhost:5820/CTDasRDFOnt/query"

# Read in the prefixes
prefixList <- read.csv(file="prefixList.csv", header=TRUE, sep=",")

# Create a combined prefix IRI column.
prefixList$prefix_ <- paste0("PREFIX ",prefixList$prefix, " ", prefixList$iri)

# Collapse into a single string
prefixBlock <- paste(prefixList$prefix_, collapse = "\n")

# Note addition of prefix 'x' needed for traversal
query = paste0(prefixBlock,"
  PREFIX x: <http://example.org/bogus>
  SELECT ?s ?p ?o 
  WHERE { cdiscpilot01:Person_1 (x:foo|!x:bar)* ?s . 
    ?s ?p ?o . 
  }")

# Query results dfs ----  
qr <- SPARQL(url=epOnt, query=query)
    
personTriples <- as.data.frame(qr$results)

# Remove any rows that have a blank Object. 
personTriples<-personTriples[!(personTriples$o==""),]

# Remove duplicates from the query
personTriples <- personTriples[!duplicated(personTriples),]

# shorten from IRI to qnam
triplesDer <- IRItoPrefix(sourceDF=personTriples, colsToParse=c("s", "p", "o"))

#---- Nodes Construction
# Unique list of nodes by combine Subject and Object into a single column
#   "id.vars" is the list of columns to keep untouched. The unamed ones (s,o) are 
#   melt into the "value" column.
nodeList <- melt(triplesDer, id.vars=c("p" ))

# A node can be both Subject and Object. Ensure a unique list of node names
#   by dropping duplicate values.
nodeList <- nodeList[!duplicated(nodeList$value),]

# ERROR HERE
# Rename to ID for use in visNetwork and keep only that column
nodeList <- rename(nodeList, c("value" = "id" ))
nodes<- as.data.frame(nodeList[c("id")])

# Assign groups used for icon types and colours
# Order is important. 
# TODO: many not assigned with new data APR2018
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
nodes$name <- gsub("\\S+:", "", nodes$id)

#---- Edges
# Create list of edges by keeping the Subject and Predicate from query result.
edges<-rename(triplesDer, c("s" = "source", "o" = "target"))

# Edge values
#   use edges$label for values always present
#   use edges$title for values only present on mouseover
edges$title <-gsub("\\S+:", "", edges$p)   # label : text always present



# CREATE THE COLOURS HERE!!!!
# Define colors based on the prefix in the id variable.
# Order is important. Eg: Person defined last
# Assign node color based on content (int, string) then based on prefixes
nodes$color <- "#d8d8d8"  # DEFAULT = light gray
nodes$color[grepl("^cd01p:", nodes$id, perl=TRUE)] <- "#bb00bb"
nodes$color[grepl("^cdiscpilot01:", nodes$id, perl=TRUE)] <- "#ffe6cc"
nodes$color[grepl("^code:", nodes$id, perl=TRUE)] <- "#b1b1ff"
nodes$color[grepl("^custom:", nodes$id, perl=TRUE)] <- "#b1b1ff"
nodes$color[grepl("^study:", nodes$id, perl=TRUE)] <- "red"
nodes$color[grepl("ncit:|schema:|sdtmterm", nodes$id, perl=TRUE)] <- "#ffb733"
nodes$color[grepl("^cdiscpilot01:Person_", nodes$id, perl=TRUE)] <- "yellow"


# rearrange for 3D graph data
vertices <- data.frame(nodes[,c("id","name", "color")])

# recoding for size and color
vertices$size <- .1
vertices$size[vertices$name =="Person_1"] <- .3

edges <- data.frame(edges[,c("source","target")])

network3d(vertices, edges, 
          node_outline_black = TRUE,
          max_iterations = 75,
          manybody_strength = 0.5, 
          background_color = "#002b36",
          edge_color = "#00e600",
          edge_opacity = 1,
          force_explorer = TRUE
          )

