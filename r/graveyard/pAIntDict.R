###############################################################################
# FILE: pAIntDict.R
# DESC: Create a dicitionary table for the Product Administration Interval
#         Each unique combination of start (rfxstdtc) plus end (rfxendtc) gets 
#         a unique fragment (prodAdminFrag) that will be attached to each Person
#      pAInt  - (dm) concatenation of rfxstdtc and rfxendtc for merging 
#      PAIntKey  - concatenation of of rfxstdtc and rfxendtc for merging 
#      PAIntFrag - the fragment to form the product Administration URI 
# REQ :
#       
# SRC : 
# IN  : 
# OUT : 
# NOTE: Product Admin is NOT handled in this way as of 2017-02-14. S
#        Serves only as an example of how to combine fields to create a unique 
#        URI fragment.
#                
#       dm$pAInt is created to allow merging of the product administration URI
#        back into the dm dataframe. It serves no other purpose.
#        
# TODO: 
###############################################################################

dm$pAInt <- paste0(dm$rfxstdtc, dm$rfxendtc)

# The single column of values for product administration. 
pAIntKey <- dm$pAInt

pAIntList <-as.data.frame(pAIntKey)

# Remove duplicates
pAIntList <- unique(pAIntList
                  )
# Remove missing(blank) values by coding to NA and them omitting
pAIntList[pAIntList==""] <- NA
pAIntList <- na.omit(pAIntList)

# Sort using  dplyr arrange instead of order to avoid loss of df type
pAIntList <- arrange(pAIntList, pAIntKey)

# Create the coded value 
pAIntList$pAIntFrag <- paste0("ProductAdministration_", 1:nrow(pAIntList))   # Generate a list of ID numbers

pAIntDict <- pAIntList[,c("pAIntKey", "pAIntFrag")]

# Merge in the Key value to created a coded version of the value field, naming
#    the column with a _Frag suffix.
addPAIntFrag<-function(domainName, colName)
{
    withFrag <- merge(x = pAIntDict, y = domainName, by.x="pAIntKey", by.y=colName, all.y = TRUE)
    # Rename the merged-in key value to the original column name to preserve original data
    names(withFrag)[names(withFrag)=="pAIntKey"] <-  colName
    # Rename Frag value to coded value using colname +  _Frag suffix
    names(withFrag)[names(withFrag)=="pAIntFrag"] <- paste0(colName, "_Frag")
    return(withFrag)
}

# Add the value Fragment back into the DM dataframe.
dm <- addPAIntFrag(dm, "pAInt")  
