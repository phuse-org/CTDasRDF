###############################################################################
# FILE: VS_impute.R
# DESC: Impute data required for prototyping. 
# REQ : Prior import of the VS domain by driver script.
# SRC : N/A
# IN  : vs dataframe 
# OUT : modified vs dataframe 
# NOTE: 
# TODO: 
###############################################################################
vs <- addPersonId(vs)

##-----------------   DEV/TESTING ONLY  ---------------------------------------
# SUBSET THE DATA DOWN TO A SINGLE PATIENT AND SUBSET OF TESTS FOR DEVELOPMENT PURPOSES
vs <- subset(vs, (personNum==1 
                  & vstestcd %in% c("DIABP", "SYSBP") 
                  # & visit %in% c("SCREENING 1", "SCREENING 2")))
                  & visit %in% c("SCREENING 1")))  # Subset further down to match AO data: 09May2017



#-- Data Imputation for Prototype Testing ---------------------------------------
# More imputations for the first 3 records to match data created by AO : 2016-01-19
#   These are new COLUMNS and values not present in original source!
vs$vsgrpid <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "GRPID1", "" )) 
vs$vscat   <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "CAT1", "" )) 
vs$vsscat  <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "SCAT1", "" )) 
vs$vsreasnd <- with(vs, ifelse(vsseq %in% c(1) & personNum == 1, "not applicable", "" )) 

# vsspid
vs[vs$vsseq %in% c(1), "vsspid"]  <- "123"
vs[vs$vsseq %in% c(2), "vsspid"]  <- "719"
vs[vs$vsseq %in% c(3), "vsspid"]  <- "235"

# vs[1:3,grep("vsstat", colnames(vs))] <- "CO"  (complete)
# Unfactorize the  column to allow entry of a bogus data
vs$vsstat <- as.character(vs$vsstat)
# vs[1,grep("vsstat", colnames(vs))] <- "CO"
#  Set all to a status of completed. TODO: Add other values for testing purposes.
vs[,"vsstat"] <- "CO"

# fragment for coded value. Links from CDISCPILOT01 to CODE namespace
#vs$vsstat_Frag <- recode(vs$vsstat, 
#                         "'CO'         = 'activitystatus_1';
#                          'ND'         = 'activitystatus_2' 
#                         " )




#---- vsloc  for DIABP, SYSBP all assigned as 'ARM' for development purposes.
# Unfactorize the  column to allow entry of a bogus data
vs$vsloc <- as.character(vs$vsloc)
vs$vsloc <- vs$vsloc[vs$testcd %in% c("DIABP", "SYSBP") ] <- "ARM"

# vslat
vs[vs$vsseq %in% c(1,3), "vslat"]  <- "RIGHT"
vs[vs$vsseq %in% c(2), "vslat"]    <- "LEFT"

vs[vs$vsseq %in% c(1), "vsblfl"]    <- "Y"

vs$vsdrvfl <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "N", "" )) 

# Investigator ID hard coded. Same value as in DM_impute.R
vs$invid  <- '123'

# Assign 1st 3 obs as COMPLETE to match AO ontology
vs$vsstat <- as.character(vs$vsstat) # Unfactorize to all allow assignment 

vs$vsrftdtc <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "2013-12-16", "" )) 

# -- Additional Value creation
# Create an extra row of data that is used to create values not present in the orignal
#   subset of data. The row is used to create codelists, etc. dynamically during the script run
#   as an alternative to hard coding, since these values are not associated within any one subject
#   in the subset. The values likely are part of the larger set.
# Add new rows of data used to create code lists for categories missing in 
#    the original test data.
temprow <- matrix(c(rep.int(NA,length(vs))),nrow=1,ncol=length(vs))
# Convert to df with  cols the same names as the original (vs) df
newrow <- data.frame(temprow)
colnames(newrow) <- colnames(vs)

# rbind the empty row back to original df
vs <- rbind(vs,newrow)

# now populate the values in the last row of the data
vs[nrow(vs),"vsstat"]   <- 'ND'  # add the ND value for creating activitystatus_2. Found later in the orginal data
