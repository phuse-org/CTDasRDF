#______________________________________________________________________________
# FILE: SourceFileGraph-Data.R 
# DESC: Number of triples in each .TTL and RDF project file. 
#       Later used for plotting in xxx.html
# SRC : 
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE:  
#         
# TODO: Add queries to determine number of links between each file?
#______________________________________________________________________________
library(redland)
library(stringr)
library(plyr)
setwd("C:/_github/CTDasRDF")
       

sourceFiles <- read.table(header=T, text='
file                       label          type        source
bridg-4-1-1.ttl            BRIDG-4.1.1    ontology    cdisc
cdiscpilot01.ttl           CDISCPilot01   data        project
cdiscpilot01-protocol.ttl  Protocol       ontology    project
code.ttl                   Code           data        project
sdtm.ttl                   SDTM           ontology    project   
sdtm-1-3.ttl               SDTM-1.3       ontology    cdisc
sdtm-cd01p.ttl             SDTM-cd01p     data        project
sdtm-cdisc01.ttl           sdtm-cdisc01   data        project
sdtmig-3-1-3.ttl           sdtmig-3.1.3   ontology    cdisc
study.ttl                  Study          data        project
time.ttl                   Time           ontology    external  
ct-schema.rdf              CT-Schema      ontology    project
meta-model-schema.rdf      Meta-Model     ontology    project
sdtm-terminology.rdf       SDTM-Term      data        cdisc
  ')

write.csv(sourceFiles, file="C:/temp/components.csv")


# sourceFiles <-sourceFiles[1,]


sourceFiles$tripleCount <- NA

#TODO Change to ddply solution
for (i in 1:nrow(sourceFiles))
{
  world <- new("World")
  storage <- new("Storage", world, "hashes", name="", options="hash-type='memory'")
  model <- new("Model", world=world, storage, options="")

  
  if (grepl(".ttl", sourceFiles[i,'file'])) {
    parser <- new("Parser", world, name = 'turtle', mimeType = 'text/turtle')
  }
  else if (grepl(".rdf", sourceFiles[i,'file'])) {
    parser <- new("Parser", world, name = 'rdfxml', mimeType = 'application/rdf+xml')
  }
  
  redland::parseFileIntoModel(parser, world, paste0("data/rdf/", sourceFiles[i,"file"]), model)
  
  # Construct and execute the query
  queryString <- 'SELECT (COUNT(?s) as ?sCount)  WHERE { ?s ?p ?o }'

  query <- new("Query", world, queryString, base_uri=NULL, query_language="sparql", query_uri=NULL)
    queryResult <- executeQuery(query, model)
    countResult <- getNextResult(queryResult)
    message(paste("---Query Result:", countResult))
    # ERROR here; the right numbe ris in countResult, but the result is not gettinb back into the dataframe. Only the last value?
    #   makes it into the dataframe. 
    sourceFiles[i,"tripleCount"] <- as.numeric(str_extract(unlist(countResult), "\\d+"))  # Assign out to global scope

}
# JSON output ----

