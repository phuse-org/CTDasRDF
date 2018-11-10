###############################################################################
# FILE: CTDasRDF/r/querypersonTriples.R
# DESC: Obtain the Predicates and Objects attached 
#       directly to Person_1.
#       Example 1: Virtuoso triple store running on localhost
#       Example 2: Local TTL file
# IN  : http://localhost:8890/sparql  OR .TTL file
# OUT : dataframes
# REQ : rrdf
# NOTE:
# TODO: 
###############################################################################
library(rrdf)

# Example: Query Virtuoso Triple Store ----
#  Assumes triplestore running on localhost on port 8890
endpoint = "http://localhost:8890/sparql"

query = 'PREFIX cd01p: <http://w3id.org/phuse/cd01p#>
PREFIX cdiscpilot01: <<http://w3id.org/phuse/cdiscpilot01#>#>
PREFIX skos:  <http://www.w3.org/2004/02/skos/core#>
PREFIX study: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#>

SELECT ?s ?p ?o
FROM <http://localhost:8890/CTDasRDF-R>
WHERE{
cdiscpilot01:Person_1 ?p ?o
BIND ("cdiscpilot01:Person_1" as ?s)
} LIMIT 100'

personTriples_Virt <- as.data.frame(sparql.remote(endpoint, query))


# Example: Query StardogTriple Store ----
#  Assumes triplestore running on localhost on port 8890
endpoint = "http://localhost:5820/CTDasRDF-R/query"

query = 'PREFIX cd01p: <http://w3id.org/phuse/cd01p#>
PREFIX cdiscpilot01: <<http://w3id.org/phuse/cdiscpilot01#>#>
PREFIX skos:  <http://www.w3.org/2004/02/skos/core#>
PREFIX study: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#>

SELECT *
WHERE{
 ?s ?p ?o
} LIMIT 100'

personTriples_Virt <- as.data.frame(sparql.remote(endpoint, query))



# Example: Query TTL file CDISCPILOT01-R.TTL ----
#   Change directory if used outside of the C:/_gitHubShared/CTDasRDF workarea
#   The only difference in the query is removal of the FROM statement.

setwd("C:/_gitHubShared/CTDasRDF")

sourceTTL = load.rdf("data/rdf/cdiscpilot01-R.ttl", format="N3")

queryTTL = 'PREFIX cd01p: <http://w3id.org/phuse/cd01p#>
PREFIX cdiscpilot01: <<http://w3id.org/phuse/cdiscpilot01#>#>
PREFIX skos:  <http://www.w3.org/2004/02/skos/core#>
PREFIX study: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#>
SELECT ?s ?p ?o
WHERE{
cdiscpilot01:Person_1 ?p ?o
BIND ("cdiscpilot01:Person_1" as ?s)
} LIMIT 100'

personTriples_TTL = as.data.frame(sparql.rdf(sourceTTL, queryTTL))