###############################################################################
# FILE: XPTtoCSV.R
# DESC: Convert XPT domain file to CSV
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
###############################################################################

# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

readXPT<-function(domain)
{
  sourceFile <- paste0("data/source/", domain, ".XPT")
  result <- sasxport.get(sourceFile)
  result  # return the dataframe
}

# XPT Import ----
dm     <- readXPT("dm")


