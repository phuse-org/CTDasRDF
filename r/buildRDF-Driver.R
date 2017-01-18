###############################################################################
# FILE: buildRDF-Driver.R
# DESC: Master program for building the TTL file for the SDTM domains from 
#        the CDISCPILOT01 example data.
#       Loads all required libraries.
#       Writes out TTL.
# REQ : Apache Jena 3.0.1: For riot, installed and avail at system path if 
#           valdiation called
# SRC : N/A
# IN  :  prefixes.csv - prefixes and their namespaces
#        Calls to other scripts for code, functions, data import.
# OUT : data/rdf/cdiscpilot01.TTL
# NOTE: Validation of the resulting TTL structure with Apache Jenna riot
#        Later cross check with CompareTTL.R
# TODO: 
#
###############################################################################
library(rrdf)
library(Hmisc)
# library(dplyr)
library(plyr)
library(car)   # Recoding of values for SDTM codes, etc. Order of lib is imp here.

# Version of COde/output. Triple created in graphMeta.R
version <- "0.0.1"

# Subset down for prototype development. 
maxPerson = 6; # Used in processDM.R 

# Set working directory to the root of the work area
setwd("C:/_github/SDTM2RDF")

# Configuration: List of prefixes
sourcePrefix<-"data/config/prefixes.csv"  # List of prefixes for the resulting TTL file

# Output filename and location
outFilename = "cdiscpilot01.TTL"
outFile=paste0("data/rdf/", outFilename)

# Initialize. Includes OWL, XSD, RDF by default.
store = new.rdf()  

#-- Build the Prefixes from the CSV file
prefixes <- as.data.frame( read.csv(sourcePrefix,
    header=T,
    sep=',' ,
    strip.white=TRUE))
for (i in 1:nrow(prefixes)) {
    add.prefix(store,
        prefix=as.character(prefixes[i,"prefix"]),
        namespace=as.character(prefixes[i, "namespace"])
    )
    # Create uppercase prefix names for use in add() in triples.R
    assign(paste0("prefix.",toupper(prefixes[i, "prefix"])), prefixes[i, "namespace"])
}

#-- Data triples creation -----------------------------------------------------
# Graph Metadata
source('R/graphMeta.R')

# Import and indexing Functions (Called during domain processing) 
source('R/dataImportFnts.R')

#-- DOMAIN PROCESSING ---------------------------------------------------------
#---- DM DOMAIN
#  NOTE: DM  MUST be processd first: Creates data required in later steps.
source('R/processDM.R')

#---- VS DOMAIN
source('R/processVS.R')

#---- X DOMAIN  Additional Domains will be added here.......

##########
# Output #
###############################################################################
store = save.rdf(store, filename=outFile, format="TURTLE")

# Validate TTL file. Always a good idea to validate, friendo.
system(paste('riot --validate ', outFile),
    show.output.on.console = TRUE)