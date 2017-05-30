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
library(rrdf)
library(Hmisc)
library(plyr)  # plyr must load prior to dplyr!
# library(dplyr)  #DEL not currently in use?
library(car)   # Recoding of values for SDTM codes, etc. Order of lib is imp here.
library(reshape2)  # decast and others...

# Version of COde/output. Triple created in graphMeta.R
version <- "0.0.1"

# Subset for prototype development. 
maxPerson = 6; # Used in processDM.R 

# Set working directory to the root of the work area
setwd("C:/_github/SDTMasRDF")

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

# Import and indexing Functions (Called during domain processing) 
source('R/dataImportFnts.R')

#-- Import data. Needed here for creating unique URIs for values that span
#   Multiple domains, like dates.

#------------------------------------------------------------------------------
# DM DOMAIN
#------------------------------------------------------------------------------
dm <- readXPT("dm")
# For testing, keep only the first (maxPerson) patients in DM
dm <- head(dm, maxPerson)  # maxPerson set above

#-- Data Imputation for Prototype Testing ---------------------------------------
# Create the Person ID (Person_(n)) in the DM dataset for looping through the data by Person  
#     across domains when creating triples
id<-1:(nrow(dm))   # Generate a list of ID numbers
dm$personNum<- id

# Create an merge Index file for the other domains.
personId <- dm[,c("personNum", "usubjid")]

#---- Investigator name and ID not present in original source data
dm$invnam <- 'Jones'
dm$invid  <- '123'

#---- Birthdate : asbsent in source data
# NOTE: Date calculations based on SECONDS so you must convert the age in Years to seconds
#      Change to character to avoid later ddply problem in processDM.R
#      Dates reflect their original mixed format of DATE or DATETIME in same col.
dm$brthdate <- as.character(strptime(strptime(dm$rfstdtc, "%Y-%m-%d") - (strtoi(dm$age) * 365.25 * 24 * 60 * 60), "%Y-%m-%d"))
#---- Informed Consent  (column present with missing values in DM source).  
dm$rficdtc <- dm$dmdtc

# Unfactorize the dthdtc column to allow entry of a bogus date
dm$dthdtc <- as.character(dm$dthdtc)
dm$dthdtc[dm$personNum == 1 ] <- "2013-12-26"  # Death Date
dm$dthfl[dm$personNum == 1 ] <- "Y" # Set a Death flag  for Person_1

# -- Additional Value creation# Create an extra row of data that is used to create values not present in the orignal
#   subset of data. The row is used to create codelists, etc. dynamically during the script run
#   as an alternative to hard coding, since these values are not associated within any one subject
#   in the subset. The values likely are part of the larger set.
#   Add an new row to the DM dataframe to contain information needed for development
# SAUCE: https://gregorybooma.wordpress.com/2012/07/18/add-an-empty-column-and-row-to-an-r-data-frame/
#   Create a one-row matrix the same length as data
temprow <- matrix(c(rep.int(NA,length(dm))),nrow=1,ncol=length(dm))
 
# Convert to df with  cols the same names as the original (dm) df
newrow <- data.frame(temprow)
colnames(newrow) <- colnames(dm)
 
# rbind the empty row back to original df
dm <- rbind(dm,newrow)
 
# Populate the values in the last row of the data
dm[nrow(dm),"arm"]   <- 'Screen Failure'
dm[nrow(dm),"armcd"] <- 'Scrnfail'

#------------------------------------------------------------------------------
# VS DOMAIN
#------------------------------------------------------------------------------
# Import VS
vs <- readXPT("vs")

vs <- addPersonId(vs)
##-----------------   DEV/TESTING ONLY  ---------------------------------------
#SUBSET THE DATA DOWN TO A SINGLE PATIENT AND SUBSET OF TESTS FOR DEVELOPMENT PURPOSES
vs <- subset(vs, (personNum==1 
                  & vstestcd %in% c("DIABP", "SYSBP") 
                  # & visit %in% c("SCREENING 1", "SCREENING 2")))
                  & visit %in% c("SCREENING 1")))  # Subset further down to match AO data: 09May2017

#-- Data Imputation for Prototype Testing ---------------------------------------
# More imputations for the first 3 records to match data created by AO : 2016-01-19
#   These are new COLUMNS and values not present in original source!
vs$vsgrpid <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "GRPID1", "" )) 
vs$vscat   <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "CAT1", "" )) 
vs$vsscat  <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "SCAT1", "" )) 
vs$vsreasnd <- with(vs, ifelse(vsseq %in% c(1) & personNum == 1, "not applicable", "" )) 

