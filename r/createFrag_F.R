#______________________________________________________________________________
# FILE: createFrag_F.R
# DESC: Functions and the calls that create URI fragments for Dates, Ages and 
#     other fields that are shared in common between various resources. 
# REQ : 
#     
# SRC : 
# IN  : 
# OUT : 
# NOTE: createDateDict() Create a translation table of dates to date fragments
#     addDateFrag()  - merges fragments back into corresponding date column
#     createFragOneDomain() - creates fragment from within a single domain, from
#     one or more columns within that df
#     Ages are all assumed to be in YEARS for this dataset. 
#     Eg: A date (DATE_1) may be a birthdate(DM) and a product 
#       administration date (VS) so dates from all domains are needed to first
#       create the date fragment dictionary, then apply it to that specific
#       domain using addDateFrag
# TODO: (see individual functions for TODO list) 
#       Change hard coding of vstestCatOutcome to the value of byCol (the sol
#            is nonobvious!)
#______________________________________________________________________________


# createDateDict() ----
#   Create a translation table of dates to date fragments
#  All dates from across both DM and VS domains. 
#  TODO: 
#    Add additional domains as project scope expands. Make function flexible
#    to accept these as arguments instead of hard coded.
#' Title
#'
#' @return
#' @export
#'
#' @examples
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
    addStatement(cdiscpilot01, 
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, dateDict$dateFrag),
        predicate = paste0(STUDY, "dateTimeInXSDString" ),
        object    = paste0(dateDict$dateKey),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))

    addStatement(cdiscpilot01, 
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, dateDict$dateFrag),
        predicate = paste0(RDFS,"label" ),
        object    = paste0(dateDict$dateKey),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))
  })
  return(dateDict)
}

# Merge in the dateKey value to created a coded version of the date field, naming
#  the column with a _Frag suffix.
#' Title
#'
#' @param domainName 
#' @param colName 
#'
#' @return
#' @export
#'
#' @examples
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

#  createFragOneDomain() ----
#  Create URI fragments for coded values in a single or mutliple column. 
#    - If more than one column, combine values into a single column to process
#    - Create numeric index the unique values
#    - Create a coded value that includes that index number (_<n>)
#    - Merge indexed IRI fragment back into the source data column(s)
#    - Use the fragment in the process<DOMAIN>.R scripts to construct IRIs
#  domainName   = A single, source domain dataset. Eg: dm, vs, ...
#  processColumns = names of one of more columns for the source values
#           E.g.: processColumns=c("DIABP", "SYSBP"),
#  fragPrefix   = a prefix used in both the new column name for 
#           the fragments and the fragment value itself. 
#  numSort    = FALSE/TRUE  . Specify as TRUE to sort a numeric series of
#           values, like a blood pressure.
#    Examples: column: actarm_frag, has values: actarm_1, actarm_3...
#  Note: original source data has columns actarmcd, armcd. The 'cd'  
#     is not needed in the RDF context, so drop that part of the name
#' Title
#'
#' @param domainName 
#' @param processColumns 
#' @param fragPrefix 
#' @param numSort 
#'
#' @return
#' @export
#'
#' @examples
createFragOneDomain<-function(domainName, processColumns, fragPrefix, numSort=FALSE)
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
  uniques <<- na.omit(uniques)
  
  # SORT
  # Sort method depends on whether the values are character or numeric.
  # Sort by values. Prev code: Use dplyr arrange instead of order/sort to avoid loss of df type
  uniqueVals <- as.data.frame(uniques)
  uniqueVals <<- na.omit(uniqueVals)
  
  # if(is.numeric(uniqueVals[1,1])) {
  # if (regexpr(uniqueVals[1,1], "\\d", perl=TRUE)){
  if(numSort){
    # Numbers. Convert and sort. 
    # Convert first to character, then to numeric. Otherwise get the order according to the factors.
    sorted.uniqueVals <<-data.frame( uniqueVals[order(as.numeric(as.character(uniqueVals$uniques))), ])
  } else {
    # Characters
    sorted.uniqueVals <<- data.frame(uniqueVals[order(as.character(uniqueVals$uniques)), ])
  }
  colnames(sorted.uniqueVals) <- "keyVal" 
  sorted.uniqueVals <-na.omit(sorted.uniqueVals)
  # Create the coded value for each unique value as <value_n> 
  sorted.uniqueVals$valFrag <- paste0(fragPrefix,"_", 1:nrow(sorted.uniqueVals))   # Generate a list of ID numbers
  
  valDict <<- sorted.uniqueVals[,c("keyVal", "valFrag")]
  
  # Merge in the keyVals value to created a coded version of the value field, naming
  #  the column with a _Frag suffix.
  for (i in processColumns) {
    domainName <- merge(x = valDict, y = domainName, by.x="keyVal", by.y=i, all.y = TRUE)
    # Rename the merged-in key value to the original column name to preserve original data
    names(domainName)[names(domainName)=="keyVal"] <-  i
    # Rename valFrag value to coded value using processColumn +  _Frag suffix
    names(domainName)[names(domainName)=="valFrag"] <- paste0(i, "_Frag")
  } 
   return(domainName)
}

