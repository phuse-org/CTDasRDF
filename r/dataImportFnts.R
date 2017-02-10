###############################################################################
# FILE: dataImpport.R
# DESC: Data Import Functions called when importing the domains. 
#       readXPT() - read the requestd XPT file
#       addPersonId() - adds the ID created from DM data to domain being processed
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: Creates the numeric personNum : index variable for each person in the
#       DM domain, used when iterating through and across domains when building 
#       the triples for each person.
# TODO: 
###############################################################################

#------------------------------------------------------------------------------
# readXPT()
# Read the requested domains into dataframes for processing.
# TODO: Consider placing in separate Import.R script called by this driver.
readXPT<-function(domain)
{
    sourceFile <- paste0("data/source/", domain, ".XPT")
    result <- sasxport.get(sourceFile)

    result  # return the dataframe
}
#------------------------------------------------------------------------------
# addpersonId()
# Merge the personId into the other domains to allow later looping during triple creation. 
addPersonId<-function(domainName)
{
    withIndex <- merge(x = personId, y = domainName, by="usubjid", all.x = TRUE)
    return(withIndex)
}