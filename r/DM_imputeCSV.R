#______________________________________________________________________________
# FILE: DM_imputeCSV.R
# DESC: Creates data values required for prototyping and ontology develeopment
# REQ : Prior import of the DM domain by driver script XPTtoCSV.R
# SRC : N/A
# IN  : dm dataframe 
# OUT : modified dm dataframe 
# NOTE: Columns that created that are not usually in SDTM are prefixed with im_
#       Eg: im_lifespan  - for lifespan IRI creation
#           im_sdtmterm  - to link to SDTM terminlology
#           brthdate  - no im_ prefix because this is often collected in SDTM.
# TODO: 
#______________________________________________________________________________

# Imputations ----
#---- Birthdate : asbsent in source data
# NOTE: Date calculations based on SECONDS so you must convert the age in Years to seconds
#      Change to character to avoid later ddply problem in DM_process.R
#      Dates reflect their original mixed format of DATE or DATETIME in same col.
dm$brthdate <- as.character(strptime(strptime(dm$rfstdtc, "%Y-%m-%d") - (strtoi(dm$age) * 365.25 * 24 * 60 * 60), "%Y-%m-%d"))

#---- Informed Consent  (column present with missing values in DM source).  
dm$rficdtc <- dm$dmdtc   # Confirm this is not in the new Test Data factory version. 

# Death Date and Flag set for Person 1 for testing purposes only. 
#   Will not match original source data! (no deaths)
# Unfactorize the dthdtc column to allow entry of a bogus date
dm$dthdtc <- as.character(dm$dthdtc)
dm$dthdtc[dm$usubjid == '01-701-1015' ] <- "2013-12-26"  # Death Date
dm$dthfl[dm$usubjid == '01-701-1015' ]  <- "Y" # Set a Death flag  for Person_1




dm$lifeSpan_im     <- paste0(dm$brthdate, "_", dm$dthdtc)
dm$refInt_im       <- paste0(dm$rfstdtc,  "_", dm$rfendtc)
dm$studyPartInt_im <- paste0(dm$dmdtc,    "_", dm$rfpendtc)


#------------------------------------------------------------------------------
# URL encoding
#   Encode fields  that may potentially have values that violate valid IRI format
#   Function is in Functions.R
# TODO: Change function to loop over a list of variables instead of 1 call per each 
#
dm <- encodeCol(data=dm, col="age")
dm <- encodeCol(data=dm, col="brthdate")
dm <- encodeCol(data=dm, col="dmdtc")
dm <- encodeCol(data=dm, col="dthdtc")
dm <- encodeCol(data=dm, col="ethnic")
dm <- encodeCol(data=dm, col="race")
dm <- encodeCol(data=dm, col="rfendtc")
dm <- encodeCol(data=dm, col="rficdtc")
dm <- encodeCol(data=dm, col="rfpendtc")
dm <- encodeCol(data=dm, col="rfstdtc")

dm <- encodeCol(data=dm, col="lifeSpan_im")
dm <- encodeCol(data=dm, col="refInt_im")    
dm <- encodeCol(data=dm, col="studyPartInt_im")

# Sort column names in the df for quicker referencing
dm <- dm %>% select(noquote(order(colnames(dm))))


