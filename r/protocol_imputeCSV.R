#______________________________________________________________________________
# FILE: protocol_imputeCSV.R
# DESC: Creates data values required for prototyping and ontology develeopment
#         Values are hard coded in this script. IRL they would be extracted
#         from the Protocol document and other sources like Site list.
# REQ : 
# SRC : N/A
# IN  :  
# OUT : protocol dataframe  
#       
# NOTE:  
# TODO:   
#______________________________________________________________________________
#
# Remove next lines when integrated with XPTtoCSV.R 
# Set working directory to the root of the work area
  setwd("C:/_github/CTDasRDF")
  source('R/Functions.R')  # Functions: readXPT(), encodeCol(), etc.
  library(dplyr)  # recode, mutate with pipe in Functions.R, other dplyr goodness
# End lines to be removed

protocol <- data.frame(
  studyid          = "CDISCPILOT01",
  adaptiveDesignNY = "N",
  addOnNY          = "N",
  blindingSchema   = "DOUBLE_BLIND",
  controlType      = "PLACEBO",
  studyBegin       = "2012-07-06",
  studyEnd         = "2015-03-05",
  actualPopSize    = "254",
  plannedPopSize   = "300",
  ageGroup         = "ADULT",
  siteid           = "710",
  sdtmtermNY       = "N",
  sexGroup         = "BOTH"
)
  
# Sort column names in the df for quicker referencing
protocol <- protocol %>% select(noquote(order(colnames(protocol))))

write.csv(protocol, file="data/source/protocol.csv", 
  row.names = F,
  na = "")



