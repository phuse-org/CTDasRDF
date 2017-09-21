#______________________________________________________________________________
# FILE: misc_F.R
# DESC: Miscellaneous functions including: 
#     readXPT() - read the requestd XPT file
#     addPersonId() - adds the ID created from DM data to domain being processed
#     assignDateType()
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: 
# TODO:  
#______________________________________________________________________________

# readXPT() ----
# Read the requested domains into dataframes for processing.
#' Title
#'
#' @param domain 
#'
#' @return
#' @export
#'
#' @examples
readXPT<-function(domain)
{
  sourceFile <- paste0("data/source/", domain, ".XPT")
  result <- sasxport.get(sourceFile)
  result  # return the dataframe
}

# addpersonId() ----
# Creates the numeric personNum:index variable for each person in the
#   DM domain, used when iterating through and across domains when building 
#   the triples for each person.
# Merge the personId into the other domains to allow later looping during triple creation. 
#' Title
#'
#' @param domainName 
#'
#' @return
#' @export
#'
#' @examples
addPersonId <- function(domainName)
{
  withIndex <- merge(x = personId, y = domainName, by="usubjid", all.x = TRUE)
  return(withIndex)
}


# assignDateType() ----
#   Add 'Date Type Triple" to an existing  Date_(n) to describe a specific date URI
#   Identifies that various types of things attached to a date. A single date 
#     can be attached to many types: InformedConsentBegin, a DPB Measure,
#     a study death, etc.
#   dateVal  - date value string variable.  Eg: dm$brthdate
#   dateFrag - date URI fragment variable. Eg: dm$brthdate_Frag
#       date URI fragments are used to create date object URI
#   dateType - the class type for that date. Eg: Birthdate.  Must correspond
#       to class names in the ontology.

#' Assign Date Types to Date Value
#'
#' Each date Object value 
#' @param dateVal 
#' @param dateFrag 
#' @param dateType 
#'
#' @return
#' @export
#'
#' @examples
assignDateType <- function(dateVal, dateFrag, dateType)
{
  #---- Date triples
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, dateFrag),
    paste0(prefix.RDF,"type" ),
    paste0(prefix.STUDY, dateType)
  )
 
}  