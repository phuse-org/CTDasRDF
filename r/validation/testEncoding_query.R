###############################################################################
# FILE:  testEncoding.R
# DESC:  Test URL Encoding
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: test:Ethnic_HISPANIC\%20OR\%20LATINO ?p ?o . 
# TODO: 
###############################################################################
library(SPARQL)
ep = "http://localhost:5820/CTDasRDF/query"
query = paste0('
prefix test: <http://www.example.org/test#> 
SELECT ?p ?o
WHERE
{
   test:Ethnic_HISPANIC%20OR%20LATINO ?p ?o .
}'
)

# Query results dfs ----  
qr <- SPARQL(url=ep, query=query)
#--------------------
triples <- qr$results

