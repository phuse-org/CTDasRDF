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

# StartRules based on vstpt 
vs$startRule_im <- car::recode(vs$vstpt,
  " 'AFTER LYING DOWN FOR 5 MINUTES'  = 'StartRuleLying5' ;
    'AFTER STANDING FOR 1 MINUTE'     = 'StartRuleStanding1' ;
    'AFTER STANDING FOR 3 MINUTES'    = 'StartRuleStanding3' "
)

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

# Create Values [Existing Columns] ---- 
#   Not present in original colums

# vsdrvfl - Derived Flag Y/N ----
vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & vs$usubjid == "01-701-1015",  "vsdrvfl"]  <- "N"

# vsreasnd - Reason not done -----
vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & vs$usubjid == "01-701-1015",  "vsreasnd"]  <- "not applicable"

# vsstat - Activity Status -----
vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & vs$usubjid == "01-701-1015",  "vsstat_im"]  <- "CO"

# vsspid - Sponsor Defined ID  ----
vs[vs$vsseq %in% c(1)   & vs$personNum == 1, "vsspid_im"]  <- "123"
vs[vs$vsseq %in% c(2)   & vs$personNum == 1, "vsspid_im"]  <- "719"
vs[vs$vsseq %in% c(3)   & vs$personNum == 1, "vsspid_im"]  <- "235"
vs[vs$vsseq %in% c(43)  & vs$personNum == 1, "vsspid_im"]  <- "1000"
vs[vs$vsseq %in% c(86)  & vs$personNum == 1, "vsspid_im"]  <- "124"
vs[vs$vsseq %in% c(87)  & vs$personNum == 1, "vsspid_im"]  <- "720"
vs[vs$vsseq %in% c(88)  & vs$personNum == 1, "vsspid_im"]  <- "236"
vs[vs$vsseq %in% c(128) & vs$personNum == 1, "vsspid_im"]  <- "3000"
vs[vs$vsseq %in% c(142) & vs$personNum == 1, "vsspid_im"]  <- "5000"

# vsgrpid_im - Group ID assignment ----
vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & vs$usubjid == "01-701-1015",  "vsgrpid_im"]  <- "GRPID1"

# vsblfl - Baseline flag -----
#  As per AO 20JUN18 to match VS_imputed.xlsx  
vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & vs$usubjid == "01-701-1015",  "vsblfl"]  <- "Y"


# Create Vals [new Columns] ----
#  Deviation from VS_imputed.xlsx. Values confirmed with AO version 20JUn18.
# vscat_im - Test Category
vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & vs$usubjid == "01-701-1015",  "vscat_im"]    <- "Category_1"
# vssubcat_im - Test Sub Category
vs[vs$vsseq %in% c(1,2,3,43,44,45,46,86,87,88,128,142) & vs$usubjid == "01-701-1015",  "vssubcat_im"] <- "Subcategory_1"

# vsrftdtc ----
#   Added to match AO VS_imputed.xlsx. Essentially vs$vsrftdtc <- vs$vsdtc 
vs[vs$vsseq %in% c(1,2,3,86,87,88) & vs$usubjid == "01-701-1015",  "vsrftdtc"]  <- "2013-12-26"

# vslat_im ----
vs[vs$vsseq %in% c(1,3,44,46,86,88)  & vs$usubjid == "01-701-1015", "vslat_im"] <- "RIGHT"
vs[vs$vsseq %in% c(2,45,87)          & vs$usubjid == "01-701-1015", "vslat_im"] <- "LEFT"

# vsloc_im - vstestcd location ----
#  Add value for ARM, recode ORAL CAVITY to allow use in IRI
vs[vs$vstestcd %in% c('DIABP', 'SYSBP'), "vsloc_im"]  <- "Arm"
vs[vs$vsloc %in% c('ORAL CAVITY'), "vsloc_im"]  <- "Oral_Cavity"

# vstest_outcome_im - labels for test type outcomes
# Groups DIABP and SYSBP together into BP outcomes per email AO 11JUN18
vs[vs$vstestcd %in% c("DIABP", "SYSBP"), "vstest_outcome_im"] <- "BloodPressure"
vs[vs$vstestcd %in% c("HEIGHT"),         "vstest_outcome_im"] <- "Height"
vs[vs$vstestcd %in% c("PULSE"),          "vstest_outcome_im"] <- "Pulse"
vs[vs$vstestcd %in% c("TEMP"),           "vstest_outcome_im"] <- "Temperature"  # updated 25JUn18
vs[vs$vstestcd %in% c("WEIGHT"),         "vstest_outcome_im"] <- "Weight"

# vstest_comp - Compressed values of vstest
vs$vstest_comp <- gsub(" ", "", vs$vstest )
vs$vstest_comp <- gsub("Rate", "", vs$vstest_comp )  # Also remove Rate from PulseRate [AO 20JUN18]

# vsstresc ----
# Replace special characters with '_' to allow use as IRI
vs$vsorres_en  <- gsub("\\.", "_", vs$vsorres, perl=TRUE)

# vsorresu_im  units ----
#  For links to code.ttl. Only some values  change from original data.
vs[vs$vsorresu %in% c("in"),       "vsorresu_im"] <- "IN"
vs[vs$vsorresu %in% c("mmHg"),      "vsorresu_im"] <- "mmHG"
vs[vs$vsorresu %in% c("beats/min"), "vsorresu_im"] <- "BEATS_MIN"
vs[vs$vsorresu %in% c("F"),         "vsorresu_im"] <- "F"
vs[vs$vsorresu %in% c("LB"),        "vsorresu_im"] <- "LB"

# visit_im_titleC -----
#  Title Case (titleC) for RDF Labels.
vs$visit_im_titleC    <- gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", vs$visit,    perl=TRUE)
vs$vspos_im_titleC    <- gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", vs$vspos,    perl=TRUE)
vs$vspos_im_lowerC    <- tolower(vs$vspos)


# vstpt_AssumeBodyPosStartRule_im ----
# Study protcol has the patient lying for 5 min before standing for 1 min.
#  The standing 1 min therefore has a previous 5 min start rule.
vs[vs$vstpt == "AFTER STANDING FOR 1 MINUTE", "vstpt_AssumeBodyPosStartRule_im"] <- "StartRuleLying5"

# vstpt_label_im ----
vs$vstpt_label_im <- tolower(vs$vstpt)

# URL encoding ----------------------------------------------------------------
#   Encode fields  that may potentially have values that violate valid IRI format
#   Function is in Functions.R

# vsdtc_en ----
vs <- encodeCol(data=vs, col="vsdtc")

# vsspid_im ----
#  Sponsor defined ID for various tests. 
#  TODO: Later change to be based on value of field vstestcd 
vs[vs$vsseq == 1   & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "123"
vs[vs$vsseq == 2   & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "719"
vs[vs$vsseq == 3   & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "235"
vs[vs$vsseq == 43  & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "1000"
vs[vs$vsseq == 44  & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "125"
vs[vs$vsseq == 45  & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "721"
vs[vs$vsseq == 46  & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "237"
vs[vs$vsseq == 86  & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "124"
vs[vs$vsseq == 87  & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "720"
vs[vs$vsseq == 88  & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "236"
vs[vs$vsseq == 128 & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "3000"
vs[vs$vsseq == 142 & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "5000"


# Sort column names in the df for quicker referencing
vs <- vs %>% select(noquote(order(colnames(vs))))
