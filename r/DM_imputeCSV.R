#______________________________________________________________________________
# FILE: DM_impute.R
# DESC: Impute data required for prototyping. Creates data values. 
# REQ : Prior import of the DM domain by driver script.
# SRC : N/A
# IN  : dm dataframe 
# OUT : modified dm dataframe 
# NOTE: 
#       URI fragments are created in DM_frag.R
#       Coded values:  - cannot have spaces or special characters.
#                      - are stored in variables with under suffix _ while 
#                          originals are retained.
# TODO: 
#______________________________________________________________________________

# ** Impute ----
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