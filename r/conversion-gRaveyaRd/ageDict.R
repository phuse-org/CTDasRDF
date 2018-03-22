###############################################################################
# FILE: ageDict.R
# DESC: Create a dicitionary table of ages and their fragments that will 
#       ageKey - used to merge back into a column
#       ageFrag - the fragment that will become part of a URI for a age col
# REQ : 
#       
# SRC : 
# IN  : 
# OUT : 
# NOTE: Ages are all assumed to be in YEARS for this dataset. 
#        
# TODO: 
###############################################################################

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
