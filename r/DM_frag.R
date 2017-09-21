#______________________________________________________________________________
# FILE: DM_frag.R
# DESC: Data recoding and URI fragment creation for values that exist in the 
#       DM dataframe
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: No value creation, only recoding. Original values retained in DF
#       Coded values cannot have spaces or special characters.
#       SDTM numeric codes, Country, Arm codes are set MANUALLY
# TODO:
#______________________________________________________________________________

# Other units to be added based on the data
dm$ageu_Frag <- sapply(dm$ageu,function(x) {
    switch(as.character(x),
        'YEARS'      = 'unitYear',
        as.character(x) ) } )

# Treatment arms (planned, actual)
dm$armcd_Frag <- sapply(dm$armcd,function(x) {
    switch(as.character(x),
        'Pbo'      = 'ArmPlacebo',
        'Xan_Hi'   = 'ArmXanomelineHigh',
        'Xan_Lo'   = 'ArmXanomelinLow',
        'Scrnfail' = 'ArmScreenFailure',
        as.character(x) ) } )

dm$actarmcd_Frag <- sapply(dm$actarmcd,function(x) {
    switch(as.character(x),
        'Pbo'      = 'ArmPlacebo',
        'Xan_Hi'   = 'ArmXanomelineHigh',
        'Xan_Lo'   = 'ArmXanomelineLow',
        'Scrnfail' = 'ArmScreenFailure',
        as.character(x) ) } )

#  SDTM code values ----

# Translate values in the domain to their corresponding codelist code
# for linkage to the SDTM graph
# Example: Sex is coded to the SDTM Terminology graph by translating the value 
#  from the DM domain to its corresponding URI code in the SDTM terminology graph.
#  F C66731.C16576
#  M C66731.C20197
# NOTE: This type of recoding to external graphs should be moved to a function
#        and driven by a config file and/or separate SPARQL query against the graph
#        that holds the codes, like SDTMTERM for the CDISC SDTM Terminology.
#-- Sex
dm$sex_Frag <- sapply(dm$sex,function(x) {
    switch(as.character(x),
       'M'  = 'C66731.C20197',
       'F'  = 'C66731.C16576',
       'U'  = 'C66731.C17998', 
       'UNDIFFERENTIATED' = 'C66731.C45908',
        as.character(x) ) } )
#-- Ethnicity
dm$ethnic_Frag <- sapply(dm$ethnic,function(x) {
    switch(as.character(x),
        'HISPANIC OR LATINO'     = 'C66790.C17459',
        'NOT HISPANIC OR LATINO' = 'C66790.C41222',
        'NOT REPORTED'           = 'C66790.C43234',
        'UNKNOWN'                = 'C66790.C17998',
        as.character(x) ) } )
#-- Race
dm$race_Frag  <- sapply(dm$race,function(x) {
    switch(as.character(x),
        'AMERICAN INDIAN OR ALASKA NATIVE'          = 'C74457.C41259',
        'ASIAN'                                     = 'C74457.C41260',
        'BLACK OR AFRICAN AMERICAN'                 = 'C74457.C16352',
        'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER' = 'C74457.C41219',
        'WHITE'                                     = 'C74457.C41261',
        as.character(x) ) } )


#--Informed Consent Outcome
# code: InformedConsentOutcome_2  : Informed Consent not granted:  informed consent date MISSING
# code: InformedConsentOutcome_1  : Informed Consent granted:  date value
dm$informedConsentOut_Frag <- with(dm, ifelse(is.na(rficdtc), "InformedConsentOutcome_2", "InformedConsentOutcome_1" )) 

#  Fragment Creation by function call ----
dm <- addDateFrag(dm, "rfstdtc")  
dm <- addDateFrag(dm, "rfendtc")  
dm <- addDateFrag(dm, "rfxstdtc")  
dm <- addDateFrag(dm, "rfxendtc")  
dm <- addDateFrag(dm, "rficdtc")  
dm <- addDateFrag(dm, "rfpendtc")  
dm <- addDateFrag(dm, "dthdtc")
dm <- addDateFrag(dm, "dmdtc")  
dm <- addDateFrag(dm, "brthdate") 

dm <- createFragOneDomain(domainName=dm, processColumns="subjid",  fragPrefix="SubjectIdentifier" )
dm <- createFragOneDomain(domainName=dm, processColumns="usubjid", fragPrefix="UniqueSubjectIdentifier" )
dm <- createFragOneDomain(domainName=dm, processColumns="siteid",  fragPrefix="Site" )
dm <- createFragOneDomain(domainName=dm, processColumns="invid",   fragPrefix="InvestigatorIdentifier" )
# Create Investigator_n  from I
dm$investigator <- dm$invid
dm <- createFragOneDomain(domainName=dm, processColumns="investigator",   fragPrefix="Investigator" )

dm <- createFragOneDomain(domainName=dm, processColumns="age",     fragPrefix="AgeOutcome"  ) 
dm <- createFragOneDomain(domainName=dm, processColumns="age",     fragPrefix="AgeOutcome"  ) 
dm <- createFragOneDomain(domainName=dm, processColumns="country", fragPrefix="Country"  )