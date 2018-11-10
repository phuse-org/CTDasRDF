###############################################################################
# FILE: Stardog-SPARQL-examples.R
# DESC: some example queries for Stardog using SPARQL pkg 
# SRC : 
# IN  : triplestore database CTDasRDFSMS
# OUT : 
# REQ : Stardog running: 
#         1. on port  5820
#         2. with --disable-security option during start
#       When behind proxy, reset proxy settings, 
# SRC : 
# NOTE:
# TODO: 
# DATE: 2018-08-23
# BY  : KG
###############################################################################


###################
# general setup
###################

#install.packages("SPARQL")   #required once to insall packages
library(SPARQL)

# Query StardogTriple Store ----
endpoint <- "http://localhost:5820/CTDasRDFSMS/query"

prefix <- c("cd01p",        "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01-protocol.ttl",
            "cdiscpilot01", "<http://w3id.org/phuse/cdiscpilot01#>#",
            "code",         "<http://w3id.org/phuse/code#>#",
            "custom",       "<http://w3id.org/phuse/custom#>",
            "owl",          "http://www.w3.org/2002/07/owl#",
            "rdf",          "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            "rdfs",         "http://www.w3.org/2000/01/rdf-schema#",
            "sdtmterm",     "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/sdtm-terminology.rdf#",
            "skos",         "http://www.w3.org/2004/02/skos/core#",
            "study",        "http://w3id.org/phuse/study#",
            "time",         "http://www.w3.org/2006/time#")

# if you get an error like: Error: 1: AttValue: " or ' expected, then remove your proxy settings, e.g.
#Sys.setenv(http_proxy="")
#Sys.setenv(https_proxy="")

###################
# try some queries
###################

# investigate triples, only the first 10
query <- "SELECT * WHERE{?s ?p ?o} LIMIT 10"
qd <- SPARQL(endpoint, query, ns=prefix)
resultsDF <- qd$results
resultsDF


# Number of triples in the CTDasRDF graph
query <- "SELECT (COUNT(*) as ?count)
          WHERE {
            ?s ?p ?o .
          }"
qd <- SPARQL(endpoint, query, ns=prefix)
resultsDF <- qd$results
print(paste("There are ", resultsDF," triples in the store."))

# Which classes are used?
query <- "SELECT DISTINCT ?t 
WHERE {
  ?s rdf:type ?t
}"
qd <- SPARQL(endpoint, query, ns=prefix)
resultsDF <- qd$results
print("The following classes are used:")
as.character(resultsDF)


# Which properties are used and how often?
query <- "SELECT ?p (COUNT(?p) AS ?count) 
          WHERE {
            ?s ?p ?o
          }
          GROUP BY ?p
          ORDER BY DESC(?count)"
qd <- SPARQL(endpoint, query, ns=prefix)
resultsDF <- qd$results
print("The following properties are used count times:")
resultsDF

# Which classes are used and how often?
query <- "SELECT ?t (COUNT(?t) AS ?count) 
          WHERE {
            ?s rdf:type ?t
          }
          GROUP BY ?t
          ORDER BY DESC(?count)"
qd <- SPARQL(endpoint, query, ns=prefix)
resultsDF <- qd$results
print("The following classes are used count times:")
resultsDF

# Classes: List a few example instances of a particular class
query <- "SELECT ?s 
          WHERE {
            ?s rdf:type study:VisitDate
          }
          LIMIT 10"
qd <- SPARQL(endpoint, query, ns=prefix)
resultsDF <- qd$results
print("The following instances of study:VisitDate are available:")
as.character(resultsDF)


# triples that use the study:hasDate predicate.
query <- 'SELECT ?s ?p ?o
          WHERE {
            ?s study:hasDate ?o
            BIND("study:hasDate" AS ?p)
          }'
qd <- SPARQL(endpoint, query, ns=prefix)
resultsDF <- qd$results
print("objects are connected through study:hasDate:")
resultsDF

