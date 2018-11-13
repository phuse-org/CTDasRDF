###############################################################################
# FILE: CTDasRDF/r/graphMetadata.R
# DESC: Obtain the graph metadata from Virtuoso, originally created in
#       cdiscpilot01-R.TTL
# IN  : http://localhost:8890/sparql
# OUT : dataframe
# REQ : rrdf
# NOTE:
# TODO: 
###############################################################################
library(rrdf)

endpoint = "http://localhost:8890/sparql"

query = 'PREFIX cdiscpilot01: <http://w3id.org/phuse/cdiscpilot01#>
SELECT ?s ?p ?o
FROM <http://localhost:8890/CTDasRDF-R>
WHERE{
cdiscpilot01:sdtm-graph ?p ?o
BIND ("cdiscpilot01:sdtm-graph" as ?s)
} LIMIT 100'

graphMeta <- as.data.frame(sparql.remote(endpoint, query))

head(graphMeta)