# vsspid
vs[vs$vsseq %in% c(1), "vsspid"]  <- "123"
vs[vs$vsseq %in% c(2), "vsspid"]  <- "719"
vs[vs$vsseq %in% c(3), "vsspid"]  <- "235"

# vs[1:3,grep("vsstat", colnames(vs))] <- "CO"  (complete)
# Unfactorize the  column to allow entry of a bogus data
vs$vsstat <- as.character(vs$vsstat)
vs[1,grep("vsstat", colnames(vs))] <- "CO"



#---- vsloc  for DIABP, SYSBP all assigned as 'ARM' for development purposes.
# Unfactorize the  column to allow entry of a bogus data
vs$vsloc <- as.character(vs$vsloc)
vs$vsloc <- vs$vsloc[vs$testcd %in% c("DIABP", "SYSBP") ] <- "ARM"

# vslat
vs[vs$vsseq %in% c(1,3), "vslat"]  <- "RIGHT"
vs[vs$vsseq %in% c(2), "vslat"]    <- "LEFT"

vs[vs$vsseq %in% c(1), "vsblfl"]    <- "Y"

vs$vsdrvfl <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "N", "" )) 

# Investigator ID hard coded. See also processDM.R
vs$invid  <- '123'

# Assign 1st 3 obs as COMPLETE to match AO
vs$vsstat <- as.character(vs$vsstat) # Unfactorize to all allow assignment 

vs$vsrftdtc <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "2013-12-16", "" )) 

# -- Additional Value creation
# Create an extra row of data that is used to create values not present in the orignal
#   subset of data. The row is used to create codelists, etc. dynamically during the script run
#   as an alternative to hard coding, since these values are not associated within any one subject
#   in the subset. The values likely are part of the larger set.
# Add new rows of data used to create code lists for categories missing in 
#    the original test data.
temprow <- matrix(c(rep.int(NA,length(vs))),nrow=1,ncol=length(vs))
# Convert to df with  cols the same names as the original (vs) df
newrow <- data.frame(temprow)
colnames(newrow) <- colnames(vs)

# rbind the empty row back to original df
vs <- rbind(vs,newrow)

# now populate the values in the last row of the data
vs[nrow(vs),"vsstat"]   <- 'NOT DONE'  # add the ND value for creating activitystatus_2. Found later in the orginal data

#------------------------------------------------------------------------------
# xx DOMAIN
#   Additional domains to be added.
#------------------------------------------------------------------------------

# Create URI fragments for Dates and other categories that are shared URIs 
# Eg: Date_1, AgeMeasurement_3
source('R/createFrag.R')

# Create the date translation table from all dates across domains
dateDict<-createDateDict()  

#------------------------------------------------------------------------------
# Domain Processing
#------------------------------------------------------------------------------
#---- DM DOMAIN
#  NOTE: DM  MUST be processd first: Creates data required in later steps.
#        DM MUST BE Run to create personNUm that is used when processing other domains.
#        SUPPDM can be omitted during development steps.

source('R/processDM.R')
source('R/processSUPPDM.R')

#---- VS DOMAIN
source('R/processVS.R')

#---- X DOMAIN  Additional Domains will be added here.......

#------------------------------------------------------------------------------
# OUTPUT
#   Write out the TTL files
#------------------------------------------------------------------------------
cdiscpilot01 = save.rdf(cdiscpilot01,  filename=outFileMain,   format="TURTLE")   
custom       = save.rdf(custom, filename=outFileCustom, format="TURTLE")
code         = save.rdf(code,   filename=outFileCode,   format="TURTLE")

#------------------------------------------------------------------------------
# VALIDATION
#   Always a good idea to validate, friendo.
#------------------------------------------------------------------------------
system(paste('riot --validate ', outFileMain),
    show.output.on.console = TRUE)

#NB: Not updating custom.ttl or code.ttl as of 2017-05-25 . 
#    Focus is only on cdiscpilot01
#system(paste('riot --validate ', outFileCustom),
#    show.output.on.console = TRUE)

#system(paste('riot --validate ', outFileCode),
#    show.output.on.console = TRUE)
