#______________________________________________________________________________
# FILE: r/vis/vis_stardog_dbs.r
# DESC: Ontology visualization and actual data visualization
# SRC :
# IN  : stardog database: CTDasRDFOWL, containing the study.ttl file loaded as triples
#       stardog database: CTDasRDFSMS, containing the content triples, e.g. cdiscpilot01.ttl (ideally subsets only)
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
# DATE: 2018-11-23
# BY  : KG
#______________________________________________________________________________



# initialize
library(stringr)
library(visNetwork)
library(reshape)  #  melt
library(dplyr)
library(SPARQL)

# Configuration
setwd("C:/Temp/git/CTDasRDF/r/vis")
maxLabelSize <- 40


#####################################################
# include functions
#####################################################

addToNodes <- function(list, id, description, label=id){
  if (! id %in% unlist(nodesListXX["id"])){
    newItem <- data.frame(id,description, label, stringsAsFactors = FALSE)
    colnames(newItem) <- nodesListLabels
    list <- rbind(list, newItem)
    return(list)
  }
  return(list)
}

addToEdges <- function(list, from, to, connectionDescription){
  # if from and to is already available, check whether connectionDescription is already available, add if appropriate
  if (dim(edgesListXX[edgesListXX$from == from & edgesListXX$to == to,])[1] != 0){
    # check if description is already in
    edgeTitle <- edgesListXX[edgesListXX$from == from & edgesListXX$to == to,]$title
    if (grepl(connectionDescription,toString(edgeTitle))){
      return(list)
    }
    else {
      # include new connection
      edgesListXX[edgesListXX$from == from & edgesListXX$to == to,]$title <<- paste0(edgeTitle,"\n",connectionDescription)
    }
  }
  else {
    newItem <- data.frame(from, to, connectionDescription, stringsAsFactors = FALSE)
    colnames(newItem) <- edgesListLabels
    list <- rbind(list, newItem)
    return(list)
  }
  return(list)
}

addToGraph <- function(from, to, connectionDescription, 
                       listUniquesPrefixes = c("xsd","code")){
  # make a unique label, to map not all, e.g. to xsd:string
  label_to <- to
  if (unlist(strsplit(to,":"))[1] %in% listUniquesPrefixes){
    to <- paste0(to,"_",from,"_",connectionDescription)
  }
  
  nodesListXX <<- addToNodes(nodesListXX,from,unlist(strsplit(from,":"))[2])
  nodesListXX <<- addToNodes(nodesListXX,to,unlist(strsplit(to,":"))[2], label=label_to)
  edgesListXX <<- addToEdges(edgesListXX, from, to,connectionDescription)
}


# initialize lists
initLists <- function (){
  nodesListXX     <<- data.frame(matrix(ncol = 3, nrow = 0), stringsAsFactors = FALSE)
  nodesListLabels <<- c("id", "description", "label")
  colnames(nodesListXX) <<- nodesListLabels
  
  edgesListXX <<- data.frame(matrix(ncol = 3, nrow = 0), stringsAsFactors = FALSE)
  edgesListLabels <<- c("from", "to", "title")
  colnames(edgesListXX) <<- edgesListLabels
}

# include formatting
formatList <- function(){
  nodesListXX$label <<- strtrim(nodesListXX$label, maxLabelSize)   
  nodesListXX$shape <<- "box"
  nodesListXX$borderWidth <<- 2
  
  # Nodes color based on prefix
  nodesListXX$color.background[ grepl("study:",        nodesListXX$id, perl=TRUE) ] <<- '#FFBD09'  
  nodesListXX$color.background[ grepl("cdiscpilot01:", nodesListXX$id, perl=TRUE) ] <<- "#CCFFCC"
  nodesListXX$color.background[ grepl("cd01p:",        nodesListXX$id, perl=TRUE) ] <<- '#008D00'   
  nodesListXX$color.background[ grepl("code:",         nodesListXX$id, perl=TRUE) ] <<- '#80F3EF'
  nodesListXX$color.background[ grepl("custom:",       nodesListXX$id, perl=TRUE) ] <<- '#C71B5F'
  # Create "other" namespace group
  nodesListXX$color.background[ grepl("time:|owl:|xsd:",    nodesListXX$id, perl=TRUE) ] <<- '#FCFF98'  # Lt Yel
  
  edgesListXX$arrows <<- "to"
  edgesListXX$label <<- strtrim(edgesListXX$title, maxLabelSize) 
  edgesListXX$color <<-"#808080"
  edgesListXX$length <<- 500  
}


