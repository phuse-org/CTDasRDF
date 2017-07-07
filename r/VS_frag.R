###############################################################################
# FILE: VS_frag.R
# DESC: Data recoding and URI fragment creation from existing domain values
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE:
# TODO:
################################################################################
# Create numbering within each usubjid, vstestcd, sorted by date (vsdtc)
#    to allow creation of number triples within that category.    
# Convert for proper sorting 
#TODO: Evaluate next lines if needed now that using Frag approach
vs$vsdtc_ymd = as.Date(vs$vsdtc, "%Y-%m-%d")
# Sort by the categories, including the date
vs <- vs[with(vs, order(usubjid, vstestcd, vsdtc_ymd)), ]
# Add ID numbers within categories, excluding date (used for sorting, not for cat number)
vs <- ddply(vs, .(usubjid, vstestcd), mutate, vstestOrder = order(vsdtc_ymd))

#-- Data Coding ---------------------------------------------------------------
#-- Value/Code Translation
# Translate values in the domain to their corresponding codelist code
# for linkage to the SDTM graph
# Example: vsloc  is coded to the SDTM Terminology graph by translating the value 
#  in the VS domain to its corresponding URI code in the SDTM terminology graph.
# TODO: This type of recoding to external graphs will be moved to a function
#        and driven by a config file and/or separate SPARQL query against the graph
#        that holds the codes, like SDTMTERM for the CDISC SDTM Terminology.
#---- vsloc
vs$vslocSDTMCode <- recode(vs$vsloc, 
                         "'ARM'         = 'C74456.C32141';
                          'EAR'         = 'C74456.C12394';                           
                          'ORAL CAVITY' = 'C74456.CC12421'" )
# bodyPosition
vs$posSDTMCode <- recode(vs$vspos, 
                           "'STANDING' = 'C71148.C62166';
                            'SUPINE'   = 'C71148.C62167'" )

# activity code
#  Note values in lowercase in SDTM terminlogy, unlike others above.
#    This is correct match with vstest case in source data 
vs$vstestSDTMCode <- recode(vs$vstest, 
                          "'Systolic Blood Pressure'  =   'C67153.C25298';
                           'Diastolic Blood Pressure' =   'C67153.C25299'" )
# laterality
vs$vslatSDTMCode <- recode(vs$vslat, 
                          "'RIGHT' = 'C99073.C25228';
                           'LEFT'  = 'C99073.C25229'" )

#-- Fragment Creation and merging ---------------------------------------------
vs <- addDateFrag(vs, "vsdtc")  
vs <- createFragOneDomain(domainName=vs, processColumns="vsstat", fragPrefix="ActivityStatus")

#------------------------------------------------------------------------------
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


# bodyPosition Rules.  1. Create the prefix
vs$startRuleType_Frag <- recode(vs$vstpt, 
                           "'AFTER STANDING FOR 1 MINUTE'    = 'StartRuleStanding1';
                            'AFTER STANDING FOR 3 MINUTES'   = 'StartRuleStanding3';
                            'AFTER LYING DOWN FOR 5 MINUTES' = 'StartRuleLying5'" )


# 2. Add the suffix as personNum. 
#TODO Confirm use of personNum
vs$startRule_Frag <- paste0(vs$startRuleType_Frag, "_", vs$personNum) 


vs$vsstresu_Frag <- recode(vs$vsorresu, 
                           "'cm'   = 'Unit_1';
                            'in'   = 'Unit_2';
                            'mmHg' = 'Unit_3'" )

vs$vstestOutcomeType_Frag <- recode(vs$vstest, 
                           "'Systolic Blood Pressure'   = 'BloodPressureOutcome';
                            'Diastolic Blood Pressure'  = 'BloodPressureOutcome';
                            'Foo'                       = 'FooOutcome'" )

# The starting point for blood pressure outcome later. Add number to it later.
vs$vstestOutcomeType_Label <- recode(vs$vstest, 
                           "'Systolic Blood Pressure'   = 'Blood pressure outcome';
                            'Diastolic Blood Pressure'  = 'Blood pressure outcome';
                            'Foo'                       = 'FooOutcome'" )


# Create label strings for the various tests. NA values not allowed in the source column!
vs$vstestcd_Label[!is.na(vs$vstestcd) & vs$vstestcd=="SYSBP"] <- paste0('P', vs$personNum, ' SBP ', vs$visitnum)
vs$vstestcd_Label[!is.na(vs$vstestcd) &vs$vstestcd=="DIABP"] <- paste0('P', vs$personNum, ' DBP ', vs$visitnum)



# Create BloodPressureOutcome_n fragment. 
#  Blood pressure results come from both SYSBP and DIABP so only these values from 
#    vstestcd / vsorres must be coded to BloodPressureOutcome
#TODO Later this becomes a function to allow creation of similar 
# fragments that rely on values from different vstestcd. 
# Possible solution: createFragOneDomain: add another parameter: valSubset that creates 
#    the fragment numbering based only a subset of values in the column: eg; SYSBP, DIABP
vstestcd.subset <- vs[,c("vstestcd", "vsorres", "vsorresu")]
vstestcd.subset.bp <- subset(vstestcd.subset, vstestcd %in% c("SYSBP", "DIABP"))

# create the BloodPressureOutcome_(n) fragment
vstestcd.subset.bp  <- createFragOneDomain(domainName=vstestcd.subset.bp, 
       processColumns=c("vsorres"), fragPrefix="BloodPressureOutcome", numSort = TRUE)

# Keep only the value field for the match (vsorres) and the fragement to merge in
vstestcd.frag <- vstestcd.subset.bp[, c("vsorres", "vsorres_Frag")]

# Merge the vsorres_Frag created in the steps above back into the VS domain.
vs <- merge(x = vs, y = vstestcd.frag, by.x="vsorres", by.y="vsorres", all.y = TRUE)

# Pick off the number after the _  from vsorres_Frag and make it part of the label
vs$vstestOutcomeType_Label <- paste0(vs$vstestOutcomeType_Label, " ", str_extract(vs$vsorres_Frag, "\\d+$"))

#  NOTE: Other test value fragements are created from vsWide to disttinguish between
#   similar and dissimilar tests AT THE TEST LEVEL attached to a PERSON_(n)
# Cast the data from long to wide based on values in vstestcd
vsWide <- dcast(vs, ... ~ vstestcd, value.var="vsorres")

# Fragments for the type of test: DIABP_<n>, SYSBP_<n>, but NOT for the numeric results of those
#   tests. See later frag creation.
#   DIABP and SYSBP combined as per email from AO 2017-07-02
vsWide <- createFragOneDomain(domainName=vsWide, processColumns=c("DIABP", "SYSBP"), 
    fragPrefix="BloodPressureOutcome", numSort = TRUE)

#TODO: Add fragments for the other results...
# visit_Frag is a special case that combines the text value of the visit name with the personNum
# vsWide$personVisit_Frag <- paste0("VisitScreening", gsub(" ", "", vsWide$visit), "_", vsWide$personNum)
vsWide$visit_Frag <- sapply(vsWide$visit,function(x) {
    switch(as.character(x),
        'SCREENING 1' = 'VisitScreening1',
        as.character(x) ) } )

# Add personNum to finish creation of the fragment.
#  Eg: VisitScreening1_1
vsWide$visitPerson_Frag <- paste0(vsWide$visit_Frag,"_",vsWide$personNum)

#TODO: evaluate the use of this next statement.
#vsWide$visit_Frag <- paste0("visit_", vsWide$visitnum)  # Links to a visit description in custom:

# end fragment creation

#DEL Create the codelist values for vsstat/activitystatus_<n>
vsstat <- vs[,c("vsstat", "vsstat_Frag")]
vsstat <- vsstat[!duplicated(vsstat), ]

vsstat$shortLabel[vsstat$vsstat=="COMPLETE"] <- 'CO'
vsstat$shortLabel[vsstat$vsstat=="NOT DONE"] <- 'ND'


# vstestSDTMCode
# Create a tempId as a counter within the categores of vstestSDTMCode, sorted
#   by vsorres_Frag to match arbitrary coding covention used in above steps.
vsWide<-ddply(vsWide, .(vstestSDTMCode), mutate, testNumber = order(vsorres_Frag))
vsWide$vstestSDTMCode_Frag <- paste0(vsWide$vstestSDTMCode, "_", vsWide$testNumber)

