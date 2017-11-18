#______________________________________________________________________________
# FILE: buildRDF-Driver.R
# DESC: Master program for building the TTL file for the SDTM domains from 
#        the CDISCPILOT01 example data.
#       Loads all required libraries.
#       Imports the various domains from XPT files
#       Imputes data needed for testing before calling the process files that 
#          create the individual triples.  
#       Calls functions for unique URI creation (eg: Dates)
#       Writes out TTL.
# REQ : Apache Jena 3.+0.1: For riot, installed and avail at system path  
# SRC : N/A
# IN  :  prefixes.csv - prefixes and their namespaces
#        Calls to other scripts for code, functions, data import.
# OUT : data/rdf/cdiscpilot01-R.TTL
# NOTE: Validation of the resulting TTL files with Apache Jenna riot
#        Later cross programmatically with scripts in the /validation folder
# TODO: Selection of rows for imputation are manually coded, with later values like personNum
#       used in conditional imputations later in the code. These dependencies should 
#       be changed to other coding when the entire file is processed.
#       
#______________________________________________________________________________
# Configuration and initial setup ---------------------------------------------
library(data.table)  # Index categories in createFrag_F.R
library(redland)     # Create TTL
library(Hmisc)
library(plyr)        # Must load prior to dplyr
library(dplyr)  
library(car)         # Recode values for SDTM codes, etc. Order of lib is imp.
library(reshape2)    # Recast and others...
library(stringr)
require(stringi)     # Proper casing, etc.

rm(list=ls())  # Clear workspace from prior runs.

# Flags and global parameters ----

# Subsetting to allow incremental dev
pntSubset<-c('01-701-1015') # List of usubjid's to process.

    # Subset for prototype development. Original ontology matching for DM
    # maxPerson = 6 # Original Ontology matching Used in DM_process.R for subsetting. VS is selects row numbers.

importsEnabled = FALSE  # Allow import when load OWL files

# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

# Version of Code/output. Triple created in graphMeta.R
version <- "0.0.1"

# Output filename and location
outFileMain   = "data/rdf/cdiscpilot01-R.TTL"

# Redland declarations ----
world <- new("World") # Model scope
# Storage provides a mechanism to store models; in-memory hashes are convenient for small models
storage <- new("Storage", world, "hashes", name="", options="hash-type='memory'")
# A model is a set of Statements, and is associated with a particular Storage instance
cdiscpilot01 <- new("Model", world=world, storage, options="")

# Prefix Declarations and [optional] OWL imports ----
source('R/prefixesAndImports.R') # Prefixes and OWL imports

# Graph Metadata ----
source('R/graphMeta.R') # Graph Metadata

# External Functions ----
source('R/misc_F.R')  # Data import, personID, etc.
source('R/createFrag_F.R') # URI fragement Creation. Eg. Date_1, AgeMeasurement_3

# XPT Imports ----
dm     <- readXPT("dm")
suppdm <- readXPT("suppdm")
vs     <- readXPT("vs")
ex     <- readXPT("ex")

# Imputation ----
# Create values needed for testing. 
source('R/DM_impute.R')     
source("R/SUPPDM_impute.R")
source('R/VS_impute.R') 
source('R/EX_impute.R') 

# Date Lookup
# Create the date translation table from all dates across domains
#   Created on ALL date values in source domains, prior to subsetting
#     for dev purposes.
#   Some dates are imputed, so must call AFTER all _impute.R
#   Needed by both xx_impute and xx_process scripts.
dateDict<-createDateDict()    

# Subset domains ----
# Keep subset of usubjid for dev
#TODO: Change into loop
dm     <- dm[dm$usubjid %in% pntSubset,]  
suppdm <- suppdm[suppdm$usubjid %in% pntSubset,]  
vs     <- vs[vs$usubjid %in% pntSubset,]  
ex     <- ex[ex$usubjid %in% pntSubset,]  

# Fragment Creation ----
source('R/DM_frag.R')  
source('R/VS_frag.R')
source('R/EX_frag.R')

# Process Domains ----
source('R/DM_process.R')
source('R/SUPPDM_process.R')
source('R/VS_process.R')
source('R/EX_process.R')

# Write out to TTL ------------------------------------------------------------
# Serialize the model to a TTL file
serializer <- new("Serializer", world, name="turtle", mimeType="text/turtle")

# Create the prefixes as a last step prior to serialization
ddply(prefixes, .(prefix), function(prefixes)
{
  status <- setNameSpace(serializer, world, 
    namespace=as.character(prefixes$namespace), prefix=as.character(prefixes$prefix))  
})
  
# Serialize to the file
status <- serializeToFile(serializer, world, cdiscpilot01, outFileMain)

# Validate --------------------------------------------------------------------
#   Always a good idea to validate, friendo.
system(paste('riot --validate ', outFileMain),
  show.output.on.console = TRUE)
