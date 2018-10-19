library(stringr)
library(visNetwork)
library(reshape)  #  melt
library(dplyr)

# Configuration
setwd("C:/Temp/git/CTDasRDF_PlaygroundKG")


all <- read.csv(file = "r/vis/support/ts-mapping.csv", sep = ";")

nodes <- all[all$Type=="class",c("s","Type","new")]
nodes$id <- nodes[,c("s")]
nodes <- reshape::rename(nodes, c("s" = "description" ))
nodes$shape <- "box"
nodes$borderWidth <- 2
#nodes$color <- "blue"
nodes$color[is.na(nodes$new)] <- "grey"
nodes$label <- nodes$id


edges <- all[all$Type=="triple",c("s","p","o")]
edges<-reshape::rename(edges, c("s" = "from", "o" = "to"))
edges$title <- edges$p  # title: present when mouseover edge.
edges$label <- edges$p  #TW  May need to shorten as did for node label
#edges$color <-"#808080" # Default edge color
#edges$length <- 500
edgesList$arrows <- "to"


visNetwork(nodes, edges, width= "100%", height=1100) %>%
  
  visIgraphLayout(layout = "layout_nicely",
                  physics = FALSE) %>%
  
  visIgraphLayout(avoidOverlap = 1) %>%
  
  # visEdges(smooth=FALSE, color="#808080") %>%
  visEdges(smooth=FALSE)