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
# Create the Person ID (Person_(n)) in the DM dataset for looping through the data by Person  
#     across domains when creating triples
id<-1:(nrow(dm))   # Generate a list of ID numbers
dm$personNum<- id

# Create an merge Index file for the other domains.
personId <- dm[,c("personNum", "usubjid")]

# Values not in original source data ----
# ** Create ----
dm$invnam <- 'Jones'
dm$invid  <- '123'
dm$inv    <- 'Investigator_1'
dm$rand   <- 'RandomizationBAL3'
dm$study  <- "Study_1"  # Must change when >1 study in triplstore!

# ** Impute ----
#---- Birthdate : asbsent in source data
# NOTE: Date calculations based on SECONDS so you must convert the age in Years to seconds
#      Change to character to avoid later ddply problem in DM_process.R
#      Dates reflect their original mixed format of DATE or DATETIME in same col.
dm$brthdate <- as.character(strptime(strptime(dm$rfstdtc, "%Y-%m-%d") - (strtoi(dm$age) * 365.25 * 24 * 60 * 60), "%Y-%m-%d"))
#---- Informed Consent  (column present with missing values in DM source).  
dm$rficdtc <- dm$dmdtc

# Death Date and Flag set for Person 1 for testing purposes only. 
#   Will not match original source data! (no deaths)
# Unfactorize the dthdtc column to allow entry of a bogus date
dm$dthdtc <- as.character(dm$dthdtc)
dm$dthdtc[dm$personNum == 1 ] <- "2013-12-26"  # Death Date
dm$dthfl[dm$personNum == 1 ]  <- "Y" # Set a Death flag  for Person_1