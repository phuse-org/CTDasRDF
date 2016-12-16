###############################################################################
# FILE : CompTTL.R
# DESCR: Compare TTL files created with R vs those from AO
# SRC  : 
# KEYS : 
# NOTES: 
#        
# INPUT: 
#      : 
# OUT  : 
# REQ  : 
# TODO : 
###############################################################################

require(rrdf)
require(dplyr) # for compare of dataframes using anti_join
# library(plyr)  # for rename

# For use with local TTL file:
setwd("C:/_gitHub/SDTM2RDF")

TWSource = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")

AOSource = load.rdf("data/rdf/Armando-16DEC16/cdiscpilot01.TTL", format="N3")


# Use the same query on both data sources.
# Select all the information associated with Obs113
#  All triples directly attached to Person_<n>  
# 
query = 'PREFIX cdiscpilot01: <http://example.org/cdiscpilot01#>
SELECT ?o 
WHERE { cdiscpilot01:Person_1 ?p ?o . 
}'

TWTriples = as.data.frame(sparql.rdf(TWSource, query))
AOTriples = as.data.frame(sparql.rdf(AOSource, query))

problems<-anti_join(TWTriples, AOTriples)
problems

