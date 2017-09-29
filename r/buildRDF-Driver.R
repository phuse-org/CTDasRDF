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
# TODO: 
#______________________________________________________________________________
# Configuration and initial setup ---------------------------------------------
library(rrdf) # to be depreciated in favor of redland
library(redland)
library(Hmisc)
library(plyr)   # plyr must load prior to dplyr
library(dplyr)  
library(car)   # Recoding of values for SDTM codes, etc. Order of lib is imp here.
library(reshape2)  # decast and others...
library(stringr)
require(stringi)  # Proper casing, etc.

rm(list=ls())  # Clear workspace from prior runs.

#** Flags and global parameters ----
# Subset for prototype development. 
maxPerson = 6 # Used in DM_process.R for subsetting. VS is selects row numbers.
importsEnabled = FALSE

# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

# Version of COde/output. Triple created in graphMeta.R
version <- "0.0.1"

# Output filename and location
outFileMain   = "data/rdf/cdiscpilot01-R.TTL"

#TODO: Replace with redlands initiation
# Initialize. Includes OWL, XSD, RDF by default.
cdiscpilot01  = new.rdf()  # The main datafile. Later change name to 'mainTTL" or similar
    # custom = new.rdf()  # customterminology-R.ttl  : NOT CURRENTLY IN USE
    # code   = new.rdf()  # code-R.ttl               : NOT CURRENTLY IN USE


# new redlands declarations
# World is the redland mechanism for scoping models
world <- new("World")

# Storage provides a mechanism to store models; in-memory hashes are convenient for small models
storage <- new("Storage", world, "hashes", name="", options="hash-type='memory'")

# A model is a set of Statements, and is associated with a particular Storage instance
cdiscpilot01 <- new("Model", world=world, storage, options="")

#** Prefix Declarations and [optional] OWL imports ----
source('R/prefixesAndImports.R') # Prefixes and OWL imports

# Graph Metadata ----
source('R/graphMeta.R') # Graph Metadata

# External Functions ----
source('R/misc_F.R')  # Data import, personID, etc.
source('R/createFrag_F.R') # URI fragement Creation. Eg. Date_1, AgeMeasurement_3

# Import and Impute DM --------------------------------------------------------
dm <- readXPT("dm")
dm <- head(dm, maxPerson)  # Keep only first maxPerson obs for development
source('R/DM_impute.R')     # Create values needed for testing. 

# Import and Impute VS --------------------------------------------------------
vs <- readXPT("vs")
source('R/VS_impute.R') 

# Import and Impute other domains ---- : to be added later----------------------
# Create the date translation table from all dates across domains
#   Needed by both xx_impute and xx_process scripts.
dateDict<-createDateDict()    

# Create fragment dictionaries that cross domains
#   Called after all contributing  domains available, since some fragment values 
#      (eg: dates), cross multiple domains.
source('R/DM_frag.R')  # Requires prev. import of VS for VS dates used as part 
                       #   of DateDict/dateFrag creation

# Domain Processing -----------------------------------------------------------
# DM DOMAIN ----
#    DM MUST be processed first: Creates data required in later steps, 
#      including personNum. 

source('R/DM_process.R')


#TW source('R/SUPPDM_process.R')

# VS Domain ----
#TW source('R/VS_frag.R')


#TW source('R/VS_process.R')

# XX Domain (to be added) ---- 

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

