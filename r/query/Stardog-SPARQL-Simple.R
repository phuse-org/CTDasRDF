###############################################################################
# FILE: Stardog-SPARQL-Simple.R
# DESC: Simple query to Stardog using SPARQL pkg 
# SRC : 
# IN  : triplestore database CTDasRDF-R
# OUT : 
# REQ : Stardog running: 1. on port  5820
#       2. with --disable-security option during start
# SRC : 
# NOTE:
# TODO: 
###############################################################################
library(SPARQL)

# Query StardogTriple Store ----
endpoint <- "http://localhost:5820/CTDasRDF-R/query"

query <- "SELECT *
  WHERE{
    ?s ?p ?o
  } LIMIT 100"

# Or: ready prefixes in from prefixes.csv project file.
prefix <- c("cd01p",        "http://w3id.org/phuse/cd01p",
            "cdiscpilot01", "<http://w3id.org/phuse/cdiscpilot01#>#",
            "code",         "<http://w3id.org/phuse/code#>#",
            "custom",       "<http://w3id.org/phuse/custom#>",
            "owl",          "http://www.w3.org/2002/07/owl#",
            "rdf",          "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            "rdfs",         "http://www.w3.org/2000/01/rdf-schema#",
            "sdtmterm",     "http://w3id.org/phuse/sdtmterm#",
            "skos",         "http://www.w3.org/2004/02/skos/core#",
            "study",        "http://w3id.org/phuse/study#",
            "time",         "http://www.w3.org/2006/time#")

qd <- SPARQL(endpoint, query, ns=prefix)
resultsDF <- qd$results
resultsDF