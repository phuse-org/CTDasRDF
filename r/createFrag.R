###############################################################################
# FILE: createFrag.R
# DESC: Create URI fragments for Dates, Ages and other fields that are shared 
#         in common between various resources. Eg: A date (DATE_1) may be both
#         a study start date and a product administrationg date. 
#       dateKey - used to merge back into a column
#       dateFrag - the fragment that will become part of a URI for a date col
#
#       ageKey - used to merge back into a column
#       ageFrag - the fragment that will become part of a URI for a age col
#
# REQ : 
#       
# SRC : 
# IN  : 
# OUT : 
# NOTE: 
#       Ages are all assumed to be in YEARS for this dataset. 
# TODO: Combine the common elements into function(s) where possible
#
###############################################################################
#------------------------------------------------------------------------------
#  Date Fragments
#  All dates from across both DM and VS domains. 
#  TODO: Add additional domains as project scope expands.
#------------------------------------------------------------------------------
# dm dates
dmDates <- dm[,c("rfstdtc", "rfendtc", "rfxstdtc","rfxendtc", "rficdtc", "rfpendtc", "dthdtc", "dmdtc", "brthdate")]

# vs dates
vsDates <- data.frame(vs[,"vsdtc"])

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

# Add fragments back to the DM dataframe. 
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

#------------------------------------------------------------------------------
#  Age Fragments
#------------------------------------------------------------------------------
# There is only 1 column of ages in the study
ageKey <- dm$age

ageList <-as.data.frame(ageKey)
# Remove duplicates  ERROR: Changes from dataframe here!!! 
ageList <- unique(ageList
                  )
# Remove missing(blank) ages by coding to NA and them omitting
ageList[ageList==""] <- NA
ageList <- na.omit(ageList)

# Sort by age. Use dplyr arrange instead of order to avoid loss of df type
ageList <- arrange(ageList, ageKey)

# Create the coded value for each age as Age_n 
ageList$ageFrag <- paste0("AgeMeasurement_", 1:nrow(ageList))   # Generate a list of ID numbers

ageDict <- ageList[,c("ageKey", "ageFrag")]

# Merge in the ageKey value to created a coded version of the age field, naming
#    the column with a _Frag suffix.
addAgeFrag<-function(domainName, colName)
{
    withFrag <- merge(x = ageDict, y = domainName, by.x="ageKey", by.y=colName, all.y = TRUE)
    # Rename the merged-in key value to the original column name to preserve original data
    names(withFrag)[names(withFrag)=="ageKey"] <-  colName
    # Rename ageFrag value to coded value using colname +  _Frag suffix
    names(withFrag)[names(withFrag)=="ageFrag"] <- paste0(colName, "_Frag")
    return(withFrag)
}

# Add the age Fragment back into the DM dataframe.
dm <- addAgeFrag(dm, "age")  