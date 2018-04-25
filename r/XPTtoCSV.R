###############################################################################
# FILE: XPTtoCSV.R
# DESC: Convert XPT domain file to CSV
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: Some imputed values to match ontology development requirements.
# TODO: 
###############################################################################
library(Hmisc)
library(car)   # recode
# library(plyr)
library(utils)  # for URLencode - no longer used. DELETE
library(dplyr)  # mutate with pipe in Functions.R


dm_n=3;  # The first n patients from the DM domain.

# Subsetting to allow incremental dev
pntSubset<-c('01-701-1015') # List of usubjid's to process.

# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

source('R/Functions.R')  # Functions: readXPT(), encodeCol(), etc.


# ---- Graph Metadata ---------------------------------------------------------
# Read in the source CSV, insert time stamp, and write it back out
#  Source file needed UTF-8 spec to import first column correctly. Could be articfact
#    that needs later replacement.
graphMeta <- read.csv2("data/source/ctdasrdf_graphmeta.csv",
   fileEncoding="UTF-8-BOM" , header=TRUE, sep=",");

graphMeta$createdOn<-gsub("(\\d\\d)$", ":\\1",strftime(Sys.time(),"%Y-%m-%dT%H:%M:%S%z"))

write.csv(graphMeta, file="data/source/ctdasrdf_graphmeta.csv",
  row.names = F)

# ---- XPT Import -------------------------------------------------------------
# DM ----
dm  <- head(readXPT("dm"), dm_n)

# Impute values needed for testing
source('R/DM_imputeCSV.R')  # Creates birthdate. 

write.csv(dm, file="data/source/DM_subset.csv", 
  row.names = F)

# SUPPDM ----
suppdm  <- readXPT("suppdm")
# subset for development
suppdm <- suppdm[suppdm$usubjid %in% pntSubset,]  
write.csv(suppdm, file="data/source/SUPPDM_subset.csv", 
row.names = F)

# EX ----
ex  <- readXPT("ex")
# subset for development
ex <- ex[ex$usubjid %in% pntSubset,]  

# Impute values needed for testing
source('R/EX_imputeCSV.R')#

write.csv(ex, file="data/source/EX_subset.csv", 
row.names = F)

# VS ----
vs  <- readXPT("vs")  # first row only for initial testing.

# Subset for development
# Subset to match ontology data. Expand to all of subjid 1015 later.
vsSubset <-c(1:3, 86:88, 43, 44:46, 128, 142, 7, 13, 37)
vs <- vs[vsSubset, ]

# for later development:
# vs<-vs[vs$visit %in% c("BASELINE","SCREENING 1","WEEK 2","WEEK 24") & vs$usubjid==pntSubset,  ]

# Impute values needed for testing
source('R/VS_imputeCSV.R')  # Creates birthdate. 

write.csv(vs, file="data/source/vs_subset.csv", 
  row.names = F)


# TS ----
#ts  <- readXPT("ts")  # first row only for initial testing.
#write.csv(ts, file="data/source/ts_subset.csv", 
#  row.names = F)
