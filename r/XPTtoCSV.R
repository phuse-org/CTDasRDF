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

dm_n=3;  # The first n patients from the DM domain.

# Subsetting to allow incremental dev
pntSubset<-c('01-701-1015') # List of usubjid's to process.


# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

readXPT<-function(domain)
{
  sourceFile <- paste0("data/source/", domain, ".XPT")
  result <- sasxport.get(sourceFile)
  result  # return the dataframe
}

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

# TS ----
#ts  <- readXPT("ts")  # first row only for initial testing.
#write.csv(ts, file="data/source/ts_subset.csv", 
#  row.names = F)


# VS ----
vs  <- readXPT("vs")  # first row only for initial testing.

# Subset for development
vs<-vs[vs$visit %in% c("BASELINE","SCREENING 1","WEEK 2","WEEK 24") & vs$usubjid==pntSubset,  ]

# Impute values needed for testing
source('R/DM_imputeCSV.R')  # Creates birthdate. 


write.csv(vs, file="data/source/vs_subset.csv", 
  row.names = F)
