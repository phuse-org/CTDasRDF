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
#        - restructure this code - very kludgey...
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
# createFrag()
#   Create URI fragments for coded values in a SINGLE column.
#     - Create a unique list of all the values in that column 
#     - Index the unique values
#     - Create a coded value that includes that index number (_<n>)
#     - Merge indexed fragment back into the data
#     - Use the fragment to construct IRIs
#     domainName = domain dataset. Eg: dm, vs, ...
#     processColumn = name of the column to process. Eg: armcd, age ...
#     outPrefix  = prefix value used in both the new column name for the fragments 
#       and the fragments themselves. Eg:
#       column: actarm_frag, has values: actarm_1, actarm_3...
#       Note: original source data has columns actarmcd, armcd. The 'cd'  
#         is not needed in the RDF context, so drop that part of the name
#------------------------------------------------------------------------------
createFrag<-function(domainName, processColumn, outPrefix)
{
    keyVals <- domainName[,processColumn]
    # uniqueVals <-as.data.frame(keyVals)
    
    # Remove duplicates  ERROR: Changes from dataframe here!!! 
    uniques <<- unique(domainName[,processColumn])

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
    uniqueVals$valFrag <- paste0(outPrefix,"_", 1:nrow(uniqueVals))   # Generate a list of ID numbers
    
    valDict <- uniqueVals[,c("keyVals", "valFrag")]
    
    # Merge in the keyVals value to created a coded version of the value field, naming
    #    the column with a _Frag suffix.
    withFrag <- merge(x = valDict, y = domainName, by.x="keyVals", by.y=processColumn, all.y = TRUE)
    # Rename the merged-in key value to the original column name to preserve original data
    names(withFrag)[names(withFrag)=="keyVals"] <-  processColumn
    # Rename valFrag value to coded value using processColumn +  _Frag suffix
    names(withFrag)[names(withFrag)=="valFrag"] <- paste0(outPrefix, "_Frag")
    return(withFrag)
}
# Add the Fragment back into the dataframe.
dm <- createFrag(dm, "age", "age")  # See how/if used now. Was AgeMeasurement that is now part of Demographics collection...
dm <- createFrag(dm, "armcd", "arm")  
dm <- createFrag(dm, "actarmcd", "actarm")  



