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
library(utils)  # for URLencode - no longer used. DELETE
library(dplyr)  # mutate with pipe in Functions.R
# library(RCurl)  # to encode URL values  REMOVED 2018-04-09

dm_n=3;  # The first n patients from the DM domain.

# Subsetting to allow incremental dev
pntSubset<-c('01-701-1015') # List of usubjid's to process.

# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

source('R/Functions.R')  # Functions: readXPT(), encodeCol(), etc.

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
source('R/EX_imputeCSV.R')


write.csv(ex, file="data/source/EX_subset.csv", 
row.names = F)


# VS ----
vs  <- readXPT("vs")  # first row only for initial testing.

# Subset for development
vs<-vs[vs$visit %in% c("BASELINE","SCREENING 1","WEEK 2","WEEK 24") & vs$usubjid==pntSubset,  ]

# Impute values needed for testing
source('R/VS_imputeCSV.R')  # Creates birthdate. 


write.csv(vs, file="data/source/vs_subset.csv", 
  row.names = F)


# TS ----
#ts  <- readXPT("ts")  # first row only for initial testing.
#write.csv(ts, file="data/source/ts_subset.csv", 
#  row.names = F)
