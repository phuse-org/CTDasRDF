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
dmDates <- dm[,c("rfstdtc", "rfendtc", "rfxstdtc","rfxendtc", "rficdtc", "rfpendtc_D", "dthdtc", "dmdtc", "brthdate")]

#TODO vs date columns

#TODO Add vs:  Combined the date datframes  ((CBIND))
allDates <- dmDates

dateList <- melt(allDates, measure.vars=c("rfstdtc", "rfendtc", "rfxstdtc", 
    "rfxendtc", "rficdtc", "rfpendtc_D", "dthdtc", "dmdtc", "brthdate"),
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


