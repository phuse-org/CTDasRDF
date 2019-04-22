#______________________________________________________________________________
# FILE: r/validation/compTriplesTTL-appp/global.R
# DESC: Compare triples in two TTL files, starting at a named Subject.
#         Used to compare instance data created in the Ontology approach with
#         data converted using R
# SRC :
# IN  : TTL files in a local folder. Typically /data/rdf
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
#______________________________________________________________________________
library(plyr)    #  rename
library(dplyr)   # anti_join. Must load dplyr AFTER plyr!!
library(reshape) #  melt
library(rrdf)
library(shiny)
setwd("C:/_gitHub/CTDasRDF/data/rdf")

prefixes <-"PREFIX cd01p: <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/cd01p#>
PREFIX cdiscpilot01: <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/cdiscpilot01#>
PREFIX code:  <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/code#>
PREFIX country: <http://psi.oasis-open.org/iso/3166/#>
PREFIX custom: <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/custom#>
PREFIX meddra: <https://w3id.org/phuse/meddra#>
prefix owl:   <http://www.w3.org/2002/07/owl#>
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX sdtm: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/sdtm#>
PREFIX sdtm-terminology: <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/sdtm-terminology#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sp: <http://spinrdf.org/sp#> 
PREFIX spin: <http://spinrdf.org/spin#> 
PREFIX study:  <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/study#>
PREFIX time:  <http://www.w3.org/2006/time#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> "