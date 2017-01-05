###############################################################################
# FILE : dataCreate.R
# DESCR: Create data values and columns as needed for testing code. 
#        Does not include RECODING/CODing based on existing fields.
# SRC  : 
# KEYS : 
# NOTES: 
#        
# INPUT: 
#      : 
# OUT  : 
# REQ  : Called from buildRDF-Driver.R
# TODO : 
###############################################################################

# Birthdate 
# NOTE: Date calculations based on SECONDS so you must convert the age in Years to seconds
dm$brthdate <- strptime(strptime(dm$rfstdtc, "%Y-%m-%d") - (strtoi(dm$age) * 365.25 * 24 * 60 * 60), "%Y-%m-%d")
# AO's formula: BRTHDTC = RFSTDTC - AGE x 365.25   


# Informed Consent  (column present with missing values in DM source).
dm$rficdtc <- dm$dmdtc

#-- Create Data required for prototyping
# Investigator name and ID not present in source data
dm$invnam <- 'Jones'
dm$invid  <- '123'


# Set Death values for Person_1
dm$dthfl[dm$personNum == 1 ] <- "Y"

# unfactorize the dthdtc column to allow entry of a bogus date
dm$dthdtc <- as.character(dm$dthdtc)

temp <-as.Date("2013-12-26", "%Y-%m-%d")
dm$dthdtc[dm$personNum == 1 ] <- "2013-12-26"