prefix <- c("cd01p",        "https://w3id.org/phuse/cd01p#",
            "cdiscpilot01", "https://w3id.org/phuse/cdiscpilot01#",
            "code",         "https://w3id.org/phuse/code#",
            "custom",       "https://w3id.org/phuse/custom#",
            "owl",          "http://www.w3.org/2002/07/owl#",
            "rdf",          "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            "rdfs",         "http://www.w3.org/2000/01/rdf-schema#",
            "sdtmterm",     "https://w3id.org/phuse/sdtmterm#",
            "skos",         "http://www.w3.org/2004/02/skos/core#",
            "study",        "https://w3id.org/phuse/study#",
            "time",         "http://www.w3.org/2006/time#",
            "rdfs",         "http://www.w3.org/2000/01/rdf-schema#",
            "xsd",          "http://www.w3.org/2001/XMLSchema#",
            "cts",          "https://w3id.org/phuse/cts#",
            "mms",          "https://w3id.org/phuse/mms#",
            "sdtm313",      "http://rdf.cdisc.org/std/sdtmig-3-1-3#",
            "sdtm",         "https://w3id.org/phuse/sdtm#")

Sys.setenv(http_proxy="")
Sys.setenv(https_proxy="")


#####################################################
# create content graph for CTDasRDFSMS
#####################################################

# Endpoint
endpoint <- "http://localhost:5820/CTDasRDFSMS/query"
queryOnt = paste0("SELECT * WHERE {?subject ?predicate ?object}")
qd <- SPARQL(endpoint, queryOnt, ns=prefix)
triplesDf <- qd$results


initLists()

# include triples
for (row in 1:nrow(triplesDf)) {
  if (!is.na(triplesDf$subject[row]) && !is.na(triplesDf$predicate[row]) && !is.na(triplesDf$object[row])  ){
    if ( triplesDf$subject[row] != "" && triplesDf$predicate[row] != "" && triplesDf$object[row] != "" &&
        (!grepl("owl:",triplesDf$predicate[row]) && !grepl("owl:",triplesDf$object[row]))){
      addToGraph(triplesDf$subject[row],triplesDf$object[row],triplesDf$predicate[row])    
    }
  }
}

formatList()

visNetwork(nodesListXX, edgesListXX, width= "100%", height=1100) %>%
  visIgraphLayout(layout = "layout_nicely",
                  physics = FALSE) %>%
  visIgraphLayout(avoidOverlap = 1) %>%
  visEdges(smooth=FALSE) %>% 
  visOptions(manipulation = TRUE)

#####################################################
# create Ontology graph for CTDasRDFOWL (all)
#####################################################


endpoint <- "http://localhost:5820/CTDasRDFOWL/query"
queryOnt = paste0("SELECT * WHERE {?predicate  rdfs:domain ?domain 
                  OPTIONAL {?predicate rdfs:range ?range}}")
qd <- SPARQL(endpoint, queryOnt, ns=prefix)
triplesDf <- qd$results

initLists()

# include triples
for (row in 1:nrow(triplesDf)) {
  if (!is.na(triplesDf$domain[row]) && !is.na(triplesDf$range[row]) && !is.na(triplesDf$predicate[row])){
    addToGraph(triplesDf$domain[row],triplesDf$range[row],triplesDf$predicate[row])  
  }
}

formatList()

visNetwork(nodesListXX, edgesListXX, width= "100%", height=1100) %>%
  visIgraphLayout(layout = "layout_nicely",
                  physics = FALSE) %>%
  visIgraphLayout(avoidOverlap = 1) %>%
  visEdges(smooth=FALSE) %>% 
  visOptions(manipulation = TRUE)


#####################################################
# create Ontology graph for CTDasRDFOWL (ofInterest_01)
#####################################################


endpoint <- "http://localhost:5820/CTDasRDFOWL/query"
queryOnt = paste0("SELECT * WHERE {?predicate  rdfs:domain ?domain 
                  OPTIONAL {?predicate rdfs:range ?range}}")
qd <- SPARQL(endpoint, queryOnt, ns=prefix)
triplesDf <- qd$results

ofInterst=c("study:Study",
            "skos:prefLabel",
            "study:narms",
            "study:hasTitle",
            "study:Title",
            "study:longTitle",
            "study:shortTitle",
            "study:PrimaryObjective",
            "study:SecondaryObjective")

