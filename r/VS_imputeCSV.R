#______________________________________________________________________________
# FILE: VS_imputeCSV.R
# DESC: Creates data values required for prototyping and ontoloty develeopment
# REQ : Prior import of the VS domain by driver script.
# SRC : N/A
# IN  : vs dataframe 
# OUT : modified vs dataframe 
# NOTE: 
# TODO: 
#______________________________________________________________________________

# ** Impute ----
# StartRules based on vstpt 
vs$startRule_im <- car::recode(vs$vstpt,
  " 'AFTER LYING DOWN FOR 5 MINUTES'  = 'StartRuleLying5' ;
    'AFTER STANDING FOR 1 MINUTE'     = 'StartRuleStanding1' ;
    'AFTER STANDING FOR 3 MINUTES'    = 'StartRuleStanding3' "
)

# Without spaces, for use in forming IRIs (that do not long to ontology as per use of
#   visit_im_CCaseSh )
vs$visit_im_comp <- gsub(" ", "", vs$visit )

# Change following to function. Used in other domains!
# visit in Camel Case Short form for linking  IRIs to ont. Ont uses camel case
vs$visit_im_titleCSh <- car::recode (vs$visit,
  " 'SCREENING 1'          =  'Screening1' ;
    'SCREENING 2'          =  'Screening2' ;
    'BASELINE'             =  'Baseline' ;
    'AMBUL ECG PLACEMENT'  =  'AmbulECGPlacement' ;
    'AMBUL ECG REMOVAL'    =  'AmbulECGRemoval' ;
    'WEEK 2'               =  'Wk2' ;
    'WEEK 4'               =  'Wk4' ;
    'WEEK 6'               =  'Wk6' ;
    'WEEK 8'               =  'Wk8' ;
    'WEEK 12'              =  'Wk12' ;
    'WEEK 16'              =  'Wk16' ;
    'WEEK 20'              =  'Wk20' ;
    'WEEK 24'              =  'Wk24' ;
    'WEEK 26'              =  'Wk26' ;
    'RETRIEVAL'            =  'Retrieval' ;
    'UNSCHEDULED 3.1'      =  'Unscheduled31' "
)


# Derived Flag Y/N 
vs$vsdrvfl_im <- "N"  # None of the measurements here are derived: BP,HT,WT,TEMP...

# Reason not done
vs$vsreasnotdone_im <- "not applicable"

#Activity Status
vs$vsactstatus_im <- "CO"



# vsspid : Sponsor Defined ID
vs[vs$vsseq %in% c(1)   & vs$personNum == 1, "vsspid_im"]  <- "123"
vs[vs$vsseq %in% c(2)   & vs$personNum == 1, "vsspid_im"]  <- "719"
vs[vs$vsseq %in% c(3)   & vs$personNum == 1, "vsspid_im"]  <- "235"
vs[vs$vsseq %in% c(43)  & vs$personNum == 1, "vsspid_im"]  <- "1000"
vs[vs$vsseq %in% c(86)  & vs$personNum == 1, "vsspid_im"]  <- "124"
vs[vs$vsseq %in% c(87)  & vs$personNum == 1, "vsspid_im"]  <- "720"
vs[vs$vsseq %in% c(88)  & vs$personNum == 1, "vsspid_im"]  <- "236"
vs[vs$vsseq %in% c(128) & vs$personNum == 1, "vsspid_im"]  <- "3000"
vs[vs$vsseq %in% c(142) & vs$personNum == 1, "vsspid_im"]  <- "5000"



# Category and Subcategory for tests (vstestcd)
vs$vscat_im    <- "Category_1"  
vs$vssubcat_im <- "Subcategory_1"

# Group ID assignement
vs[vs$vsseq %in% c(1,2,3,43,86,87,88,128,142) & vs$usubjid == "01-701-1015",  "vsgrpid_im"]  <- "GRPID1"


#DEL : Converted to use im_titleC
#vs$vspos_im_CCase <- car::recode(vs$vspos,
#  " 'STANDING'  = 'Standing' ;
#    'SUPINE'    = 'Supine'"
#)

# vslat
vs[vs$vsseq %in% c(1,3,86,88)  & vs$personNum == 1, "vslat_im"] <- "RIGHT"
vs[vs$vsseq %in% c(2,87)       & vs$personNum == 1, "vslat_im"] <- "LEFT"


# vstestcd location. Add value for ARM, recode ORAL CAVITY to allow use in IRI
vs[vs$vstestcd %in% c('DIABP', 'SYSBP'), "vsloc_im"]  <- "ARM"
vs[vs$vsloc %in% c('ORAL CAVITY'), "vsloc_im"]  <- "ORALCAVITY"


