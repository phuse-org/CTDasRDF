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

addToEdges <- function(list, from, to, connectionDescription){
  if (! to %in% unlist(edgesListXX[edgesListXX$from == from,]["to"])){
    newItem <- data.frame(from, to, connectionDescription)
    colnames(newItem) <- edgesListLabels
    list <- rbind(list, newItem)
    return(list)
  }
  return(list)
}

addToGraph <- function(from, to, connectionDescription){
  nodesListXX <<- addToNodes(nodesListXX,from,unlist(strsplit(from,":"))[2])
  nodesListXX <<- addToNodes(nodesListXX,to,unlist(strsplit(to,":"))[2])
  edgesListXX <<- addToEdges(edgesListXX, from, to,connectionDescription)
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
addToGraph("study:Study","study:Title","study:hasTitle")


# nodesListXX <- addToNodes(nodesListXX,"study:Study","Study")
# nodesListXX <- addToNodes(nodesListXX,"study:Study","Study")
# nodesListXX <- addToNodes(nodesListXX,"study:StudyTest","StudyTest")
# edgesListXX <- addToEdges(edgesListXX, "study:Study", "study:StudyTest","simple link")
# edgesListXX <- addToEdges(edgesListXX, "study:Study", "study:Study","link own")


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



Sys.setenv(http_proxy="")
Sys.setenv(https_proxy="")

# Endpoint
endpoint <- "http://localhost:5820/CTDasRDFOWL/query"

prefix <- c("cd01p",        "http://w3id.org/phuse/cd01p#",
            "cdiscpilot01", "http://w3id.org/phuse/cdiscpilot01#",
            "code",         "http://w3id.org/phuse/code#",
            "custom",       "http://w3id.org/phuse/custom#",
            "owl",          "http://www.w3.org/2002/07/owl#",
            "rdf",          "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            "rdfs",         "http://www.w3.org/2000/01/rdf-schema#",
            "sdtmterm",     "http://w3id.org/phuse/sdtmterm#",
            "skos",         "http://www.w3.org/2004/02/skos/core#",
            "study",        "http://w3id.org/phuse/study#",
            "time",         "http://www.w3.org/2006/time#")

queryOnt = paste0("SELECT * WHERE {?predicate  rdfs:domain ?domain 
                OPTIONAL {?predicate rdfs:range ?range}} LIMIT 10")

qd <- SPARQL(endpoint, queryOnt, ns=prefix)
triplesDf <- qd$results



for (row in 1:nrow(triplesDf)) {
  addToGraph(triplesDf$domain,triplesDf$range,triplesDf$predicate)
}

warnings()


##- function with extra args:
#cave <- function(x, c1, c2) c(mean(x[c1]), mean(x[c2]))
apply(triplesDf, 1, addToGraph,  from = "domain", to = "range", connectionDescription="predicate")


apply(triplesDf, 2, addToGraph, from=triplesDf$domain, to=triplesDf$range, connectionDescription=triplesDf$predicate)

apply(triplesDf, 2, print)





m <- matrix(c(1:10, 11:20), nrow = 10, ncol = 2)
foo <- function(x)
{
  print( c("hallo", x, "World"));
  return(NULL)
}
m
apply(triplesDf, 1, FUN=foo)