#' Title
#'
#' @param domainName  - domain dataframe 
#' @param dataCol     - column containing the data to indexed (Eg: vsorres)
#' @param byCol       - column containing the 'by variable" within with to index (eg vsTestCat)
#' @param fragPrefixName - prefix used to name the output column for the fragmant values created in this fnt
#'                     Eg:  vstestCat = BloodPressureOutcome, PulseHROutcome
#' @param numSort  - TRUE/FALSE to sort the data prior to indexing it. ** NOT CURRENTLY IMPLEMENTED
#'
#' @return
#' @export
#'
#' @examples
#'    createFragOneColByCat(domainName=vs, dataCol=vsorres, byCol=vsTestCat, fragPrefixName=vsTestCat, numSort=TRUE)
#'    vsTest <- createFragOneColByCat(domainName=vsTest, dataCol="vsorres", byCol="vstestCat", fragPrefixName="vstestCat")    
#'    
#' PROBLEM:Only works for vsorres_Frag and one SDTM frag due to hard coding in the function.
#           TODO: fix this with some grown up, big boy code.

createFragOneColByCat<-function(domainName, byCol, dataCol, fragPrefixName, numSort=TRUE)
{
  temp <- domainName[,c(byCol, dataCol)]

  temp2 <- temp[!duplicated(temp), ]
  # sort by category, data column value
  # temp2 <- temp2[ order(temp2[,1], temp2[,2]), ]
  # temp2 <- temp2[ order(temp2[,byCol], temp2[,dataCol]), ]
  # https://stackoverflow.com/questions/26497751/pass-a-vector-of-variable-names-to-arrange-in-dplyr
  
  # Create a numeric version of the dataCol for sorting purposes
  
  # Coerce the dataCol to numeric, otherwise sorting will fail.
  # A new variable is used here because if you convert it in place, the merge back into teh original
  #   dataset will likely
  #TODO: Make this conditional on numSort==TRUE
  if (numSort == TRUE){
    temp2$dataCol_N <- as.numeric(as.character(temp2[,2]))
    temp2 <- temp2[ order(temp2[,1], temp2[,"dataCol_N"]), ]
  }
  # Ordering the df does not change the row number so create a new index for use
  #   in the later mutate statement.
  temp2$rowID <- 1:nrow(temp2)
  
  # temp2 <- temp2 %>% arrange_(.dots = c(byCol, dataCol)) # Try this: arrange_(.dots=c("var1","var3"))
  
  # temp2 <- arrange_(temp2, byCol, -dataCol)
  # temp2 <- temp2[ order(temp2[, !!byCol], temp2[, !!dataCol]), ]
  # Create the new column named based on the input column name by appending
  #  "_Frag" to the value of the the dataCol parameter
  varname <- paste0(fragPrefixName, "_Frag")

  byColName <<- byCol

  # Note use of !! to resolve the value of varname created above and assign
  #   a value to it using :=
  # Kludge due to inability to resolve the byCol value within seq_along and mutate.
  #     Need someone with R Expertise to make this resolved correctly!
    if (byCol=="vstestCatOutcome"){
    temp2 <- temp2 %>% group_by_(byCol) %>% mutate(id = seq_along(vstestCatOutcome))%>% 
      mutate( !!varname := paste0(vstestCatOutcome,"_", id)) 
  }
  else if (byCol=="vstestSDTMCode"){
    temp2 <- temp2 %>% group_by_(byCol) %>% mutate(id = seq_along(vstestSDTMCode))%>% 
      mutate( !!varname := paste0(vstestSDTMCode,"_", id)) 
  }
  # This gives ROW NUMBER and not correct numbering within a category
  #temp2 <- temp2 %>% group_by_(byCol) %>% mutate(id = rowID)%>% 
  #  mutate( !!varname := paste0(vstestCat,"_", id)) 
  
  # Remove the ID variable and the numeric rep. of the data col. 
  temp2 <- temp2[,!(names(temp2) %in% c("id", "dataCol_N"))]
  
  # Merge the fragment value back into the original data
  withFrag <<- merge(domainName, temp2, by = c(byCol, dataCol), all.x=TRUE)

}