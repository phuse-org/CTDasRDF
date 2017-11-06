#______________________________________________________________________________
# FILE: VS_frag.R
# DESC: 1) Data recoding 
#       2) URI fragment creation from existing domain values
#       Creates vsWide format of the vs DF for processing by test result type.
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: No value creation, only recoding. Original values retained in DF
#       Coded values cannot have spaces or special characters.
#       SDTM numeric codes and others set MANUALLY
# TODO: 
#   Clean up code, convert many of th assignments to use of dplyr MUTATE
#   Move recoding of SDTM codes to a function and/or config file that 
#     queries their external graphs instead of manual coding in this script
#     for SDTM and CDISC terminology 
#   Replace FOR loop with dplyr mutate? 

#______________________________________________________________________________

# Create vstestOrder for numbering the test within each usubjid, vstestcd, sorted
#   by date (vsdtc) to allow creation of number triples within that category.    
vs$vsdtc_ymd = as.Date(vs$vsdtc, "%Y-%m-%d") # Convert for proper sorting 
# Sort by the categories, including the date
vs <- vs[with(vs, order(usubjid, vstestcd, vsdtc_ymd)), ]
# Add ID numbers within categories, excluding date (used for sorting, not for cat number)
vs <- ddply(vs, .(usubjid, vstestcd), mutate, vstestOrder = order(vsdtc_ymd))