vs[vs$vstestcd %in% c("DIABP", "SYSBP"), "vstest_testtype_im"] <- "BloodPressure"
vs[vs$vstestcd %in% c("HEIGHT"), "vstest_testtype_im"]         <- "Height"
vs[vs$vstestcd %in% c("PULSE"), "vstest_testtype_im"]          <- "Pulse"
vs[vs$vstestcd %in% c("TEMP"), "vstest_testtype_im"]           <- "Temperature"
vs[vs$vstestcd %in% c("WEIGHT"), "vstest_testtype_im"]         <- "Weight"

# Title Case (titleC) Conversions. For RDF Labels.
vs$visit_im_titleC    <- gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", vs$visit,    perl=TRUE)
vs$vspos_im_titleC    <- gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", vs$vspos,    perl=TRUE)
vs$vslat_im_titleC    <- gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", vs$vslat,    perl=TRUE)
vs$vstestcd_im_titleC <- gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", vs$vstestcd, perl=TRUE)

#------------------------------------------------------------------------------
# URL encoding
#   Encode fields  that may potentially have values that violate valid IRI format
#   Function is in Functions.R
vs <- encodeCol(data=vs, col="vsdtc")
vs <- encodeCol(data=vs, col="vsorres")


# Sort column names in the df for quicker referencing
vs <- vs %>% select(noquote(order(colnames(vs))))


#------------- ORIGINAL IMPUTATIONS FOLLOW ------------------------------------
#TW # All Subjects ----
#TW # Imputations for all patients in the VS domain.  Many of these were initially 
#TW #   applied only to the first patient (1015). Expanded to all patients 16Nov17.
#TW # Regress to commit prior to 16Nov17 to obtain original assignment code.
#TW # vsloc
#TW vs$vsloc <- as.character(vs$vsloc)  # factor correction
#TW vs[vs$vstestcd %in% c('DIABP', 'SYSBP'), "vsloc"]  <- "ARM"
#TW 
#TW #vsstat
#TW vs$vsstat <- as.character(vs$vsstat) # Factor correction
#TW vs$vsstat <- "CO"  # all results hard coded to Complete.
#TW 
#TW # vsreasnd
#TW # Change make dependent on presence/absence of a result value.
#TW vs$vsreasnd <- "not applicable"  # All Reason Not Done coded to not applicable.
#TW 
#TW # Derived Flag Y/N 
#TW vs$vsdrvfl <- "N"  # None of the measurements here are derived: BP,HT,WT,TEMP...
#TW 
#TW vs[vs$visit %in% c('SCREENING 1', 'BASELINE'), "vsblfl"]  <- "Y"
#TW 
#TW # invid set to same value as hard coded for DM in DM_impute.R
#TW vs$invid <- "123"  # Later change to base on set of subjid or site or...?
#TW 
#TW # vsrftdtc
#TW vs$vsrftdtc <- vs$vsdtc 
#TW 
#TW #______________________________________________________________________________
#TW # Person 1 ----
#TW # Created to illustrate round-tripping back to values in the ontology instance data. 
#TW #  Hard coded for specific vsseq numbers for the first patient (1015). 
#TW vs[vs$vsseq %in% c(1,2,3,43,86,87,88,128,142) & vs$personNum == 1,  "vsgrpid"]  <- "GRPID1"
#TW # vscat
#TW vs[vs$vsseq %in% c(1,2,3,43,86,87,88,128,142) & vs$personNum == 1,  "vscat"]  <- "CAT1"
#TW # vsscat
#TW vs[vs$vsseq %in% c(1,2,3,43,86,87,88,128,142) & vs$personNum == 1,  "vsscat"]  <- "SCAT1"
#TW 
#TW # vsspid
#TW vs[vs$vsseq %in% c(1)   & vs$personNum == 1, "vsspid"]  <- "123"
#TW vs[vs$vsseq %in% c(2)   & vs$personNum == 1, "vsspid"]  <- "719"
#TW vs[vs$vsseq %in% c(3)   & vs$personNum == 1, "vsspid"]  <- "235"
#TW vs[vs$vsseq %in% c(43)  & vs$personNum == 1, "vsspid"]  <- "1000"
#TW vs[vs$vsseq %in% c(86)  & vs$personNum == 1, "vsspid"]  <- "124"
#TW vs[vs$vsseq %in% c(87)  & vs$personNum == 1, "vsspid"]  <- "720"
#TW vs[vs$vsseq %in% c(88)  & vs$personNum == 1, "vsspid"]  <- "236"
#TW vs[vs$vsseq %in% c(128) & vs$personNum == 1, "vsspid"]  <- "3000"
#TW vs[vs$vsseq %in% c(142) & vs$personNum == 1, "vsspid"]  <- "5000"
#TW 
