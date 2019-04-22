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