###############################################################################
# FILE: codeOntClasses.R
# DESC: 
# SRC : code.ttl - file created by AO
# IN  : 
# OUT : 
# REQ : code.ttl uploaded to local Virtuoso Endpoint
# SRC :  
# NOTE: THe first filter selects only direct subclasses as desdribed here:
#        https://stackoverflow.com/questions/23699246/how-to-query-for-all-direct-subclasses-in-sparql
# TODO: 
###############################################################################
library(rrdf)
library(plyr)
setwd("C:/_github/SDTMasRDF/data/rdf")
# codeData = load.rdf("code.TTL", format="N3")
endpoint = "http://localhost:8890/sparql"


query = 'PREFIX code: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/code#> 
prefix : <http://www.semanticweb.org/administrator/ontologies/2014/7/untitled-ontology-9#>
PREFIX custom: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/custom#> 
prefix owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX sdtm-terminology: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/sdtm-terminology#> 
PREFIX time: <http://www.w3.org/2006/time#> 

PREFIX time: <http://www.w3.org/2006/time#> 
PREFIX custom: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/custom#Visit>
SELECT ?parent ?relation ?child
FROM <http://localhost:8890/CODE>
WHERE
 {
    ?child rdfs:subClassOf ?parent
   FILTER(REGEX(STR(?parent), "code"))  
   FILTER(!(REGEX(STR(?parent), "spin")))

    BIND ("subClassOf" AS ?relation)
}
ORDER BY ?parent

'
classes = sparql.remote(endpoint, query)

# classes = as.data.frame(sparql.rdf(codeData, query))
# write.table(classes, "classes.txt")

# rename(classes, c)


