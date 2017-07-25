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
# TODO: 
###############################################################################
# Configuration and initial setup ---------------------------------------------
library(rrdf)
library(Hmisc)
library(plyr)   # plyr must load prior to dplyr
library(dplyr)  
library(car)   # Recoding of values for SDTM codes, etc. Order of lib is imp here.
library(reshape2)  # decast and others...
library(stringr)

rm(list=ls())  # Clear workspace from prior runs.

# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

# Version of COde/output. Triple created in graphMeta.R
version <- "0.0.1"

# Subset for prototype development. 
maxPerson = 6; # Used in DM_process.R for subsetting

# Output filename and location
outFileMain   = "data/rdf/cdiscpilot01-R.TTL"

# Initialize. Includes OWL, XSD, RDF by default.
cdiscpilot01  = new.rdf()  # The main datafile. Later change name to 'mainTTL" or similar
    # custom = new.rdf()  # customterminology-R.ttl  : NOT CURRENTLY IN USE
    # code   = new.rdf()  # code-R.ttl               : NOT CURRENTLY IN USE

# Build Prefixes --------------------------------------------------------------
#   Add prefixes to files cdiscpilot01-R.TTL, and later to other namespace TTL
#     files if/when implemented, allowing one source of prefix definitions for
#     both building the TTL file and for later query and vis. R scripts.
#------------------------------------------------------------------------------
allPrefix <- "data/config/prefixes.csv"  # List of prefixes

prefixes <- as.data.frame( read.csv(allPrefix,
  header=T,
  sep=',' ,
  strip.white=TRUE))

ddply(prefixes, .(prefix), function(prefixes)
{
  add.prefix(cdiscpilot01,
    prefix=as.character(prefixes$prefix),
    namespace=as.character(prefixes$namespace)
  )
  # Add output to other TTL files as per this example. 
  # Prefixes to code-R.ttl file
  #add.prefix(code,
  #  prefix=as.character(prefixes$prefix),
  #  namespace=as.character(prefixes$namespace)
  #)

  # Create uppercase prefix names for use in add() statements in the 
  #   xx_process.R scripts. 
  assign(paste0("prefix.",toupper(prefixes$prefix)), prefixes$namespace, envir=globalenv())
  # assign(paste0("prefix.",toupper(prefixes[i, "prefix"])), prefixes[i, "namespace"], envir=globalenv()))
})


# Build Imports --------------------------------------------------------------
#   Create the owl:import statements 
#------------------------------------------------------------------------------
owlImports <- "data/config/imports.csv"  # List of prefixes
imports <- as.data.frame( read.csv(owlImports,
  header=T,
  sep=',' ,
  strip.white=TRUE))

add.triple(cdiscpilot01,
  paste0("https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl"),
  paste0(prefix.RDF,"type" ),
  paste0(prefix.OWL, "Ontology")
)
ddply(imports, .(o), function(imports)
{
  add.triple(cdiscpilot01,
    paste0(imports$s),
    paste0(prefix.OWL,"imports"),
    paste0(imports$o)
  )
})

add.data.triple(cdiscpilot01,
  paste0("https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl"),
  paste0(prefix.OWL,"versionInfo" ),
  paste0("Created with R to match TopBraid Composer imports from AO"), type="string"
)

# Graph Metadata ----
source('R/graphMeta.R') # Graph Metadata

# Functions for later use -----------------------------------------------------
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
#      eg: dates, cross multiple domains.
source('R/DM_frag.R')  # Requires prev. import of VS for VS dates used as part 
                       #   of DateDict/dateFrag creation

# Domain Processing -----------------------------------------------------------
#------------------------------------------------------------------------------
# DM DOMAIN ----
#    DM MUST be processed first: Creates data required in later steps, 
#      including personNum. 
source('R/DM_process.R')
source('R/SUPPDM_process.R')

# VS Domain ----
source('R/VS_frag.R')


source('R/VS_process.R')

# XX Domain (to be added) ---- 

# Write out to TTL ------------------------------------------------------------
cdiscpilot01 = save.rdf(cdiscpilot01,  filename=outFileMain,   format="TURTLE")   

# Validate --------------------------------------------------------------------
#   Always a good idea to validate, friendo.
system(paste('riot --validate ', outFileMain),
  show.output.on.console = TRUE)