#______________________________________________________________________________
# FILE: r/vis/MedDRALTtoSOCVis-app/global.R
# DESC: MedDRA visualization from LT to SOC 
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: Bring in libraries, functions (IRItoPrefix), set endpoint, etc.
# TODO: 
#______________________________________________________________________________
library(collapsibleTree)
library(dplyr)  # recode
library(SPARQL)

setwd("C:/_github/CTDasRDF/r")
source("Functions.R")  # IRItoPrefix()

# Query StardogTriple Store ----
endpoint <- "http://localhost:5820/MedDRA/query"

# Define the namespaces
namespaces <- c(
'meddra', '<https://w3id.org/phuse/meddra#>',
'skos',   '<http://www.w3.org/2004/02/skos/core#>',
'rdf',    '<http://www.w3.org/1999/02/22-rdf-syntax-ns#>',
'rdfs',   '<http://www.w3.org/2000/01/rdf-schema#>',
'xsd',    '<http://www.w3.org/2001/XMLSchema#>'
)
