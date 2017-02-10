###############################################################################
# FILE: dateDict.R
# DESC: Create a dicitionary table of dates and their fragments that will 
#         become part of date URI's in the TTL.
#       dateKey - used to merge back into a column
#       dateFrag - the fragment that will become part of a URI for a date col
# REQ : 
#       
# SRC : 
# IN  : 
# OUT : 
# NOTE: 
#        
# TODO: Extend to include dates in VS
#
###############################################################################
library(reshape2)

# dm dates
dmDates <- dm[,c("rfstdtc", "rfendtc", "rfxstdtc","rfxendtc", "rficdtc", "rfpendtc", "dthdtc", "dmdtc", "brthdate")]

# vs dates
vsDates <- data.frame(vs[,"vsdtc"])

library(plyr)
# Combined the date dataframes from all sources
allDates <- merge(dmDates,vsDates)

# Melt all the dates into a single column of values
dateList <- melt(allDates, measure.vars=colnames(allDates),
                 variable.name="source",
                 value.name="dateKey")

# Remove duplicates
dateList <- dateList[!duplicated(dateList$date), ]  # is DF here.

# Remove missing(blank) dates by coding to NA and them omitting
dateList[dateList==""] <- NA
dateList <- na.omit(dateList)

# Sort by date
dateList <- dateList[with(dateList, order(dateKey)),]

# Create the coded value for each date as Date_n 
dateList$dateFrag <- paste0("Date_", 1:nrow(dateList))   # Generate a list of ID numbers

dateDict <- dateList[,c("dateKey", "dateFrag")]


# Merge in the dateKey value to created a coded version of the date field, naming
#    the column with a _Frag suffix.
addDateFrag<-function(domainName, colName)
{
    withFrag <- merge(x = dateDict, y = domainName, by.x="dateKey", by.y=colName, all.y = TRUE)
    # Rename the merged-in key value to the original column name to preserve original data
    names(withFrag)[names(withFrag)=="dateKey"] <-  colName
    # Rename dateFrag value to coded value using colname +  _Frag suffix
    names(withFrag)[names(withFrag)=="dateFrag"] <- paste0(colName, "_Frag")
    # withFrag <- withFrag[ , !names(withFrag) %in% c("dateKey")]  #DEL - no longer needed
    return(withFrag)
}

#TODO: Move to processDM.R
#TODO: change to an lapply over the list of date fields instead of separate calls
dm <- addDateFrag(dm, "rfstdtc")  

dm <- addDateFrag(dm, "rfendtc")  
dm <- addDateFrag(dm, "rfxstdtc")  
dm <- addDateFrag(dm, "rfxendtc")  
dm <- addDateFrag(dm, "rficdtc")  
dm <- addDateFrag(dm, "rfpendtc")  
dm <- addDateFrag(dm, "dthdtc")
dm <- addDateFrag(dm, "dmdtc")  
dm <- addDateFrag(dm, "brthdate")  

dmDatesList <- c("rfstdtc", "rfendtc", "rfxstdtc","rfxendtc", "rficdtc", "rfpendtc", "dthdtc", "dmdtc", "brthdate")


