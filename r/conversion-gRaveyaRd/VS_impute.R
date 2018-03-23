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

vs <- addPersonId(vs)  # Add personNum for merge across domains, triple creation

# All Subjects ----
# Imputations for all patients in the VS domain.  Many of these were initially 
#   applied only to the first patient (1015). Expanded to all patients 16Nov17.
# Regress to commit prior to 16Nov17 to obtain original assignment code.
# vsloc
vs$vsloc <- as.character(vs$vsloc)  # factor correction
vs[vs$vstestcd %in% c('DIABP', 'SYSBP'), "vsloc"]  <- "ARM"

#vsstat
vs$vsstat <- as.character(vs$vsstat) # Factor correction
vs$vsstat <- "CO"  # all results hard coded to Complete.

# vsreasnd
# Change make dependent on presence/absence of a result value.
vs$vsreasnd <- "not applicable"  # All Reason Not Done coded to not applicable.

# Derived Flag Y/N 
vs$vsdrvfl <- "N"  # None of the measurements here are derived: BP,HT,WT,TEMP...

vs[vs$visit %in% c('SCREENING 1', 'BASELINE'), "vsblfl"]  <- "Y"

# invid set to same value as hard coded for DM in DM_impute.R
vs$invid <- "123"  # Later change to base on set of subjid or site or...?

# vsrftdtc
vs$vsrftdtc <- vs$vsdtc 

#______________________________________________________________________________
# Person 1 ----
# Created to illustrate round-tripping back to values in the ontology instance data. 
#  Hard coded for specific vsseq numbers for the first patient (1015). 
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
vs[vs$vsseq %in% c(86)  & vs$personNum == 1, "vsspid"]  <- "124"
vs[vs$vsseq %in% c(87)  & vs$personNum == 1, "vsspid"]  <- "720"
vs[vs$vsseq %in% c(88)  & vs$personNum == 1, "vsspid"]  <- "236"
vs[vs$vsseq %in% c(128) & vs$personNum == 1, "vsspid"]  <- "3000"
vs[vs$vsseq %in% c(142) & vs$personNum == 1, "vsspid"]  <- "5000"

# vslat
vs[vs$vsseq %in% c(1,3,86,88)  & vs$personNum == 1, "vslat"] <- "RIGHT"
vs[vs$vsseq %in% c(2,87) & vs$personNum == 1, "vslat"]       <- "LEFT"