# 1) Recoding -----------------------------------------------------------------
vs$vsstresu_Frag <- recode(vs$vsorresu, 
  "'cm'       = 'Unit_1';
   'IN'        = 'Unit_2';
   'mmHg'      = 'Unit_3';
   'BEATS/MIN' = 'Unit_4';
   'F'         = 'Unit_6';
   'LB'        = 'Unit_8'")

#  SDTM code values ----
# Translate values in the domain to their corresponding codelist code
# for linkage to the SDTM graph
# Example: vsloc  is coded to the SDTM Terminology graph by translating the value 
#  in the VS domain to its corresponding URI code in the SDTM terminology graph.
# Location ----
vs$vslocSDTMCode <- recode(vs$vsloc, 
                         "'ARM'         = 'C74456.C32141';
                          'EAR'         = 'C74456.C12394';                           
                          'ORAL CAVITY' = 'C74456.C12421'" )
# Body Position ----
vs$posSDTMCode <- recode(vs$vspos, 
                           "'STANDING' = 'C71148.C62166';
                            'SUPINE'   = 'C71148.C62167'" )

# Test Codes ----
vs$vstestSDTMCode <- recode(vs$vstest, 
                          "'Systolic Blood Pressure'  = 'C67153.C25298';
                           'Diastolic Blood Pressure' = 'C67153.C25299';
                           'Height'                   = 'C67153.C25347';
                           'Pulse Rate'               = 'C67153.C49676';
                           'Temperature'              = 'C67153.C25206';
                           'Weight'                   = 'C67153.C25208';
  " )
# Laterality ----
vs$vslatSDTMCode <- recode(vs$vslat, 
                          "'RIGHT' = 'C99073.C25228';
                           'LEFT'  = 'C99073.C25229'" )
# Body position ----
vs$vsposSDTM_Frag <- recode(vs$vspos, 
                           "'STANDING' = 'C71148.C62166';
                            'SUPINE'   = 'C71148.C62167'" )


# 2) Fragment  Creation -------------------------------------------------------
vs <- addDateFrag(vs, "vsdtc")  
vs <- createFragOneDomain(domainName=vs, processColumns="vsstat", fragPrefix="ActivityStatus")

# Category and Subcategory hard coding.  See AO email 2071-05
vs <- createFragOneDomain(domainName=vs, processColumns="vscat", fragPrefix="Category")
vs <- createFragOneDomain(domainName=vs, processColumns="vsscat", fragPrefix="Subcategory")


#!!!ERROR!!! in numbering of vspos_Frag. 
# vspos_Frag
#   Create fragment for creating hasSubActivity AssumeBodyPositionXXXX_n, where n
#      is numbered within patient x visit x vstptnum. See emails with AO 2017-07-05, then 2017-10-24 for update
#      and published in the .rmd file

# body position ---- 
vs$vsposCode <- recode(vs$vspos, 
                           "'STANDING' = 'AssumeBodyPositionStanding';
                            'SUPINE'   = 'AssumeBodyPositionSupine';
                            ''         =  NA" )
vs <- vs[with(vs, order(personNum, visit, vstptnum)), ]
# Create a temp field that combines personNum and visit for ease of numbering.
vs$tempvsposCat <- paste0(vs$personNum,"-v", vs$visitnum,"-", vs$vsposCode)

#!!ERROR HERE 
#vs <- createFragOneColByCat(domainName=vs, byCol="tempvsposCat", dataCol="tempvsposCat", 
#      fragPrefixName="vsposCode", numSort=FALSE)    

# This creates the right _(n) but we need the BY VALUES (?) as part of the fragment value...
#  so must use createFragOneColByCat ??
# vs <- createFragOneDomain(domainName=vs, processColumns="tempvsposCat", fragPrefix="vsposCode")


#DEL  Number the distinct values of the tempField
#DEL vs$tempId <- with(rle(as.character(vs$tempField)), rep(seq_along(values), lengths))
# Note: Missing values in extraction indices will cause error, so use !is.na() 
#   in these assignments. Ref: https://stackoverflow.com/questions/23396279/when-trying-to-replace-values-missing-values-are-not-allowed-in-subscripted-as

# Create vspos_Frag only when vspos is not misssing or not blank
# initialize
# see https://stackoverflow.com/questions/29814912/error-replacement-has-x-rows-data-has-y

# bodyPosition Rules ----
# ** Rule Type ----
vs$startRuleType_Frag <- recode(vs$vstpt, 
                           "'AFTER STANDING FOR 1 MINUTE'    = 'StartRuleStanding1';
                            'AFTER STANDING FOR 3 MINUTES'   = 'StartRuleStanding3';
                            'AFTER LYING DOWN FOR 5 MINUTES' = 'StartRuleLying5';
                             ''                               = NA " )
# Text for Rule Type 
vs$startRuleType_txt <- recode(vs$vstpt, 
                           "'AFTER STANDING FOR 1 MINUTE'    = 'Standing 1 Min';
                            'AFTER STANDING FOR 3 MINUTES'   = 'Standing 3 Min';
                            'AFTER LYING DOWN FOR 5 MINUTES' = 'Lying 5 Min';
                            ''                               = NA " )
# Position code label
vs$vspos_Label <- recode(vs$vspos, 
                           "'STANDING' = 'assume standing position';
                            'SUPINE'   = 'assume supine position'" )

# Outcomes  ----
# vsTestCat = categorized tests. Allows for fragment creation using function
#   createFragOneColByCat by grouping results for indexing WITHIN a category.
#   Eg: SYSBP, DIABP are indexed together as a BloodPressureOutcome_(n)
vs$vstestCat <- recode(vs$vstest, 
                           "'Systolic Blood Pressure'  = 'BloodPressure';
                            'Diastolic Blood Pressure' = 'BloodPressure';
                            'Height'                   = 'Height';
                            'Pulse Rate'               = 'Pulse';
                            'Temperature'              = 'Temperature';
                            'Weight'                   = 'Weight'" )
# Outcome labels
vs$vstestOutcomeType_Label <- recode(vs$vstest, 
                           "'Systolic Blood Pressure'  = 'Blood pressure outcome';
                            'Diastolic Blood Pressure' = 'Blood pressure outcome';
                            'Height'                   = 'Height outcome';
                            'Pulse Rate'               = 'Pulse outcome';
                            'Temperature'              = 'Temperature outcome';
                            'Weight'                   = 'Weight outcome'" )

# Visit ----
#  Manual recode from known visit values to fragment representation
#   data-dependent manual recoding!
# TODO: Change to call: createVisitFrag() function in createFrag_F
#   

vs<-createFragVisit(vs)  # this replaces the following TW# code 

#TW vs$visit_Frag <- sapply(vs$visit,function(x) {
#TW     switch(as.character(x),
#TW       "AMBUL ECG PLACEMENT" = "VisitAmbulECGPlacement",
#TW       "AMBUL ECG REMOVAL"   = "VisitAmbulECGRemoval",
#TW       "BASELINE"            = "VisitBaseline",
#TW       "RETRIEVAL"           = "VisitRetrieval",
#TW       "SCREENING 1"         = "VisitScreening1",
#TW       "SCREENING 2"         = "VisitScreening2",
#TW       "UNSCHEDULED 3.1"     = "VisitUnsched3-1",
#TW       "WEEK 2"              = "VisitWk2",
#TW       "WEEK 4"              = "VisitWk4",
#TW       "WEEK 6"              = "VisitWk6",
#TW       "WEEK 8"              = "VisitWk8",
#TW       "WEEK 12"             = "VisitWk12",
#TW       "WEEK 16"             = "VisitW168",
#TW       "WEEK 20"             = "VisitWk20",
#TW       "WEEK 24"             = "VisitWk24",
#TW       "WEEK 26"             = "VisitW26",
#TW       as.character(x) ) } )
#TW vs$visitPerson_Frag <- paste0(vs$visit_Frag,"_",vs$personNum)
#TW 
# visit ==> SCREENING 1 becomes Screening 1
vs$startRule_Label <-  paste0("P", vs$personNum, " ", 
  gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", vs$visit, perl=TRUE),
  " Rule ", vs$startRuleType_txt)

for (i in 1:nrow(vs)){
  # StartRule ----
  if (! is.na(vs[i,"startRuleType_Frag"])){
    #-- 2. Add the suffix as personNum. 
    #TODO Confirm use of personNum
    vs[i,"startRule_Frag"] <- paste0(vs[i,"startRuleType_Frag"], "_", vs[i,"personNum"]) 
  }
  # SDTM Code TYPE fragment ----
  #   stringr to remove spaces 
  #   Example: VisitScreening1SystolicBloodPressure, VisitScreening1PulseRate  
  vs[i,"vstestSDTMCodeType_Frag"] <- str_replace_all(string=paste0(vs[i,"visit_Frag"], vs[i,"vstestCat"]),
                                                     pattern=" ", repl="")    
  # Person Visit label ----
  #   Eg: P1 Visit 1
  vs[i,"persVis_Label"] <- stri_trans_general(
                                paste0("P", vs[i,"personNum"], " Visit ", vs[i,"visitnum"]), id="Title")
  
  # Result type fragment ----
  #   Eg: VisitScreening1SystolicBloodPressure
  #   stringr to remove spaces 
  vs[i,"sdtmCodeType_Frag"] <- str_replace_all(string=paste0(vs[i,"visit_Frag"], vs[i,"vstest"]),
                                               pattern=" ", repl="")

  # Form the first part of the vstestCatOutcome by appending Outcome to the vstestCat value.
  #   this will be used in createFragOneColByCat()
  # TODO: Resolve redundancy here: use only ONE of these: move to use of vstestOutcomeType_Frag here and in VS_process.R??
  vs[i,"vstestCatOutcome"] <- paste0(vs[i,"vstestCat"], "Outcome")
  vs[i,"vstestOutcomeType_Frag"] <- paste0(vs[i,"vstestCat"], "Outcome")

  # Outcome label ----
  vs[i,"vsorres_Label"] <- paste0(vs[i,"vsorres"], " ", vs[i,"vsorresu"])
}

# vsorres_Frag
#   Note how both dataCol and fragPrefix are same value here, but not in next fnt call.
vs <- createFragOneColByCat(domainName=vs, byCol="vstestCatOutcome", dataCol="vsorres", 
      fragPrefixName="vsorres", numSort=TRUE)    

#vs$vstestSDTMCode_Frag 
#  Frag number is based on the original order in the source file, not on the sorted result
#  values. So xxxx.C25298_1 is the first systolic BP value in the source file, not the
#  lowest SYSBP value. This is unlike BloodPressureOutcome_n, which uses SORTED values to 
#  create the outcome URIs.

vs <-vs[with(vs, order(vsseq)), ]  # return to original df order. TODO: build this into the function as a sort option!
vs <- createFragOneColByCat(domainName=vs, byCol="vstestSDTMCode", dataCol="vsorres",
       fragPrefixName="vstestSDTMCode", numSort=FALSE)    

# vstestSDTMCode
# Counter within the categores of vstestSDTMCode, sorted
#   by vsorres_Frag to match arbitrary coding covention used in above steps.
vs<-ddply(vs, .(vstestSDTMCode), mutate, testNumber = order(vsorres_Frag))

# Create label strings for the various tests. NA values not allowed in the source column!
vs$vstestcd_Label <- paste0('P', vs$personNum, " ", vs$vstestcd, " ", vs$testNumber)

vs <- mutate(vs,
  testRes_Label = stri_trans_general(
    #DEL paste0("P", personNum, " ", visit, " ", vstest, " ", testNumber), id="Title")
    paste0("P", personNum, " ", visit, " ", vstest, " ", vstestOrder), id="Title")
)
# OUtcome label ----
# Pick off the number after the _  from vsorres_Frag and make it part of the label
# TODO: Need new approach. The number should relate to the person and the result for that type of test
#   within that person+test.  P1 SBP 2 is the second SBP for Person 1!
vs$vstestOutcomeType_Label <- paste0(vs$vstestOutcomeType_Label, " ", str_extract(vs$vsorres_Frag, "\\d+$"))

# Clean up: remove temp vars
#TODO: Reinstate after debug     vs<-vs[, !(names(vs) %in% c("tempId", "tempField"))]


# AssumeBodyPosition(a)_(n)
vs <-createFragWithinCat(domainName=vs, 
  sortCols=c("personNum", "visitnum", "vsposCode"),
  fragValsCol="vsposCode")


# !!HERE!! ----
# vsposCodeStartRule_Frag
# Only AssumeBodyPositionStanding_1 has a start rule.  It must be preceded by StartRuleLying5_1
# if vsposCode_Frag is AssumeBodyPositionStanding_1, then assign vsposCodeSTartRule_Frag as StartRuleLying5_1
#    all other cases are NA (no start rule for that AssumeBodyPos. See email from AO 2017-11-02)
# Rcall that  _(n) , n=PersonNum. Rules apply on a per-person basis.
vs <- vs %>%
  mutate(vsposCodeStartRule_Frag = 
      ifelse(vsposCode_Frag=='AssumeBodyPositionStanding_1', 
        paste0("StartRuleLying5_", personNum), NA))

# Sort column names in the df for quicker referencing
vs <- vs %>% select(noquote(order(colnames(vs))))
