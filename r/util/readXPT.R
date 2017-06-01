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
setwd("C:/_github/SDTMasRDF/data/source")

readXPTDomain <- function (domainName){
   domainValues <- sasxport.get(paste0(domainName, ".xpt"))
   # dataSubset   <- head(domainValues, 100)    
}

domainVals <- readXPTDomain("dm")


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



