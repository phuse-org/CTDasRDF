###############################################################################
# FILE: VS_frag.R
# DESC: Data recoding and URI fragment creation from existing domain values
#       Creates vsWide format of the vs DF for processing by test result type.
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: No value creation, only recoding. Original values retained in DF
#       Coded values cannot have spaces or special characters.
#       SDTM numeric codes and others set MANUALLY
# TODO:
################################################################################
# Create vstestOrder for numbering the test within each usubjid, vstestcd, 
#   sorted by date (vsdtc)
#   to allow creation of number triples within that category.    
vs$vsdtc_ymd = as.Date(vs$vsdtc, "%Y-%m-%d") # Convert for proper sorting 
# Sort by the categories, including the date
vs <- vs[with(vs, order(usubjid, vstestcd, vsdtc_ymd)), ]
# Add ID numbers within categories, excluding date (used for sorting, not for cat number)
vs <- ddply(vs, .(usubjid, vstestcd), mutate, vstestOrder = order(vsdtc_ymd))

# Category and Subcategory hard coding.  See AO email 2071-05
vs$vscat_Frag  <- 'Category_1'
vs$vsscat_Frag <- 'Subcategory_1'

vs$vsstresu_Frag <- recode(vs$vsorresu, 
                           "'cm'        = 'Unit_1';
                            'IN'        = 'Unit_2';
                            'mmHg'      = 'Unit_3';
                            'BEATS/MIN' = 'Unit_4';
                            'F'         = 'Unit_6';
                            'LB'        = 'Unit_8'")

#  SDTM code values -----------------------------------------------------------
# Translate values in the domain to their corresponding codelist code
# for linkage to the SDTM graph
# Example: vsloc  is coded to the SDTM Terminology graph by translating the value 
#  in the VS domain to its corresponding URI code in the SDTM terminology graph.
# TODO: This type of recoding to external graphs will be moved to a function
#        and driven by a config file and/or separate SPARQL query against the graph
#        that holds the codes, like SDTMTERM for the CDISC SDTM Terminology.
# vsloc ----
vs$vslocSDTMCode <- recode(vs$vsloc, 
                         "'ARM'         = 'C74456.C32141';
                          'EAR'         = 'C74456.C12394';                           
                          'ORAL CAVITY' = 'C74456.CC12421'" )
# bodyPosition ----
vs$posSDTMCode <- recode(vs$vspos, 
                           "'STANDING' = 'C71148.C62166';
                            'SUPINE'   = 'C71148.C62167'" )

# vstest ----
vs$vstestSDTMCode <- recode(vs$vstest, 
                          "'Systolic Blood Pressure'  = 'C67153.C25298';
                           'Diastolic Blood Pressure' = 'C67153.C25299';
                           'Height'                   = 'C67153.C25347';
                           'Pulse Rate'               = 'C67153.C49676';
                           'Temperature'              = 'C67153.C25206';
                           'Weight'                   = 'C67153.C25208';
  " )
# laterality
vs$vslatSDTMCode <- recode(vs$vslat, 
                          "'RIGHT' = 'C99073.C25228';
                           'LEFT'  = 'C99073.C25229'" )
# body position
vs$vsposSDTM_Frag <- recode(vs$vspos, 
                           "'STANDING' = 'C71148.C62166';
                            'SUPINE'   = 'C71148.C62167'" )


# Fragment  -------------------------------------------------------------------
vs <- addDateFrag(vs, "vsdtc")  
vs <- createFragOneDomain(domainName=vs, processColumns="vsstat", fragPrefix="ActivityStatus")

# vspos_Frag
#   Create fragment for creating hasSubActivity AssumeBodyPositionXXXX_n, where n
#      is numbered within patient x visit. See emails with AO 2017-07-05
vs <- vs[with(vs, order(personNum, visit)), ]
# Create a temp field that combines personNum and visit for ease of numbering.
vs$tempField <- paste0(vs$personNum, vs$visit)
# Number the distinct values of the tempField
vs$tempId <- with(rle(as.character(vs$tempField)), rep(seq_along(values), lengths))
# Note: Missing values in extraction indices will cause error, so use !is.na() 
#   in these assignments. Ref: https://stackoverflow.com/questions/23396279/when-trying-to-replace-values-missing-values-are-not-allowed-in-subscripted-as

# Create vspos_Frag only when vspos is not misssing or not blank
# initialize
# see https://stackoverflow.com/questions/29814912/error-replacement-has-x-rows-data-has-y

# bodyPosition Rules.  
#-- 1. Create the prefix
vs$startRuleType_Frag <- recode(vs$vstpt, 
                           "'AFTER STANDING FOR 1 MINUTE'    = 'StartRuleStanding1';
                            'AFTER STANDING FOR 3 MINUTES'   = 'StartRuleStanding3';
                            'AFTER LYING DOWN FOR 5 MINUTES' = 'StartRuleLying5';
                            ''                               = 'StartRuleNone'" )

# bodyPosition Rules. 
vs$vsposCode_Frag <- recode(vs$vspos, 
                           "'STANDING' = 'AssumeBodyPositionStanding';
                            'SUPINE'   = 'AssumeBodyPositionSupine';
                            ''         =  NA" )

vs$vspos_Label <- recode(vs$vspos, 
                           "'STANDING' = 'assume standing position';
                            'SUPINE'   = 'assume supine position'" )
# Outcomes  
#   Recode allows combination of some categories, like SBP and DPB into BloodPressure
# TODO: REMOVE in preference to vsTestCat
vs$vstestOutcomeType_Frag <- recode(vs$vstest, 
                           "'Systolic Blood Pressure'  = 'BloodPressureOutcome';
                            'Diastolic Blood Pressure' = 'BloodPressureOutcome';
                            'Height'                   = 'HeightLengthOutcome';
                            'Pulse Rate'               = 'PulseHROutcome';
                            'Temperature'              = 'TemperatureOutcome';
                            'Weight'                   = 'WeightMassOutcome'" )


# vsTestCat = categorized tests. Allows for fragment creation using function
#   createFragOneColByCat by grouping results for indexing WITHIN a category.
#   Eg: SYSBP, DIABP are indexed together as a BloodPressureOutcome_(n)
vs$vstestCat <- recode(vs$vstest, 
                           "'Systolic Blood Pressure'  = 'BloodPressureOutcome';
                            'Diastolic Blood Pressure' = 'BloodPressureOutcome';
                            'Height'                   = 'HeightLengthOutcome';
                            'Pulse Rate'               = 'PulseHROutcome';
                            'Temperature'              = 'TemperatureOutcome';
                            'Weight'                   = 'WeightMassOutcome'" )

# Outcome labels
vs$vstestOutcomeType_Label <- recode(vs$vstest, 
                           "'Systolic Blood Pressure'  = 'Blood pressure outcome';
                            'Diastolic Blood Pressure' = 'Blood pressure outcome';
                            'Height'                   = 'Height length outcome';
                            'Pulse Rate'               = 'Pulse HR outcome';
                            'Temperature'              = 'Temperature outcome';
                            'Weight'                   = 'Weight mass outcome'" )


# Create label strings for the various tests. NA values not allowed in the source column!
vs$vstestcd_Label <- paste0('P', vs$personNum, " ", vs$vstestcd, " ", vs$testNumber)

# Create the VS result fragment vsorres_Frag
# vs <- createFragOneColByCat(domainName=vs, dataCol="vsorres", byCol="vstestCat", fragPrefixCol="vstestCat")    
vs <- createFragOneColByCat(domainName=vs, byCol="vstestCat", dataCol="vsorres", fragPrefixCol="vstestCat")    

# Pick off the number after the _  from vsorres_Frag and make it part of the label
# TODO: Need new approach. The number should relate to the person and the result for that type of test
#   within that person+test.  P1 SBP 2 is the second SBP for Person 1!

vs$vstestOutcomeType_Label <- paste0(vs$vstestOutcomeType_Label, " ", str_extract(vs$vsorres_Frag, "\\d+$"))

# Visit Fragments
vs$visit_Frag <- sapply(vs$visit,function(x) {
    switch(as.character(x),
      'SCREENING 1' = 'VisitScreening1',
      as.character(x) ) } )
vs$visitPerson_Frag <- paste0(vs$visit_Frag,"_",vs$personNum)

# vstestSDTMCode
# Create a tempId as a counter within the categores of vstestSDTMCode, sorted
#   by vsorres_Frag to match arbitrary coding covention used in above steps.
vs<-ddply(vs, .(vstestSDTMCode), mutate, testNumber = order(vsorres_Frag))
vs$vstestSDTMCode_Frag <- paste0(vs$vstestSDTMCode, "_", vs$testNumber)



#TODO: Replace FOR with more efficient code. 
for (i in 1:nrow(vs)){
  
  # vspos_Frag based on vsposCOde_Frag.    
  if (!is.na(vs[i,"vsposCode_Frag"])){
    vs[i,"vspos_Frag"] <- paste0(vs[i,"vsposCode_Frag"], "_", vs[i,"tempId"])
  }

  # StartRule ----
  if (!is.na(vs[i,"startRuleType_Frag"])){
    #-- 2. Add the suffix as personNum. 
    #TODO Confirm use of personNum
    vs[i,"startRule_Frag"] <- paste0(vs[i,"startRuleType_Frag"], "_", vs[i,"personNum"]) 
  }else{
    # Another confirm with AO: is there a SINGLE StartRuleNone, or One per personNum
    vs[i,"startRule_Frag"] <- paste0("StartRuleNone_", vs[i,"personNum"])
  }

  #TODO Start Rule Label
  #  Build startRule_Label here
  #QUESTION out to AO  <TBD>
  
  # SDTM Code TYPE fragment ----
  #   stringr to remove spaces 
  #   Example: VisitScreening1SystolicBloodPressure, VisitScreening1PulseRate  
  vs[i,"vstestSDTMCodeType_Frag"] <- str_replace_all(string=paste0(vs[i,"visit_Frag"], vs[i,"vstest"]),
                                                     pattern=" ", repl="")    
  # Result label ----
  #   Eg: P1 Screening1 Temperature
  vs[i,"testRes_Label"] <- stri_trans_general(
                                paste0("P", vs[i,"personNum"], " ", vs[i,"visit"], " ", vs[i,"vstest"]), id="Title")
  
  # Result type fragment ----
  #   Eg: VisitScreening1SystolicBloodPressure
  #   stringr to remove spaces 
  vs[i,"sdtmCodeType_Frag"] <- str_replace_all(string=paste0(vs[i,"vist_Frag"], vs[i,"vstest"]),
                                               pattern=" ", repl="")
  # Outcome label ----
  vs[i,"vsorres_Label"] <- paste0(vs[i,"vsorres"], " ", vs[i,"vsorresu"])
  
  
}
  
# Clean up: remove temp vars
vs<-vs[, !(names(vs) %in% c("tempId", "tempField"))]

# Sort column names in the df for quicker referencing
vs <- vs %>% select(noquote(order(colnames(vs))))


