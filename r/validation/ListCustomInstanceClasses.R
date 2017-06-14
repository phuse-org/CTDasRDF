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
library(rrdf)
library(reshape)   # melt
# For use with local TTL file:
setwd("C:/_gitHub/CTDasRDF")

ontSource = load.rdf("data/rdf/customterminology.TTL", format="N3")
query = 'prefix arg: <http://spinrdf.org/arg#>                                                
prefix code: <https://github.com/phuse-org/CTDasRDF/blob/master/data/rdf/code#> 
prefix custom: <https://github.com/phuse-org/CTDasRDF/blob/master/data/rdf/custom#> 
prefix owl: <http://www.w3.org/2002/07/owl#>                                        
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>                           
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>                                
prefix skos: <http://www.w3.org/2004/02/skos/core#>                                 
prefix sp: <http://spinrdf.org/sp#>                                                  
prefix spin: <http://spinrdf.org/spin#>                                              
prefix spl: <http://spinrdf.org/spl#>                                                
prefix xsd: <http://www.w3.org/2001/XMLSchema#>                                      
SELECT  ?class ?subclass
WHERE { ?class rdfs:subClassOf ?subclass .}
'

ontTriples = as.data.frame(sparql.rdf(ontSource, query))


classes <- melt(ontTriples, measure.vars = c("class", "subclass"))

classes <- data.frame(classes[,"value"])
# remote dupes
classes <- data.frame(classes[!duplicated(classes), ])  # is DF here.

# Rename column
names(classes)[names(classes) == 'classes..duplicated.classes....'] <- 'class'


# Get list of those that are created from rdf frags in the data. custom: prefix with
#   '_' 
# These are the ones you need to create in R,  others are created in Protege/TopBraid.
# keep the custom: classes

classes <- subset(classes, grepl("custom:\\S+_\\S+", class, perl=TRUE))

