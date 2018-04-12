###############################################################################
# FILE : /utility/readXPT.R
# DESCR: Read SAS .XPT file into R Dataframe
# SRC  : /data
# KEYS : 
# NOTES: 
#        
# INPUT: 
#      : 
# OUT  : 
# REQ  : 
# TODO : 
###############################################################################
library(Hmisc)

# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF/data/source")

readXPTDomain <- function (domainName){
   domainValues <- sasxport.get(paste0(domainName, ".xpt"))
   ## dataSubset   <- head(domainValues, 300)    
}

domainVals <- readXPTDomain("ex")

foo<-data.frame(domainVals$extrt)




foo<-as.data.frame(unique(domainVals$vsorres))



foo



domainVals <- domainVals[domainVals$usubjid=='01-701-1015',]

domainVals <- domainVals[domainVals$visit=='SCREENING 1',]

# Sort
domainVals <- domainVals[with(domainVals, order(vstptnum)), ]

# TEST BED
# Testing scripts on the raw data that may be used in other parts of the programs.
#  
# Remove T from  dateTime values when present 
# the field is already Character, no need for as.character conversion

#masterData$rfpendtc <- gsub("T", "-", masterData$rfpendtc)
#masterData$flag <- ifelse(grepl(":",masterData$rfpendtc),'DATETIME','DATE')
#for (i in 1:nrow(masterData))
#{
#    if (grepl(":",masterData[i,"rfpendtc"])
#        |
#        is.na(as.Date(masterData[i,"rfpendtc"], format = "%Y-%m-%d")) # UNTESTED
#    )
#        {
#        masterData[i,"rfpendtc_F"] <- "STRING"
#    } else {
#        masterData[i,"rfpendtc_F"] <- "DATE"
#    }
#        
#}



