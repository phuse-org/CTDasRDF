###############################################################################
# FILE: createFrag.R
# DESC: Create URI fragments for Dates, Ages and other fields that are shared 
#         in common between various resources. Eg: A date (DATE_1) may be both
#         a study start date and a product administration date. 
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

# Create the label and dateTimeInXSDString triples for each new date _Frag to avoid 
#   repeating the same values when createDateTriples is called
#   Both the label and the string representation of the date are the same.

ddply(dateDict, .(dateKey), function(dateDict)
{
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, dateDict$dateFrag),
        paste0(prefix.STUDY, "dateTimeInXSDString" ),
        paste0(dateDict$dateKey), type="string"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, dateDict$dateFrag),
        paste0(prefix.RDFS,"label" ),
        paste0(dateDict$dateKey), type="string"
    )
})

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

#------------------------------------------------------------------------------
#  arm (treatment arm) Age Fragments
# TODO: Make a new function that creates fragments for columns, then call it 
#    for columns: age, arm, armcd, etc.
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

#------------------------------------------------------------------------------
# createFrag()
#  NEW 2017-04-18:   New code for a function that creates fragments for coding
#                  values that exist in a single column. These fragments then used
#                   to create URIs.
# TODO: replace all addAgeFrag section with a call to this function!
#------------------------------------------------------------------------------

createFrag<-function(domainName, columnName)
{
    keyVals <- domainName[,columnName]
    # uniqueVals <-as.data.frame(keyVals)
    
    # Remove duplicates  ERROR: Changes from dataframe here!!! 
    uniques <<- unique(domainName[,columnName])

    # Remove missing(blank) values by coding to NA, then omitt
    uniques[uniques==""] <- NA
    uniques <- na.omit(uniques)
    keyVals <- sort(uniques, decreasing = F)
    # Sort by values. Prev code: Use dplyr arrange instead of order/sort to avoid loss of df type
    #OLD CODE uniqueVals <- arrange(uniqueVals, keyVals)
    # uniqueVals$keyVals <- as.data.frame(sort(uniques))
    # uniqueVals <- as.data.frame(sort(uniques))
    uniqueVals <- as.data.frame(keyVals)
    
    # Create the coded value for each unique value as <value_n> 
    uniqueVals$valFrag <- paste0(columnName,"_cd_", 1:nrow(uniqueVals))   # Generate a list of ID numbers
    
    valDict <- uniqueVals[,c("keyVals", "valFrag")]
    
    # Merge in the keyVals value to created a coded version of the value field, naming
    #    the column with a _Frag suffix.
    withFrag <- merge(x = valDict, y = domainName, by.x="keyVals", by.y=columnName, all.y = TRUE)
    # Rename the merged-in key value to the original column name to preserve original data
    names(withFrag)[names(withFrag)=="keyVals"] <-  columnName
    # Rename valFrag value to coded value using columnName +  _Frag suffix
    names(withFrag)[names(withFrag)=="valFrag"] <- paste0(columnName, "_Frag")
    return(withFrag)
}
# Add the Fragment back into the dataframe.
foo <-createFrag(dm, "armcd")  




