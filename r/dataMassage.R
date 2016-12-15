###############################################################################
# FILE : dataMassage.R
# DESCR: Massage the data as needed for the prototype.
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

# Add the id var "Peson_<n>" for each HumanStudySubject observation 
id<-1:(nrow(masterData))   # Generate a list of ID numbers
masterData$pers<-paste0("Person_",id)  # Defines the person identifier as Person_<n>

#---- Data Massage
#-- Create values not in the source that are required for testing or for later 
#      versions of SDTM.
# TODO: Move data massage/fabrication to separate R Script.
# Birthdate 
masterData$brthdate <- strptime(masterData$rfstdtc, "%m/%d/%Y") - (strtoi(masterData$age) * 365 * 24 * 60*60)

# Informed Consent  (column present with missing values in DM source).
masterData$rficdtc <- masterData$dmdtc

#-- Create Data required for prototyping
# Investigator name and ID not present in source data
masterData$invnam <- 'Jones'
masterData$invid  <- '123'
