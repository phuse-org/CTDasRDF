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
# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

readXPT<-function(domain)
{
  sourceFile <- paste0("data/source/", domain, ".XPT")
  result <- sasxport.get(sourceFile)
  result  # return the dataframe
}

# XPT Import ----
dm     <- head(readXPT("dm"),1)  # first row only for initial testing.

source('R/DM_impute.R')

write.csv(dm, file="data/source/DM-1obs.csv", 
  row.names = F)
