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

    # Original Subset VS data to match ontology instance data. 
    #  Now replaced by subsetting by usubjid
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
    #  row 7
    
    # Person 1 Week 2
    # row 13
    
    # Person 1 Week 24
    # row 37
     #TODO: REMOVE THIS    
     #vsSubset <-c(1:3, 86:88, 43, 44:46, 128, 142, 7, 13, 37)
     #vs <- vs[vsSubset, ]

vs <- addPersonId(vs)  # Add personNum for merge across domains, triple creation

# NEW Imputations ----
# Imputations corrected for use on all new data, based on values in other fields, 
#   not on row numbers.
# vsloc
vs$vsloc <- as.character(vs$vsloc)  # factor correction
#OLDE vs[vs$vsseq %in% c(1,2,3,86,87,88) & vs$personNum == 1, "vsloc"]  <- "ARM"
vs[vs$vstestcd %in% c('DIABP', 'SYSBP'), "vsloc"]  <- "ARM"

#vsstat
vs$vsstat <- as.character(vs$vsstat) # factor correction
#OLDE vs[vs$vsseq %in% vsSubset & vs$personNum == 1, "vsstat"] <- "CO"
vs$vsstat <- "CO"  # all results hard coded to Complete.

# vsreasnd
# Change make dependent on presence/absence of a result value.
#OLDE vs[vs$vsseq %in% c(1,2,3,43,86,87,88,128,142) & vs$personNum == 1, "vsreasnd"]  <- "not applicable"
vs$vsreasnd <- "not applicable"  # All Reason Not Done coded to not applicable.

# Derived Flag Y/N ----
# vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & vs$personNum == 1, "vsdrvfl"] <- "N"
vs$vsdrvfl <- "N"  # None of the measurements here are derived: BP,HT,WT,TEMP...

#OLDE vs[vs$vsseq %in% c(1,2,3,43,86,87,88,128,142) & vs$personNum == 1, "vsblfl"]  <- "Y"
vs[vs$visit %in% c('SCREENING 1', 'BASELINE'), "vsblfl"]  <- "Y"

# invid set to same value as hard coded for DM in DM_impute.R
#OLDE vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & vs$personNum == 1, "invid"] <- "123"
vs$invid <- "123"  # Later change to base on set of subjid or site or...?

# vsrftdtc
#OLDE vs[vs$vsseq %in% c(1,2,3,86,87,88) & vs$personNum == 1, "vsrftdtc "] <- "2013-12-16"
vs$vsrftdtc <- vs$vsdtc  #TW: Confirm with AO





#---------------------------------------------------------------------------------------------
# OLD imputations ----
#TODO:  New logic for the imputations below.

# More imputations for the first 3 records to match data created by AO : 2016-01-19
#   These are new COLUMNS and values not present in original source!
# vs$vsgrpid  <- with(vs, ifelse(vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & personNum == 1, "GRPID1", "" )) 

#Note: Not full susbset: removed 44,45,46 on 19Oct17 to match new data from AO
#vsgrpid
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
#TW vs[vs$vsseq %in% c(44)  & vs$personNum == 1, "vsspid"]  <- "125"  # removed
#TW vs[vs$vsseq %in% c(45)  & vs$personNum == 1, "vsspid"]  <- "721"  # removed
#TW vs[vs$vsseq %in% c(46)  & vs$personNum == 1, "vsspid"]  <- "237"  # removed
vs[vs$vsseq %in% c(86)  & vs$personNum == 1, "vsspid"]  <- "124"
vs[vs$vsseq %in% c(87)  & vs$personNum == 1, "vsspid"]  <- "720"
vs[vs$vsseq %in% c(88)  & vs$personNum == 1, "vsspid"]  <- "236"
vs[vs$vsseq %in% c(128) & vs$personNum == 1, "vsspid"]  <- "3000"
vs[vs$vsseq %in% c(142) & vs$personNum == 1, "vsspid"]  <- "5000"

# vslat
vs[vs$vsseq %in% c(1,3,86,88)  & vs$personNum == 1, "vslat"] <- "RIGHT"
vs[vs$vsseq %in% c(2,87) & vs$personNum == 1, "vslat"]       <- "LEFT"

