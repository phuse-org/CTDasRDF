
library("Rgraphviz")
library(SPARQL)

# Query StardogTriple Store ----
endpoint <- "http://localhost:5820/CTDasRDFOWL/query"

prefix <- c("cd01p",        "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01-protocol.ttl",
            "cdiscpilot01", "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#",
            "code",         "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/code.ttl#",
            "custom",       "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/custom#",
            "owl",          "http://www.w3.org/2002/07/owl#",
            "rdf",          "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            "rdfs",         "http://www.w3.org/2000/01/rdf-schema#",
            "sdtmterm",     "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/sdtm-terminology.rdf#",
            "skos",         "http://www.w3.org/2004/02/skos/core#",
            "study",        "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#",
            "time",         "http://www.w3.org/2006/time#")

# if you get an error like: Error: 1: AttValue: " or ' expected, then remove your proxy settings, e.g.
Sys.setenv(http_proxy="")
Sys.setenv(https_proxy="")

addToClasses <- function(list, element){
  if (! element %in% classList){
    return(c(list,element))
  }
  return(list)
}

addToEdge <- function(edgesIn, from, to){
  if (dim(edgesIn)[1] == 0){
    edgesIn <- rbind(edgesIn,c(from, to))
  }
  else if (max(edgesIn[,1]==from && edgesIn[,2]==to, na.rm=TRUE) == 0) {
    edgesIn <- rbind(edgesIn,c(from, to))
  }
  return(edgesIn)
}

addToEdgeLabel <- function(edgesLabelsIn, from, to, label){
  id = paste(from,'~',to,sep="")
  return(cbind(edgesLabelsIn, id=label))
}


addConnection <- function (classLi, edgesIn, edgesLabelsIn, from, to, label){
  classLi <- addToClasses(classLi, from)
  classLi <- addToClasses(classLi, to)
  classList <<- classLi
  edges <<- addToEdge(edgesIn, from, to)
  edgesLabels <<- addToEdgeLabel(edgesLabelsIn, from, to, label)
}




classList <- list()
edges <- na.omit(matrix(ncol=2))
edgesLabels <- c()


classOfInterest = "study:EnrolledSubject"


classList <- addToClasses(classList, classOfInterest)
addConnection(classList, edges, edgesLabels,"study:EnrolledSubject","study:HumanStudySubject","subClass")
addConnection(classList, edges, edgesLabels,"study:EnrolledSubject","study:HumanStudySubject","subClass")
addConnection(classList, edges, edgesLabels,"study:Study","study:HumanStudySubject","hasStudyParticipant")
addConnection(classList, edges, edgesLabels,"study:StudyActivity","study:HumanStudySubject","hasParticipant")
addConnection(classList, edges, edgesLabels,"study:HumanStudySubject","study:ReferenceInterval","study:hasReferenceInterval")
addConnection(classList, edges, edgesLabels,"study:HumanStudySubject","study:Site","study:hasSite")
addConnection(classList, edges, edgesLabels,"study:HumanStudySubject","study:StudyParticipationInterval","study:hasStudyParticipationInterval")
addConnection(classList, edges, edgesLabels,"study:HumanStudySubject","study:Study","study:participatesInStudy")

str(edges[i,1])

studyGraph <- addEdge(edges[1,1], edges[1,2], studyGraph, 1)  

studyGraph <- new("graphNEL", nodes=unlist(classList), edgemode="directed")
for (i in 1 : dim(edges)[1]){
  studyGraph <- addEdge(edges[i,1], edges[i,2], studyGraph, 1)  
}
myEAttrs <- list()
myEAttrs$label <- edgesLabels
plot(studyGraph)

plot(studyGraph, attrs=list(node=list(fillcolor="lightgreen", 
                                        fontsize=16, shape="box", width="2"),
                              graph=list(rankdir="LR")), main = "Figure 1: Step overview")

edgesLabels

test <- c("Study~Subject"="Participates in", "Study~Site"="has")
test



query <- paste("SELECT * WHERE {", classOfInterest, " ?p ?o}")
qd <- SPARQL(endpoint, query, ns=prefix)
resultsDF <- qd$results

if (! classOfInterest %in% classList){
  classList <- c(classList,classOfInterest)
}

#investigate all classes where the current class is subclass of
resultsDF[resultsDF[,] == "rdfs:subClassOf",][,2]
resultsDF

classList <- addToClasses(classList,"dummy")