triplesDf <- triplesDf[(triplesDf$domain %in% ofInterst & triplesDf$range %in% ofInterst) | 
                       (triplesDf$domain %in% ofInterst & triplesDf$predicate %in% ofInterst),]

initLists()
# include triples
for (row in 1:nrow(triplesDf)) {
  if (!is.na(triplesDf$domain[row]) && !is.na(triplesDf$range[row]) && !is.na(triplesDf$predicate[row])){
    addToGraph(triplesDf$domain[row],triplesDf$range[row],triplesDf$predicate[row])  
  }
}

formatList()

visNetwork(nodesListXX, edgesListXX, width= "100%", height=1100) %>%
  visIgraphLayout(layout = "layout_nicely",
                  physics = FALSE) %>%
  visIgraphLayout(avoidOverlap = 1) %>%
  visEdges(smooth=FALSE) %>% 
  visOptions(manipulation = TRUE)


#####################################################
# create Ontology graph for CTDasRDFOWL (ofInterest_02)
#####################################################


endpoint <- "http://localhost:5820/CTDasRDFOWL/query"
queryOnt = paste0("SELECT * WHERE {?predicate  rdfs:domain ?domain 
                  OPTIONAL {?predicate rdfs:range ?range}}")
qd <- SPARQL(endpoint, queryOnt, ns=prefix)
triplesDf <- qd$results

ofInterst=c("study:Study",
            "skos:prefLabel",
            "study:actualPopulationSize",
            "study:adaptiveDesign",
            "study:addOn",
            "study:ageGroup",
            "study:blinding",
            "study:controlType",
            "study:hasTitle",
            "study:longTitle",
            "study:interventionModel",
            "study:interventionType",
            "study:InvestigationalSubstance",
            "study:isAddOnStudy",
            "study:MaximumSubjectAge",
            "study:MinimumSubjectAge",
            "study:narms",
            "study:plannedPopulationSize",
            "study:PrimaryObjective",
            "study:PrimaryOutcomeMeasure",
            "study:randomizedTrial",
            "study:SecondaryObjective",
            "study:sexGroup",
            "study:Sponsor",
            "study:studyDrug",
            "study:StudyIdentifier",
            "study:StudyPopulation",
            "study:StudyRegistryIdentifier",
            "study:studyType",
            "study:Title",
            "study:trialPhase",
            "study:trialType")

triplesDf <- triplesDf[(triplesDf$domain %in% ofInterst & triplesDf$range %in% ofInterst) | 
                           (triplesDf$domain %in% ofInterst & triplesDf$predicate %in% ofInterst),]

initLists()
# include triples
for (row in 1:nrow(triplesDf)) {
    if (!is.na(triplesDf$domain[row]) && !is.na(triplesDf$range[row]) && !is.na(triplesDf$predicate[row])){
        addToGraph(triplesDf$domain[row],triplesDf$range[row],triplesDf$predicate[row])  
    }
}

formatList()

visNetwork(nodesListXX, edgesListXX, width= "100%", height=1100) %>%
    visIgraphLayout(layout = "layout_nicely",
                    physics = FALSE) %>%
    visIgraphLayout(avoidOverlap = 1) %>%
    visEdges(smooth=FALSE) %>% 
    visOptions(manipulation = TRUE)


#####################################################
# create Ontology graph for CTDasRDFOWL (ofInterest_03)
#####################################################


endpoint <- "http://localhost:5820/CTDasRDFOWL/query"
queryOnt = paste0("SELECT * WHERE {?predicate  rdfs:domain ?domain 
                  OPTIONAL {?predicate rdfs:range ?range}}")
qd <- SPARQL(endpoint, queryOnt, ns=prefix)
triplesDf <- qd$results

ofInterst=c("study:Study","study:StudyActivity")

triplesDf <- triplesDf[(triplesDf$domain %in% ofInterst & triplesDf$range %in% ofInterst) | 
                           (triplesDf$domain %in% ofInterst & triplesDf$predicate %in% ofInterst),]

initLists()
# include triples
for (row in 1:nrow(triplesDf)) {
    if (!is.na(triplesDf$domain[row]) && !is.na(triplesDf$range[row]) && !is.na(triplesDf$predicate[row])){
        addToGraph(triplesDf$domain[row],triplesDf$range[row],triplesDf$predicate[row])  
    }
}

