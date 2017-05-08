###############################################################################
# FILE: createFrag.R
# DESC: Create URI fragments for Dates, Ages and other fields that are shared 
#         in common between various resources. Eg: A date (DATE_1) may be both
#         a study start date and a product administration date. 
# REQ : 
#       
# SRC : 
# IN  : 
# OUT : 
# NOTE: createDateDict() Create a translation table of dates to date fragments
#       addDateFrag()  - merges fragments back into corresponding date column
#       createFragOneDomain() - creates fragment from within a single domain, from
#         one or more columns within that df
#       Ages are all assumed to be in YEARS for this dataset. 
# TODO: (see individual functions for TODO list) 
#
###############################################################################

#------------------------------------------------------------------------------
# createDateDict()
#   Create a translation table of dates to date fragments
#    All dates from across both DM and VS domains. 
#    TODO: 
#      Add additional domains as project scope expands. Make function flexible
#      to accept these as arguments instead of hard coded.
#------------------------------------------------------------------------------
createDateDict <- function()
{
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
    dateList <- dateList[!duplicated(dateList$date), ]
    
    # Remove missing(blank) dates by coding to NA and then omitting
    dateList[dateList==""] <- NA
    dateList <- na.omit(dateList)
    
    # Sort by date
    dateList <- dateList[with(dateList, order(dateKey)),]
    
    # Create the coded value for each date as Date_n 
    dateList$dateFrag <- paste0("Date_", 1:nrow(dateList))   # Generate a list of ID numbers
    
    #  dateKey - used to merge back into a column
    #  dateFrag - the fragment that will become part of a URI for a date col
    dateDict <- dateList[,c("dateKey", "dateFrag")]
    
    # Create the label and dateTimeInXSDString triples for each new date _Frag to avoid 
    #   repeating the same values when createDateTriples is called
    #   Both the label and the string representation of the date are the same.
    
    ddply(dateDict, .(dateKey), function(dateDict)
    {
        add.data.triple(cdispilot01,,
            paste0(prefix.CDISCPILOT01, dateDict$dateFrag),
            paste0(prefix.STUDY, "dateTimeInXSDString" ),
            paste0(dateDict$dateKey), type="string"
        )
        add.data.triple(cdispilot01,,
            paste0(prefix.CDISCPILOT01, dateDict$dateFrag),
            paste0(prefix.RDFS,"label" ),
            paste0(dateDict$dateKey), type="string"
        )
    })
    return(dateDict)
}

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
#------------------------------------------------------------------------------
#  createFragOneDomain()
#    Create URI fragments for coded values in a single or mutliple column. 
#      - If more than one column, combine values into a single column to process
#      - Create numeric index the unique values
#      - Create a coded value that includes that index number (_<n>)
#      - Merge indexed IRI fragment back into the source data column(s)
#      - Use the fragment in the process<DOMAIN>.R scripts to construct IRIs
#    domainName = A single, source domain dataset. Eg: dm, vs, ...
#    processColumns = names of one of more columns for the source values
#    fragPrefix  = a prefix value used in both the new column name for 
#      the fragments and the fragment value itself. 
#      Examples: column: actarm_frag, has values: actarm_1, actarm_3...
#    Note: original source data has columns actarmcd, armcd. The 'cd'  
#         is not needed in the RDF context, so drop that part of the name
#------------------------------------------------------------------------------
createFragOneDomain<-function(domainName, processColumns, fragPrefix)
{
    # Combine the multiple columns into one
    columnData <- domainName[,c(processColumns)] # keep only the requested cols in the df
    
    sourceVals <- melt(columnData, measure.vars=colnames(columnData),
                    variable.name="source",
                    value.name="value")
    
    # Keep only the values. Source not important
    #TW:NOT NEEDED #sourceVals <- sourceVals[ , c("value")]
    # 
    uniques <- unique(sourceVals[,"value"])
    # Remove missing(blank) values by coding to NA, then omit
    uniques[uniques==""] <- NA
    uniques <- na.omit(uniques)
    keyVals <- sort(uniques, decreasing = F)
    # Sort by values. Prev code: Use dplyr arrange instead of order/sort to avoid loss of df type
    uniqueVals <- as.data.frame(keyVals)
    
    # Create the coded value for each unique value as <value_n> 
    uniqueVals$valFrag <- paste0(fragPrefix,"_", 1:nrow(uniqueVals))   # Generate a list of ID numbers
    
    valDict <<- uniqueVals[,c("keyVals", "valFrag")]
    
    # Merge in the keyVals value to created a coded version of the value field, naming
    #    the column with a _Frag suffix.
    for (i in processColumns) {
        domainName <- merge(x = valDict, y = domainName, by.x="keyVals", by.y=i, all.y = TRUE)
        # Rename the merged-in key value to the original column name to preserve original data
        names(domainName)[names(domainName)=="keyVals"] <-  i
        # Rename valFrag value to coded value using processColumn +  _Frag suffix
        # names(withFrag)[names(withFrag)=="valFrag"] <- paste0(fragPrefix, "_Frag")
        names(domainName)[names(domainName)=="valFrag"] <- paste0(i, "_Frag")
    
    }
     return(domainName)
}
