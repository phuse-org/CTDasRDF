library(stringr)
library(visNetwork)
library(reshape)  #  melt
library(dplyr)

# Configuration
setwd("C:/Temp/git/CTDasRDF")
maxLabelSize <- 40

# provide functions
addToNodes <- function(list, id, description){
  if (! id %in% unlist(nodesListXX["id"])){
    newItem <- data.frame(id,description)
    colnames(newItem) <- nodesListLabels
    list <- rbind(list, newItem)
    return(list)
  }
  return(list)
}

addToEdges <- function(list, from, to, description){
  if (! to %in% unlist(edgesListXX[edgesListXX$from == from,]["to"])){
    newItem <- data.frame(from, to, description)
    colnames(newItem) <- edgesListLabels
    list <- rbind(list, newItem)
    return(list)
  }
  return(list)
}

#nodesList - dataFrame with id, description, label, shape, borderWidth
#edgesList - from, to, arrows, title, label, color, length

# initialize lists
nodesListXX     <- data.frame(matrix(ncol = 2, nrow = 0))
nodesListLabels <- c("id", "description")
colnames(nodesListXX) <- nodesListLabels

edgesListXX <- data.frame(matrix(ncol = 3, nrow = 0))
edgesListLabels <- c("from", "to", "title")
colnames(edgesListXX) <- edgesListLabels


# fill lists
nodesListXX <- addToNodes(nodesListXX,"study:Study","Study")
nodesListXX <- addToNodes(nodesListXX,"study:Study","Study")
nodesListXX <- addToNodes(nodesListXX,"study:StudyTest","StudyTest")

edgesListXX <- addToEdges(edgesListXX, "study:Study", "study:StudyTest","simple link")
edgesListXX <- addToEdges(edgesListXX, "study:Study", "study:Study","link own")


# include formatting
nodesListXX$label <- strtrim(nodesListXX$id, maxLabelSize) 
nodesListXX$shape <- "box"
nodesListXX$borderWidth <- 2

edgesListXX$arrows <- "to"
edgesListXX$label <- strtrim(edgesListXX$title, maxLabelSize) 
edgesListXX$color <-"#808080"
edgesListXX$length <- 500


# print list
nodesListXX
edgesListXX



visNetwork(nodesListXX, edgesListXX, width= "100%", height=1100) %>%

  visIgraphLayout(layout = "layout_nicely",
                  physics = FALSE) %>%

  visIgraphLayout(avoidOverlap = 1) %>%

  visEdges(smooth=FALSE)