formatList()

visNetwork(nodesListXX, edgesListXX, width= "100%", height=1100) %>%
    visIgraphLayout(layout = "layout_nicely",
                    physics = FALSE) %>%
    visIgraphLayout(avoidOverlap = 1) %>%
    visEdges(smooth=FALSE) %>% 
    visOptions(manipulation = TRUE)

#####################################################
# create Ontology graph for Cutoff mapping
#####################################################

initLists()
addToGraph("study:Study","study:DataCutoff","study:hasStudyActivity")
addToGraph("study:DataCutoff","xsd:string","study:activityDescription")
addToGraph("study:DataCutoff","time:instant","study:hasDate")  
formatList()

visNetwork(nodesListXX, edgesListXX, width= "100%", height=1100) %>%
    visIgraphLayout(layout = "layout_nicely",
                    physics = FALSE) %>%
    visIgraphLayout(avoidOverlap = 1) %>%
    visEdges(smooth=FALSE) %>% 
    visOptions(manipulation = TRUE)


#####################################################
# create content graph for CTDasRDFSMS for cdiscpilot01-protocol.ttl
# prerequisite: delete all data from CTDasRDFSMS:
#     DELETE{?s ?p ?o} WHERE{?s ?p ?o}
#     then include data by reading cdiscpilot01-protocol.ttl into CTDasRDFSMS
#####################################################

# Endpoint
endpoint <- "http://localhost:5820/CTDasRDFSMS/query"
queryOnt = paste0("SELECT * WHERE {?subject ?predicate ?object}")
qd <- SPARQL(endpoint, queryOnt, ns=prefix)
triplesDf <- qd$results


initLists()

# include triples
for (row in 1:nrow(triplesDf)) {
  # exclude na and missings
  if (!is.na(triplesDf$subject[row]) && !is.na(triplesDf$predicate[row]) && !is.na(triplesDf$object[row])  ){
    if ( triplesDf$subject[row] != "" && triplesDf$predicate[row] != "" && triplesDf$object[row] != "" &&
         # exclude owl prefixes in predicate or object
         (!grepl("owl:",triplesDf$predicate[row]) && !grepl("owl:",triplesDf$object[row])) &&
         # exclude rdfs:subClassOf and rdf:type
         (triplesDf$predicate[row] != "rdfs:subClassOf" && triplesDf$predicate[row] != "rdf:type"))
      {
      addToGraph(triplesDf$subject[row],triplesDf$object[row],triplesDf$predicate[row])    
    }
  }
}

formatList()

visNetwork(nodesListXX, edgesListXX, width= "100%", height=1100) %>%
  visIgraphLayout(layout = "layout_nicely",
                  physics = FALSE) %>%
  visIgraphLayout(avoidOverlap = 1) %>%
  visEdges(smooth=FALSE) %>% 
  visOptions(manipulation = TRUE)

#####################################################
# create content graph for CTDasRDFOWL for code.ttl
#####################################################

# Endpoint
endpoint <- "http://localhost:5820/CTDasRDFOWL/query"
queryOnt = paste0("SELECT * WHERE {?subject ?predicate ?object} Limit 300")
qd <- SPARQL(endpoint, queryOnt, ns=prefix)
triplesDf <- qd$results


initLists()

# include triples
for (row in 1:nrow(triplesDf)) {
  if (!is.na(triplesDf$subject[row]) && !is.na(triplesDf$predicate[row]) && !is.na(triplesDf$object[row])  ){
    if ( triplesDf$subject[row] != "" && triplesDf$predicate[row] != "" && triplesDf$object[row] != "" &&
         (!grepl("owl:",triplesDf$predicate[row]) && !grepl("owl:",triplesDf$object[row])
          && !grepl("_:",triplesDf$object[row]) && !grepl("_:",triplesDf$subject[row]) )){
      addToGraph(triplesDf$subject[row],triplesDf$object[row],triplesDf$predicate[row],
                 listUniquesPrefixes = c())    
    }
  }
}

formatList()

visNetwork(nodesListXX, edgesListXX, width= "100%", height=1100) %>%
  visIgraphLayout(layout = "layout_nicely",
                  physics = FALSE) %>%
  visIgraphLayout(avoidOverlap = 1) %>%
  visEdges(smooth=FALSE) %>% 
  visOptions(manipulation = TRUE)