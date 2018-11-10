###############################################################################
# FILE: ListCustomInstanceClasses.R
# DESC: List the classes customterminoloty.TTL that are created from instance 
#         data. These must be created by the R Script process. The other
#         classes are created in Protege/Topbraid
# SRC : 
# IN  : customterminology.TTL
# OUT : 
# REQ : rrdf
# SRC : 
# NOTE: Used during building of TTL files from R
# TODO: 
###############################################################################
library(redland)
setwd("C:/_github/CTDasRDF")
       
# Setup the file read
world <- new("World")
storage <- new("Storage", world, "hashes", name="", options="hash-type='memory'")
model <- new("Model", world=world, storage, options="")
parser <- new("Parser", world, name = 'turtle', mimeType = 'text/turtle')


# Query
queryString <- '
PREFIX cdiscpilot01: <<http://w3id.org/phuse/cdiscpilot01#>
PREFIX study: <http://w3id.org/phuse/study#>
SELECT ?dateFrag ?dateVal
WHERE { ?date study:dateTimeInXSDString ?dateVal .
BIND (strafter(str(?date), ".ttl#" ) AS ?dateFrag) 
# BIND (STRBEFORE(?dateString, "http" ) AS ?dateVal) .
} ORDER BY ?dateVal '
query <- new("Query", world, queryString, base_uri=NULL, query_language="sparql", query_uri=NULL)
queryResult <- executeQuery(query, model)


# Ontology Dates ----
redland::parseFileIntoModel(parser, world, "data/rdf/cdiscpilot01.ttl", model)
query <- new("Query", world, queryString, base_uri=NULL, query_language="sparql", query_uri=NULL)
queryResult <- executeQuery(query, model)

# Need to wrap the getNextResult into a loop that runs until NULL is returned.
# Posted this example to https://github.com/ropensci/redland-bindings/issues/55  asking for clarification
#   if this is the way to do it or not.  29Sep17
queryResults = NULL;
repeat{
  nextResult <- getNextResult(queryResult)
  queryResults <- rbind(queryResults, data.frame(nextResult))
  if(is.null(nextResult)){
    break
  }
}
ontDates <- queryResults
# Post processing
ontDates$dateFrag<-gsub('"', '', ontDates$dateFrag)
ontDates$dateVal<-gsub('"', '', ontDates$dateVal)
ontDates$dateVal<-gsub("\\^+.*", "", ontDates$dateVal, perl=TRUE)


# R Dates ----
redland::parseFileIntoModel(parser, world, "data/rdf/cdiscpilot01-R.ttl", model)
query <- new("Query", world, queryString, base_uri=NULL, query_language="sparql", query_uri=NULL)
queryResult <- executeQuery(query, model)

# Need to wrap the getNextResult into a loop that runs until NULL is returned.
# Posted this example to https://github.com/ropensci/redland-bindings/issues/55  asking for clarification
#   if this is the way to do it or not.  29Sep17
queryResults = NULL;
repeat{
  nextResult <- getNextResult(queryResult)
  queryResults <- rbind(queryResults, data.frame(nextResult))
  if(is.null(nextResult)){
    break
  }
}
rDates <- queryResults
# Post processing
rDates$dateFrag<-gsub('"', '', rDates$dateFrag)
rDates$dateVal<-gsub('"', '', rDates$dateVal)
rDates$dateVal<-gsub("\\^+.*", "", rDates$dateVal, perl=TRUE)




rOntDates <- merge(rDates, ontDates, by.x="dateVal", by.y="dateVal", all.x=TRUE, all.y=TRUE)


rOntDates <- rename(rOntDates, c(dateFrag.x = "R", dateFrag.y = "Ont"))

# Old comparison here.
#ontTriples = as.data.frame(sparql.rdf(ontSource, query))
#ontTriples <-ontTriples[!duplicated(ontTriples), ]  # remove dupes

#rTriples = as.data.frame(sparql.rdf(rSource, query))
#rTriples <- rTriples[!duplicated(rTriples), ]  # remove dupes

#dateComp <- merge(rTriples, ontTriples, by.x="dateVal", by.y="dateVal", all.x=TRUE, all.y=TRUE)

#dateComp <- rename(dateComp, c(dateURI.x = "R", dateURI.y = "Ontology"))


#library(xlsx)
#write.xlsx(dateComp, "data/validation/DateComp.xlsx")

