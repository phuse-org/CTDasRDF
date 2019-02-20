#______________________________________________________________________________
# FILE: medDRAReadAsc.R
# DESC:  Read the original .asc files from MedDRA into R dataframes for 
#        processing into RDF.
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
#______________________________________________________________________________

setwd("C:/_github/CTDasRDF")

#' Read MedDRA asc files.
#' 
#'
#' @param ascFile  File name, no extension
#' @param colNames Column names in the order they appear in the source file
#'                 These names are created by the team and may not be the 
#'                 official MSSO names! Named using underbar instead of spaces.
#' @return R dataframe with only the column names listed in the function call.
#'
#' @examples
#'  readAscFile(ascFile="soc",      colNames=c("code", "label", "short"))
#'  readAscFile(ascFile="hlgt",     colNames=c("code", "label"))
#'  readAscFile(ascFile="hlt",      colNames=c("code", "label"))
#'  readAscFile(ascFile="pt",       colNames=c("code", "label", "SOC_code"))
#'  readAscFile(ascFile="llt",      colNames=c("code", "label", "PT_code"))
#'  readAscFile(ascFile="soc_hlgt", colNames=c("SOC_code", "HGLT_code"))
#'  readAscFile(ascFile="hlt-pt",   colNames=c("HGLT_code", "HLT_code"))
#'  readAscFile(ascFile="hlt_pt",   colNames=c("HLT_code", "PT_code"))
#' 
readAscFile <- function(ascFile, colNames)
{
  sourceFile <- paste0("data/medDRA/meddra_21_1_english/MedAscii/", ascFile, ".asc")

  result <- read.delim2(sourceFile, 
              header = FALSE, 
              sep = "$", 
              quote = "\"")
  
  names(result) <- colNames
  #cols <- colnames(result)
  # Remove "missing" columns (.. in name) and the PREREQUISITE column that is only
  #    present in SDTM and ADAM.
  result <- result[,colNames]  
  
} 

hlt_ptData <- readAscFile(ascFile="hlt_pt", colNames=c("HLT_code", "PT_code"))
head(hlt_ptData)
