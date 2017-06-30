###############################################################################
# FILE: buildRDF-Driver.R
# DESC: Master program for building the TTL file for the SDTM domains from 
#        the CDISCPILOT01 example data.
#       Loads all required libraries.
#       Imports the various domains from XPT files
#       Imputes data needed for testing before calling the process files that 
#          create the individual triples.  
#       Calls functions for unique URI creation (eg: Dates)
#       Writes out TTL.
# REQ : Apache Jena 3.+0.1: For riot, installed and avail at system path if 
#           valdiation called
# SRC : N/A
# IN  :  prefixes.csv - prefixes and their namespaces
#        Calls to other scripts for code, functions, data import.
# OUT : data/rdf/cdiscpilot01-R.TTL
#       data/rdf/customterminology-R.TTL 
#       data/rdf/code-R.TTL 
# NOTE: Validation of the resulting TTL files with Apache Jenna riot
#        Later cross check with CompareTTL.R
# TODO: Move imputations for DS, VS to separate .R scipts.
###############################################################################
library(rrdf)
library(Hmisc)
library(plyr)  # plyr must load prior to dplyr!
# library(dplyr)  #DEL not currently in use?
library(car)   # Recoding of values for SDTM codes, etc. Order of lib is imp here.
library(reshape2)  # decast and others...

# Version of COde/output. Triple created in graphMeta.R
version <- "0.0.1"

# Subset for prototype development. 
maxPerson = 6; # Used in DM_process.R 

# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

# Configuration: List of prefixes
allPrefix <- "data/config/prefixes.csv"  # List of prefixes for the resulting TTL file

# Output filename and location
outFileMain   = "data/rdf/cdiscpilot01-R.TTL"
outFileCustom = "data/rdf/customterminology-R.TTL"
outFileCode   = "data/rdf/code-R.TTL"
# outFile=paste0("data/rdf/", outFilename)

# Initialize. Includes OWL, XSD, RDF by default.
cdiscpilot01  = new.rdf()  # The main datafile. Later change name to 'mainTTL" or similar
custom = new.rdf()  # customterminology-R.ttl
code   = new.rdf()  # code-R.ttl
#------------------------------------------------------------------------------
# Build Prefixes
#   Add prefixes to files cdiscpilot01-R.TTL, customterminology-R.ttl, 
#      code-R.ttl
#   For simplicity, one set of prefixes is built for all files. All output files
#     have the same list of prefixes for both code simplicity consistency.
#------------------------------------------------------------------------------
prefixes <- as.data.frame( read.csv(allPrefix,
    header=T,
    sep=',' ,
    strip.white=TRUE))
for (i in 1:nrow(prefixes)) {
    # Prefixes to cdiscpilot01-R.TTL
    add.prefix(cdiscpilot01,
        prefix=as.character(prefixes[i,"prefix"]),
        namespace=as.character(prefixes[i, "namespace"])
    )
    # Prefixes to customterminology-R.ttl
    add.prefix(custom,
        prefix=as.character(prefixes[i,"prefix"]),
        namespace=as.character(prefixes[i, "namespace"])
    )
    # Prefixes to code-R.ttl file
    add.prefix(code,
        prefix=as.character(prefixes[i,"prefix"]),
        namespace=as.character(prefixes[i, "namespace"])
    )

    # Create uppercase prefix names for use in add() in triples.R
    assign(paste0("prefix.",toupper(prefixes[i, "prefix"])), prefixes[i, "namespace"])
}

#-- Data triples creation -----------------------------------------------------
# Graph Metadata
source('R/graphMeta.R')

# Misc funt. : data import, person ID, etc. 
source('R/misc_F.R')

#------------------------------------------------------------------------------
# Fragment Creation Functions for the domains
# Functions to create URI fragments for Dates and other categories that are shared URIs 
# Eg: Date_1, AgeMeasurement_3
source('R/createFrag_F.R')


#------------------------------------------------------------------------------
# Imports 
#------------------------------------------------------------------------------
# DM 
dm <- readXPT("dm")
# For testing, keep only the first (maxPerson) patients in DM
dm <- head(dm, maxPerson)  # maxPerson set above
source('R/DM_impute.R')     # Create values needed for testing. 

# VS
vs <- readXPT("vs")
source('R/VS_impute.R')  # restructure and impute, and subset for dev purposes

#------------------------------------------------------------------------------
# xx DOMAIN
#   Additional domains to be added.
#------------------------------------------------------------------------------


# Create the date translation table from all dates across domains
#   Needed by both DM_impute and in later code where DM is processed.
dateDict<-createDateDict()    



# Create fragment dictionaries that cross domains
#   Called after all contributing  domains available, since some fragment values 
#      eg: dates, cross multiple domains.
source('R/DM_frag.R')  # requires import of VS to get dates from VS that are used as part of DateDict/dateFrag creation

#------------------------------------------------------------------------------
# Domain Processing
#------------------------------------------------------------------------------
#---- DM DOMAIN
#  NOTE: DM  MUST be processd first: Creates data required in later steps.
#        DM MUST BE Run to create personNUm that is used when processing other domains.
#        SUPPDM can be omitted during development steps.

source('R/DM_process.R')
source('R/SUPPDM_process.R')


#TW source('R/VS_process.R')

#---- X DOMAIN  Additional Domains will be added here.......

#------------------------------------------------------------------------------
# OUTPUT
#   Write out the TTL files
#------------------------------------------------------------------------------
cdiscpilot01 = save.rdf(cdiscpilot01,  filename=outFileMain,   format="TURTLE")   

#------------------------------------------------------------------------------
# VALIDATION
#   Always a good idea to validate, friendo.
#------------------------------------------------------------------------------
system(paste('riot --validate ', outFileMain),
    show.output.on.console = TRUE)
