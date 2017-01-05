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
masterData$brthdate <- strptime(strptime(masterData$rfstdtc, "%Y-%m-%d") - (strtoi(masterData$age) * 365 * 24 * 60 * 60), "%Y-%m-%d")

# Informed Consent  (column present with missing values in DM source).
masterData$rficdtc <- masterData$dmdtc

#-- Create Data required for prototyping
# Investigator name and ID not present in source data
masterData$invnam <- 'Jones'
masterData$invid  <- '123'




# Set Death values for Person_1
masterData$dthfl[masterData$pers == "Person_1" ] <- "Y"

# unfactorize the dthdtc column to allow entry of a bogus date
masterData$dthdtc <- as.character(masterData$dthdtc)

temp <-as.Date("2013-12-26", "%Y-%m-%d")
masterData$dthdtc[masterData$pers == "Person_1" ] <- "2013-12-26"
