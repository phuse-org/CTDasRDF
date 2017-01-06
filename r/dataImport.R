###############################################################################
# FILE : dataImpport.R
# DESCR: Data Imoport Functions called when importing the domains. 
#        readXPT() - read the requestd XPT file
#        
# SRC  : 
# KEYS : 
# NOTES: Creates the numeric personNum : index variable for each person in the
#           DM domain, used for iterating through and across domains, building the
#           the triples for each person.
#        
# INPUT: 
#      : 
# OUT  : Calls dataCreate.R
# FNT  : readXPT - reads XPT files 
# REQ  : Called from buildRDF-Driver.R
# TODO : Move domain-specific code like DM and VS work to their respective scripts:
#         processDM.R , processVS.R (above the function calls.)
###############################################################################

#------------------------------------------------------------------------------
#  readXPT()
#      Read the requested domains into dataframes for processing.
# TODO: Consider placing in separate Import.R script called by this driver.
readXPT<-function(domain)
{
    # resultList <- vector("list", length(domains)) # initialize vector to hold dataframes
    # for (i in seq(1, length(domains))) {
    sourceFile <- paste0("data/source/", domain, ".XPT")
        # resultList[[i]]<-sasxport.get(sourceFile)
        # Each domain assembled into resultList by name "dm", "vs" etc.
      # resultList[[domains[i]]]<-sasxport.get(sourceFile)
      result <- sasxport.get(sourceFile)
    #}
    # resultList # return the dataframes from the function
    result  # return the dataframe
    #TODO Merge the multiple SDTM Domains into a single Master dataframe.
}

# Access individual dataframes based on name:  domainsDF["vs"], etc.
#DEL  domainsDF<-readXPT(c("dm", "vs")) 

#------------------------------------------------------------------------------
# addpersonId()
#-- Merge the personId into the other domains to allow later looping during triple creation. 
#-- vs domain subset down to the test population specified in the dm subsetting.

#
addpersonId<-function(domainName)
{
    withIndex <- merge(x = personId, y = domainName, by="usubjid", all.x = TRUE)
    return(withIndex)
}

