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
vs[!is.na(vs$vspos) & vs$vspos == "STANDING", "vspos_Frag"]  <- "AssumeBodyPositionStanding_"
vs[!is.na(vs$vspos) & vs$vspos == "SUPINE", "vspos_Frag"]    <- "AssumeBodyPositionSupine_"
vs$vspos_Frag <- paste0(vs$vspos_Frag, vs$tempId)
# Clean up: remove temp vars
vs<-vs[, !(names(vs) %in% c("tempId", "tempField"))]

# bodyPosition Rules.  
#-- 1. Create the prefix
vs$startRuleType_Frag <- recode(vs$vstpt, 
                           "'AFTER STANDING FOR 1 MINUTE'    = 'StartRuleStanding1';
                            'AFTER STANDING FOR 3 MINUTES'   = 'StartRuleStanding3';
                            'AFTER LYING DOWN FOR 5 MINUTES' = 'StartRuleLying5'" )
#-- 2. Add the suffix as personNum. 
#TODO Confirm use of personNum
vs$startRule_Frag <- paste0(vs$startRuleType_Frag, "_", vs$personNum) 

# bodyPosition Rules. 
vs$vsposCode_Frag <- recode(vs$vspos, 
                           "'STANDING' = 'AssumeBodyPositionStanding';
                            'SUPINE'   = 'AssumeBodyPositionSupine'" )
vs$vspos_Label <- recode(vs$vspos, 
                           "'STANDING' = 'assume standing position';
                            'SUPINE'   = 'assume supine position'" )

# Outcomes  
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
vs$vstestcd_Label[!is.na(vs$vstestcd) & vs$vstestcd=="SYSBP"]  <- paste0('P', vs$personNum, ' SBP ', vs$visitnum)
vs$vstestcd_Label[!is.na(vs$vstestcd) & vs$vstestcd=="DIABP"]  <- paste0('P', vs$personNum, ' DBP ', vs$visitnum)
vs$vstestcd_Label[!is.na(vs$vstestcd) & vs$vstestcd=="HEIGHT"] <- paste0('P', vs$personNum, ' Height ', vs$visitnum)
vs$vstestcd_Label[!is.na(vs$vstestcd) & vs$vstestcd=="PULSE"]  <- paste0('P', vs$personNum, ' Pulse ', vs$visitnum)
vs$vstestcd_Label[!is.na(vs$vstestcd) & vs$vstestcd=="TEMP"]   <- paste0('P', vs$personNum, ' Temperature ', vs$visitnum)
vs$vstestcd_Label[!is.na(vs$vstestcd) & vs$vstestcd=="WEIGHT"] <- paste0('P', vs$personNum, ' Weight ', vs$visitnum)

#TESTING TO HERE ------------------------------

# Create BloodPressureOutcome_n fragment. 
#  Blood pressure results come from both SYSBP and DIABP so only these values from 
#    vstestcd / vsorres must be coded to BloodPressureOutcome
#TODO Later this becomes a function to allow creation of similar 
# fragments that rely on values from more than one type of vstestcd. 
# Possible solution: createFragOneDomain: add another parameter: valSubset that creates 
#    the fragment numbering based only a subset of values in the column: eg; SYSBP, DIABP
vstestcd.subset <- vs[,c("vstestcd", "vsorres")]
vstestcd.subset.bp <- subset(vstestcd.subset, vstestcd %in% c("SYSBP", "DIABP"))

# create the BloodPressureOutcome_(n) fragment
#!! PROBLEM HERE: The SORT makes for a problem against AO's data - wrong order.
#TODO Possible solution is to create fragment using  row number from original dataset instead of 
#   numbering based on order within test result category.
vstestcd.frag  <- createFragOneDomain(domainName=vstestcd.subset.bp, 
       processColumns=c("vsorres"), fragPrefix="BloodPressureOutcome", numSort = TRUE)

# Merge the vsorres_Frag created in the steps above back into the VS domain.
vs <- merge(x = vs, y = vstestcd.frag, by.x=c("vstestcd","vsorres"), by.y=c("vstestcd","vsorres"), all.x = TRUE)



# Pick off the number after the _  from vsorres_Frag and make it part of the label
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