#______________________________________________________________________________
# FILE: VS_impute.R
# DESC: Impute data required for prototyping. 
# REQ : Prior import of the VS domain by driver script.
# SRC : N/A
# IN  : vs dataframe 
# OUT : modified vs dataframe 
# NOTE: 
# TODO: 
#______________________________________________________________________________

# Subset VS data for Dev purposes
# SUBSET THE DATA DOWN TO A SINGLE PATIENT AND SUBSET OF TESTS FOR DEVELOPMENT PURPOSES
#  All for Person 1, Screening 1
# Row     Data
# 1:3     DIABP
# 86:88   SYSBP
# 43      Ht
# 44:46   Pulse
# 128     Temp
# 142     Wt

# Person 1 Baseline
#  7

# Person 1 Week 2
# 13

# Person 1 Week 24
# 37

vsSubset <-c(1:3, 86:88, 43, 44:46, 128, 142, 7, 13, 37)

# vs <- vs[c(1:3, 86:88, 43, 44:46, 128, 142, 7), ]
vs <- vs[vsSubset, ]
#DEL vs <- vs[c(1:3, 86:88, 43, 44:46, 128, 142, 7, 13, 37), ]
vs <- addPersonId(vs)  # Add personNum for merge across domains, triple creation

# personNum
# TODO: Add a later count/merge with DM.
#  Must be present for later imputations.
# vs[vs$usubjid  %in% c("01-701-1015"),  "personNum"]  <- 1
#DEL vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142,
#DEL   7,13,37),  "personNum"]  <- 1

# More imputations for the first 3 records to match data created by AO : 2016-01-19
#   These are new COLUMNS and values not present in original source!
# vs$vsgrpid  <- with(vs, ifelse(vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & personNum == 1, "GRPID1", "" )) 

#Note: Not full susbset: removed 44,45,46 on 19Oct17 to match new data from AO
vs[vs$vsseq %in% c(1,2,3,43,86,87,88,128,142) & vs$personNum == 1,  "vsgrpid"]  <- "GRPID1"
# vscat
vs[vs$vsseq %in% c(1,2,3,43,86,87,88,128,142) & vs$personNum == 1,  "vscat"]  <- "CAT1"

# vsscat
vs[vs$vsseq %in% c(1,2,3,43,86,87,88,128,142) & vs$personNum == 1,  "vsscat"]  <- "SCAT1"

# vsspid
vs[vs$vsseq %in% c(1)   & vs$personNum == 1, "vsspid"]  <- "123"
vs[vs$vsseq %in% c(2)   & vs$personNum == 1, "vsspid"]  <- "719"
vs[vs$vsseq %in% c(3)   & vs$personNum == 1, "vsspid"]  <- "235"
vs[vs$vsseq %in% c(43)  & vs$personNum == 1, "vsspid"]  <- "1000"
#TW vs[vs$vsseq %in% c(44)  & vs$personNum == 1, "vsspid"]  <- "125"
#TW vs[vs$vsseq %in% c(45)  & vs$personNum == 1, "vsspid"]  <- "721"
#TW vs[vs$vsseq %in% c(46)  & vs$personNum == 1, "vsspid"]  <- "237"
vs[vs$vsseq %in% c(86)  & vs$personNum == 1, "vsspid"]  <- "124"
vs[vs$vsseq %in% c(87)  & vs$personNum == 1, "vsspid"]  <- "720"
vs[vs$vsseq %in% c(88)  & vs$personNum == 1, "vsspid"]  <- "236"
vs[vs$vsseq %in% c(128) & vs$personNum == 1, "vsspid"]  <- "3000"
vs[vs$vsseq %in% c(142) & vs$personNum == 1, "vsspid"]  <- "5000"

#vsstat
vs$vsstat <- as.character(vs$vsstat) # factor correction
#DEL vs[vs$vsseq %in% c(1, 2, 3, 43, 44, 45, 46, 86, 87, 88, 128, 142,
#DEL   7, 13, 37) & vs$personNum == 1, "vsstat"] <- "CO"
vs[vs$vsseq %in% vsSubset & vs$personNum == 1, "vsstat"] <- "CO"

# vsreasnd
# Not full subset!
vs[vs$vsseq %in% c(1,2,3,43,86,87,88,128,142) & vs$personNum == 1, "vsreasnd"]  <- "not applicable"

# vsloc
vs$vsloc <- as.character(vs$vsloc)  # factor correction
vs[vs$vsseq %in% c(1,2,3,86,87,88) & vs$personNum == 1, "vsloc"]  <- "ARM"

# vslat
vs[vs$vsseq %in% c(1,3,86,88)  & vs$personNum == 1, "vslat"] <- "RIGHT"
vs[vs$vsseq %in% c(2,87) & vs$personNum == 1, "vslat"]          <- "LEFT"

#TW removed 44,45,46 to match new data from AO 19Oct17
vs[vs$vsseq %in% c(1,2,3,43,86,87,88,128,142) & vs$personNum == 1, "vsblfl"]  <- "Y"

# Derived Flag Y/N ----
vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & vs$personNum == 1, "vsdrvfl"] <- "N"

# invid Same value as in DM_impute.R
vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & vs$personNum == 1, "invid"] <- "123"

# vsrftdtc
vs[vs$vsseq %in% c(1,2,3,86,87,88) & vs$personNum == 1, "vsrftdtc "] <- "2013-12-16"

# Create ND value not in original data
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
# vs[nrow(vs),"vsstat"]   <- 'ND'  # add the ND value for creating activitystatus_2. Found later in the orginal data
# vsstat
# vs[vs$vsseq %in% c(n,n,n,n,n) & personNum == 1, "vsstat"] <- "ND"