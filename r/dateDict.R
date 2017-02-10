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

# dm date columns
dmDates <- dm[,c("rfstdtc", "rfendtc", "rfxstdtc","rfxendtc", "rficdtc", "rfpendtc", "dthdtc", "dmdtc", "brthdate")]

#TODO vs date columns

#TODO Add vs:  Combined the date datframes  ((CBIND))
allDates <- dmDates

dateList <- melt(allDates, measure.vars=c("rfstdtc", "rfendtc", "rfxstdtc", 
    "rfxendtc", "rficdtc", "rfpendtc", "dthdtc", "dmdtc", "brthdate"),
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

# Move following FUNCT to a sep file and the calls to processDM.R

# addpersonId()
# Merge the personId into the other domains to allow later looping during triple creation. 

addDateFrag<-function(domainName, colName)
{
    withFrag <- merge(x = dateDict, y = domainName, by.x="dateKey", by.y=colName, all.y = TRUE)
    # Rename dateFrag value to the name of column being matched plus the _Frag suffix
    names(withFrag)[names(withFrag)=="dateFrag"] <- paste0(colName, "_Frag")
    # Remove columns that are an artifact from the merge.
    withFrag <- withFrag[ , !names(withFrag) %in% c("dateKey")] 
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

