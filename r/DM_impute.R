###############################################################################
# FILE: DM_impute.R
# DESC: Impute data required for prototyping. Creates data values. 
#       URI fragments are created in DM_frag.R
# REQ : Prior import of the DM domain by driver script.
# SRC : N/A
# IN  : dm dataframe 
# OUT : modified dm dataframe 
# NOTE: Does NOT include URI fragment creation, which relies on multiple domains.
# TODO: 
###############################################################################
# Create the Person ID (Person_(n)) in the DM dataset for looping through the data by Person  
#     across domains when creating triples
id<-1:(nrow(dm))   # Generate a list of ID numbers
dm$personNum<- id

# Create an merge Index file for the other domains.
personId <- dm[,c("personNum", "usubjid")]

#---- Investigator name and ID not present in original source data
dm$invnam <- 'Jones'
dm$invid  <- '123'
dm$invid_Frag  <- 'Investigator_1'

#---- Birthdate : asbsent in source data
# NOTE: Date calculations based on SECONDS so you must convert the age in Years to seconds
#      Change to character to avoid later ddply problem in DM_process.R
#      Dates reflect their original mixed format of DATE or DATETIME in same col.
dm$brthdate <- as.character(strptime(strptime(dm$rfstdtc, "%Y-%m-%d") - (strtoi(dm$age) * 365.25 * 24 * 60 * 60), "%Y-%m-%d"))
#---- Informed Consent  (column present with missing values in DM source).  
dm$rficdtc <- dm$dmdtc

# Unfactorize the dthdtc column to allow entry of a bogus date
dm$dthdtc <- as.character(dm$dthdtc)
dm$dthdtc[dm$personNum == 1 ] <- "2013-12-26"  # Death Date
dm$dthfl[dm$personNum == 1 ] <- "Y" # Set a Death flag  for Person_1

# DELETED THE FOLLOWING SINCE CODE LIST GENERATION IS NOT PART OF THE CURRENT REMIT,
# WHICH is focussed soley on CDISCPILOT01-R.TTL. Not CODE.TTL, etc. at this time.

# -- Additional Value creation# Create an extra row of data that is used to create values not present in the orignal
#   subset of data. The row is used to create codelists, etc. dynamically during the script run
#   as an alternative to hard coding, since these values are not associated within any one subject
#   in the subset. The values likely are part of the larger set.
#   Add an new row to the DM dataframe to contain information needed for development
# SAUCE: https://gregorybooma.wordpress.com/2012/07/18/add-an-empty-column-and-row-to-an-r-data-frame/
#   Create a one-row matrix the same length as data
#temprow <- matrix(c(rep.int(NA,length(dm))),nrow=1,ncol=length(dm))
 
# Convert to df with  cols the same names as the original (dm) df
#newrow <- data.frame(temprow)
#colnames(newrow) <- colnames(dm)
 
# rbind the empty row back to original df
#dm <- rbind(dm,newrow)
 
# Populate the values in the last row of the data
#dm[nrow(dm),"arm"]   <- 'Screen Failure'
#dm[nrow(dm),"armcd"] <- 'Scrnfail'


