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
# NOTE: 
#       Ages are all assumed to be in YEARS for this dataset. 
# TODO: (see individual functions for TODO list) 
#
###############################################################################

#------------------------------------------------------------------------------
#  Date Fragments
#    All dates from across both DM and VS domains. 
#    TODO: 
#      Add additional domains as project scope expands.
#      Recode into a new function createFragMultDomain(), following the 
#        same approach as createFragOneDomain()
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

# ERROR IS IN FOLLOWING STEP HERE!!!!!
# Remove duplicates
dateList <- dateList[!duplicated(dateList$date), ]  # is DF here.

# Remove missing(blank) dates by coding to NA and them omitting
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
#TODO: Move this to processDM.R
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
    # Remove duplicates  ERROR: Changes from dataframe here!!! 
    # uniques <<- unique(domainName[,processColumn])
    uniques <- unique(sourceVals[,"value"])
    # Remove missing(blank) values by coding to NA, then omitt
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
#    withFrag <- merge(x = valDict, y = domainName, by.x="keyVals", by.y=processColumn, all.y = TRUE)
    # Rename the merged-in key value to the original column name to preserve original data
#    names(withFrag)[names(withFrag)=="keyVals"] <-  processColumn
    # Rename valFrag value to coded value using processColumn +  _Frag suffix
#    names(withFrag)[names(withFrag)=="valFrag"] <- paste0(fragPrefix, "_Frag")
#    return(withFrag)
}

# -- Treatment Arms Processing ------------------------------------------------
#TODO: Move the dm calls out to processDM
dm <- createFragOneDomain(domainName=dm, processColumns=c("armcd", "actarmcd"), fragPrefix="arm"  )
#  Create custom terminlogy list for arm_1, arm_2 etc.
dm1 <- dm[,c("actarm", "actarmcd", "actarmcd_Frag")]
dm1 <- rename(dm1, c("actarm"= "arm", "actarmcd" = "armcd", "actarmcd_Frag" = "armcd_Frag"))
dm2 <- dm[,c("arm", "armcd", "armcd_Frag")]

dmArms <- rbind(dm1,dm2)
dmArms <- dmArms[!duplicated(dmArms), ]

# Loop through the arm_ codes to create  custom-terminology triples
ddply(dmArms, .(armcd_Frag), function(dmArms)
{
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.OWL, "Class")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CUSTOM, "CustomConcept")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CODE, "RandomizationOutcome")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CUSTOM, "Arm")
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"label" ),
        paste0(dmArms$arm), type="string"
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"label" ),
        paste0(dmArms$armcd), type="string"
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "Arm")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "RandomizationOutcome")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "AdministrativeActivityOutcome")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "CustomConcept")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "ActivityOutcome")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "RandomizationOutcome")
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.SKOS,"altLabel" ),
        paste0(dmArms$armcd), type="string"
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.SKOS,"prefLabel" ),
        paste0(dmArms$arm), type="string"
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CUSTOM, "Arm")
    )
})    

#------------------------------------------------------------------------------
# Age
#------------------------------------------------------------------------------
# - age fragment as AgeOutcome_
dm <- createFragOneDomain(domainName=dm, processColumns="age", fragPrefix="AgeOutcome"  )

# Keep only the columns needed to create triples in the terminology file
ageList <- dm[,c("age", "ageu", "age_Frag")]

ageList <- ageList[!duplicated(ageList), ]

# Loop through the arm_ codes to create  custom-terminology triples
ddply(ageList, .(age_Frag), function(ageList)
{
    add.triple(custom,
        paste0(prefix.CUSTOM, ageList$age_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CUSTOM, "AgeOutcomeTerm")
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, ageList$age_Frag),
        paste0(prefix.RDFS,"label" ),
        paste0(ageList$age, " ", ageList$ageu), type="string"
    )
    #TODO Make this triple conditional: if ageu=YEARS, then:
    add.triple(custom,
        paste0(prefix.CUSTOM, ageList$age_Frag),
        paste0(prefix.CODE,"hasUnit" ),
        paste0(prefix.TIME, "unitYear")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, ageList$age_Frag),
        paste0(prefix.CODE,"hasUnit" ),
        paste0(prefix.TIME, "unitYear")
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, ageList$age_Frag),
        paste0(prefix.CODE,"hasValue" ),
        paste0(ageList$age), type="int"
    )
})    


#------------------------------------------------------------------------------
# Country
#------------------------------------------------------------------------------
dm <- createFragOneDomain(domainName=dm, processColumns="country", fragPrefix="country"  )

# Does country get recorded in CUSTOM.TTL or elsewhere?


