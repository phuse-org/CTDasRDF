###############################################################################
# FILE: processDM.R
# DESC: Create DM domain triples
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: TESTING MODE: Uses only first 6 patients (set for DM migrates across 
#           all domains)
#       Coded values:  cannot have spaces or special characters.
#                      Are stored in variables with under suffix _ while 
#                          originals are retained.
#       SDTM numeric codes, Country, Arm codes are set MANUALLY
#       Birthdate and Deathdate are now part of the Lifespan interval. 
# TODO: 
#   
#  - Collapse code segments in FUNT()s where possible
#  - Add a function that evaluates each DATE value and types it as either
#     xsd:date if valid yyyy-mm-dd value, or as xsd:string if(invalid/incomplete 
#     date OR is a datetime value)
#  - Consider new triples for incomplete dates (YYYY triple, MON  triple, etc.)
#     for later implmentations
#   CUSTOM file creation
#      Add creation of CUSTOMTERMINLOGY.TTL for terms like AgeOutcomeTerm_(nn)YRS
#          this file and triples currently not created!
###############################################################################

#-- Data Creation (for testing) -----------------------------------------------
#---- Investigator name and ID not present in source data
dm$invnam <- 'Jones'
dm$invid  <- '123'
dm$dthfl[dm$personNum == 1 ] <- "Y" # Set a Death flag  for Person_1
#-- End Data Creation ---------------------------------------------------------

#-- Data COding ---------------------------------------------------------------
#-- CODED values 
#TODO: DELETE THESE toupper() statements. No longer used?  2017-01-18 TW ?
# UPPERCASE and remove spaces values of fields that will be coded to codelists
# Phase:  "Phase 2" becomes "PHASE2"
dm$study_ <- toupper(gsub(" ", "", dm$study))
dm$ageu_  <- toupper(gsub(" ", "", dm$ageu))  # TODO: NOT USED?
# For arm, use the coded form of both armcd and actarmcd to allow a short-hand linkage
#    to the codelist where both ARM/ARMCD adn ACTARM/ACTARMCD are located.
dm$arm_    <- toupper(gsub(" ", "", dm$armcd))
dm$actarm_ <- toupper(gsub(" ", "", dm$actarmcd))

#-- Value/Code Translation
# Translate values in the domain to their corresponding codelist code
# for linkage to the SDTM graph
# Example: Sex is coded to the SDTM Terminology graph by translating the value 
#  from the DM domain to its corresponding URI code in the SDTM terminology graph.
#  F C66731.C16576
#  M C66731.C20197
# TODO: This type of recoding to external graphs will be moved to a function
#        and driven by a config file and/or separate SPARQL query against the graph
#        that holds the codes, like SDTMTERM for the CDISC SDTM Terminology.
#---- Sex
dm$sex_ <- sapply(dm$sex,function(x) {
    switch(as.character(x),
       'M'  = 'C66731.C20197',
       'F'  = 'C66731.C16576',
       'U'  = 'C66731.C17998', 
       'UNDIFFERENTIATED' = 'C66731.C45908',
        as.character(x) ) } )
#---- Ethnicity
dm$ethnic_ <- sapply(dm$ethnic,function(x) {
    switch(as.character(x),
        'HISPANIC OR LATINO'     = 'C66790.C17459',
        'NOT HISPANIC OR LATINO' = 'C66790.C41222',
        'NOT REPORTED'           = 'C66790.C43234',
        'UNKNOWN'                = 'C66790.C17998',
        as.character(x) ) } )
#---- Race
dm$race_  <- sapply(dm$race,function(x) {
    switch(as.character(x),
        'AMERICAN INDIAN OR ALASKA NATIVE'          = 'C74457.C41259',
        'ASIAN'                                     = 'C74457.C41260',
        'BLACK OR AFRICAN AMERICAN'                 = 'C74457.C16352',
        'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER' = 'C74457.C41219',
        'WHITE'                                     = 'C74457.C41261',
        as.character(x) ) } )
            
#---- Country
# Match to the code in the ontology identified by AO
dm$country_ <- recode(dm$country,"'USA' = '840'")
#-- End Data Coding -----------------------------------------------------------

#-- Single Resource Creation --------------------------------------------------
#---- Investigators : Build triples for each unique Investigator
# Get unique investigator ID 
investigators <- dm[,c("invnam", "invid")]
investigators <- investigators[!duplicated(investigators),] 
ddply(investigators, .(invnam), function(investigators)
{
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators$invid),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "Investigator")
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators$invid),
        paste0(prefix.STUDY,"hasInvestigatorID" ),
        paste0(investigators$invid), type="string"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators$invid),
        paste0(prefix.STUDY,"hasLastName" ),
        paste0(investigators$invnam), type="string"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators$invid),
        paste0(prefix.RDFS,"label" ),
        paste0("Investigator ", investigators$invid), type="string"
    )
})
# ---- Sites : Build triples for each unique Site
sites <- dm[,c("siteid", "invid", "country_" )]
sites <- sites[!duplicated(sites),]
ddply(sites, .(siteid), function(sites)
{
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "site_",sites$siteid),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY,"Site" )
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "site_",sites$siteid),
        paste0(prefix.STUDY,"hasCountry" ),
        paste0(prefix.COUNTRY,sites$country )
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "site_",sites$siteid),
        paste0(prefix.STUDY,"hasInvestigator" ),
        paste0(prefix.CDISCPILOT01,"Investigator_", sites$invid)
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "site_",sites$siteid),
        paste0(prefix.STUDY,"hasSiteID" ),
        paste0(sites$siteid), type="string" 
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "site_",sites$siteid),
        paste0(prefix.RDFS,"label" ),
        paste0("site_",sites$siteid), type="string" 
    )
})
#---- Treatment Arms : Build triples for each unique Treatment Arm
#     Note combination of arm and armcd to capture all possible values
arms <- dm[,c("arm", "armcd")]
arms <- arms[!duplicated(arms),]
arms$armUC   <- toupper(gsub(" ", "", arms$arm))
arms$armcdUC <- toupper(gsub(" ", "", arms$armcd))
ddply(arms, .(armUC), function(arms)
{
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "arm_", arms$armUC),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "Arm")
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "arm_", arms$armUC),
        paste0(prefix.STUDY,"hasArmCode" ),
        paste0(prefix.CUSTOM, "armcd_", arms$armcdUC)
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "arm_", arms$armUC),
        paste0(prefix.RDFS,"label" ),
        paste0(arms$arm), type="string"
    )
})

# Triples that describe the Study CDISCPILOT01.
# TODO: Recode this kludge to creates triples based on unique(studyid)
#       Leave the commented lines intact until kludge recoded.
add.triple(store,
    # paste0(prefix.CDISCPILOT01, "study_", dm$studyid),
    paste0(prefix.CDISCPILOT01, "study_CDISCPILOT01"),
    paste0(prefix.RDF,"type" ),
    paste0(prefix.STUDY, "Study")
)
add.data.triple(store,
    # paste0(prefix.CDISCPILOT01, "study_", dm$studyid),
    paste0(prefix.CDISCPILOT01, "study_CDISCPILOT01"),
    paste0(prefix.STUDY,"hasStudyID" ),
    # paste0(dm$studyid), type="string"
    paste0("CDISCPILOT01"), type="string"
)
add.data.triple(store,
    # paste0(prefix.CDISCPILOT01, "study_", dm$studyid),
    paste0(prefix.CDISCPILOT01, "study_CDISCPILOT01"),
    paste0(prefix.RDFS,"label" ),
    # paste0("study_", dm$studyid), type="string"
    paste0("study_CDISCPILOT01"), type="string"
)

###############################################################################
# Create triples from source domain
# Loop through each row, creating triples for each Person_<n>
#for (i in 1:nrow(dm))
#{
# ddply(dm, .(personNum), function(dm)
ddply(dm, .(subjid), function(dm)
{
    # Create var to shorten code during repeats in following lines
    person <-  paste0("Person_", dm$personNum)
   
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "EnrolledSubject")
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasSubjectID" ),
        paste0(dm$subjid), type="string"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasUniqueSubjectID" ),
        paste0(dm$usubjid), type="string"
    )
    
    # Arm 
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"allocatedToArm" ),
        paste0(prefix.CUSTOM, dm$armcd_Frag) 
    )
    # Treated Arm
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"actualArm"),
        paste0(prefix.CUSTOM, dm$actarmcd_Frag) 
    )
    # Death flag
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"deathFlag" ),
        paste0(dm$dthfl), type="string"
    )

    # Site
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasSite" ),
        paste0(prefix.CDISCPILOT01, "site_",dm$siteid) 
    )
    # Person label
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.RDFS,"label" ),
        paste0(person), type="string"
    )
    # Reference Interval
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasReferenceInterval" ),
        paste0(prefix.CDISCPILOT01, "Interval_RI", dm$personNum)
    )
        #----Reference Interval triples
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Interval_RI", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"ReferenceInterval" )
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "Interval_RI", dm$personNum),
            paste0(prefix.RDFS,"label"),
            paste0("Interval_RI", dm$personNum), type="string"
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Interval_RI", dm$personNum),
            paste0(prefix.TIME,"hasBeginning" ),
            paste0(prefix.CDISCPILOT01, dm$rfstdtc_Frag)
        )
        #---- Assign Date Type
        assignDateType(dm$rfstdtc, dm$rfstdtc_Frag, "ReferenceBegin")

        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Interval_RI", dm$personNum),
            paste0(prefix.TIME,"hasEnd" ),
            paste0(prefix.CDISCPILOT01, dm$rfendtc_Frag)
        )
        #---- Assign Date Type
        assignDateType(dm$rfendtc, dm$rfendtc_Frag, "ReferenceEnd")

    # Lifespan Interval
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasLifespan" ),
        paste0(prefix.CDISCPILOT01, "Interval_LS", dm$personNum)
    )
        #----Lifespan Interval triples
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Interval_LS", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"Lifespan" )
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "Interval_LS", dm$personNum),
            paste0(prefix.RDFS,"label"),
            paste0("Interval_LS", dm$personNum), type="string"
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Interval_LS", dm$personNum),
            paste0(prefix.TIME,"hasBeginning" ),
            paste0(prefix.CDISCPILOT01, dm$brthdate_Frag)
        )
        #---- Assign Date Type
        assignDateType(dm$brthdate, dm$brthdate_Frag, "Birthdate")

        if (!is.na(dm$dthdtc_Frag) && ! as.character(dm$dthdtc_Frag)=="") {
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "Interval_LS", dm$personNum),
                paste0(prefix.TIME,"hasEnd" ),
                paste0(prefix.CDISCPILOT01, dm$dthdtc_Frag)
            )
            #---- Assign Date Type
            assignDateType(dm$dthdtc, dm$dthdtc_Frag, "Deathdate")
        }
    # Study Participation Interval
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasStudyParticipationInterval" ),
        paste0(prefix.CDISCPILOT01, "Interval_SP", dm$personNum)
    )

    #---- Study Participation Interval triples
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Interval_SP", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"StudyParticipationInterval" )
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "Interval_SP", dm$personNum),
            paste0(prefix.RDFS,"label"),
            paste0("Interval_SP", dm$personNum), type="string"
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Interval_SP", dm$personNum),
            paste0(prefix.TIME,"hasBeginning" ),
            paste0(prefix.CDISCPILOT01, dm$rfstdtc_Frag)
        )
        #---- Assign Date Type
        assignDateType(dm$rfstdtc, dm$rfstdtc_Frag, "StudyParticipationBegin")
        
        if (!is.na(dm$rfpendtc_Frag) && ! as.character(dm$rfpendtc_Frag)=="") {
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "Interval_SP", dm$personNum),
                paste0(prefix.TIME,"hasEnd" ),
                paste0(prefix.CDISCPILOT01, dm$rfpendtc_Frag)
            )
            #---- Assign Date Type
            assignDateType(dm$rfpendtc, dm$rfpendtc_Frag, "StudyParticipationEnd")
        }
    # Informed Consent  
    # Create all triples and subgraphs associated with informed conssent if the 
    #    date of informed consent is non-missing
    if (!is.na(dm$rficdtc_Frag) && ! as.character(dm$rficdtc_Frag)=="") {    
        add.triple(store,
            paste0(prefix.CDISCPILOT01, person),
            paste0(prefix.STUDY,"participatesIn" ),
            paste0(prefix.CDISCPILOT01, "InformedConsent_", dm$personNum)
        )
            # InformedConsent_(n)
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "InformedConsent_", dm$personNum),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.CODE,"informedconsentterm-DEFAULT")
            )
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "InformedConsent_", dm$personNum),
                paste0(prefix.STUDY,"hasActivityCode" ),
                paste0(prefix.CODE,"informedconsentterm-DEFAULT")
            )
            # Key triple to link to Interval for Informed consent
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "InformedConsent_", dm$personNum),
                paste0(prefix.STUDY,"hasActivityInterval" ),
                paste0(prefix.CDISCPILOT01,"Interval_IC", dm$personNum)
            )
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "InformedConsent_", dm$personNum),
                paste0(prefix.STUDY,"hasActivityOutcome" ),
                paste0(prefix.CODE,"InformedConsent_granted")
            )
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "InformedConsent_", dm$personNum),
                paste0(prefix.RDFS,"label"),
                paste0("InformedConsent_", dm$personNum), type="string"
            )
                # Interval_IC(n)
                add.triple(store,
                    paste0(prefix.CDISCPILOT01,"Interval_IC", dm$personNum),
                    paste0(prefix.RDF,"type" ),
                    paste0(prefix.STUDY, "InformedConsentInterval")
                )
                add.data.triple(store,
                    paste0(prefix.CDISCPILOT01, "Interval_IC", dm$personNum),
                    paste0(prefix.RDFS,"label"),
                    paste0("Interval_IC", dm$personNum), type="string"
                )
                add.triple(store,
                    paste0(prefix.CDISCPILOT01,"Interval_IC", dm$personNum),
                    paste0(prefix.TIME,"hasBeginning" ),
                    paste0(prefix.CDISCPILOT01, dm$rficdtc_Frag)
                )
                #---- Assign Date Type
                assignDateType(dm$rficdtc, dm$rficdtc_Frag, "InformedConsentBegin")
                #Note: There is no informedConsentEnd in the source data
    }
    # Product Administration
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum)
    )
        #ProductAdministration_(n)
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY, "ProductAdministration")
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum),
            paste0(prefix.RDFS,"label" ),
            paste0("ProductAdministration_", dm$personNum), type="string"
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum),
            paste0(prefix.STUDY,"hasActivityInterval" ),
            paste0(prefix.CDISCPILOT01, "Interval_PA", dm$personNum)
        )
            # Interval_PA(n)
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "Interval_PA", dm$personNum),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.CDISCPILOT01, "ProductAdministrationInterval")
            )
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "Interval_PA", dm$personNum),
                paste0(prefix.RDFS,"label" ),
                paste0("Interval_PA", dm$personNum), type="string"
            )
            # Product Administration Begin
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "Interval_PA", dm$personNum),
                paste0(prefix.TIME,"hasBeginning" ),
                paste0(prefix.CDISCPILOT01, dm$rfxstdtc_Frag)
            )
            #---- Assign Date Type
            assignDateType(dm$rfxstdtc, dm$rfxstdtc_Frag, "ProductAdministrationBegin")

            # Product Administration End
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "Interval_PA", dm$personNum),
                paste0(prefix.TIME,"hasEnd" ),
                paste0(prefix.CDISCPILOT01, dm$rfxendtc_Frag)
            )
            #---- Assign Date Type
            assignDateType(dm$rfxendtc, dm$rfxendtc_Frag, "ProductAdministrationEnd")

    # DemographicDataCollection
    #  Age, Ethnicity, Race, Sex, etc. are all part of the Demographic Data collection
    #    triples for a specific person. Person_<n> -->  DemographicDataCollection_<n>       
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum)
    )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"DemographicDataCollection" )
        )  
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.RDFS,"label" ),
            paste0("Demographic data collection ", dm$personNum), type="string"
        )  
        # Age
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.STUDY,"hasAge" ),
            paste0(prefix.CUSTOM, dm$age_Frag)
    )
           #----Age Measurement Triples
           #TODO: Confirm these against AO's model!
           add.triple(store,
               paste0(prefix.CUSTOM, dm$age_Frag),
               paste0(prefix.RDF,"type" ),
               paste0(prefix.CODE,"Age")
           )
           #!! Note hard coding here for unit and formation of term
           add.triple(store,
               paste0(prefix.CUSTOM, dm$age_Frag),
               paste0(prefix.STUDY,"hasActivityOutcome" ),
               paste0(prefix.CUSTOM,"AgeOutcomeTerm_",dm$age,"YRS")
           )
           add.data.triple(store,
               paste0(prefix.CUSTOM, dm$age_Frag),
               paste0(prefix.RDFS,"label" ),
               paste0(dm$age_Frag), type="string"
           )
        # Ethnicity
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.STUDY,"hasEthnicity" ),
            paste0(prefix.CDISCSDTM, dm$ethnic_) 
        )
        # Race
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.STUDY,"hasRace" ),
            paste0(prefix.CDISCSDTM, dm$race_) 
        )
        # Sex 
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.STUDY,"hasSex" ),
            paste0(prefix.CDISCSDTM, dm$sex_) 
        )
        #DEL  ActivityCode no longer in use 2017-04-19
        #add.triple(store,
        #     paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
        #     paste0(prefix.STUDY,"hasActivityCode" ),
        #     paste0(prefix.CODE,"observationterm-DEMOG")
        #)    
        add.triple(store,
             paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
             paste0(prefix.STUDY,"hasDate" ),
             paste0(prefix.CDISCPILOT01,dm$dmdtc_Frag)
        )    
        #---- Assign Date Type
        assignDateType(dm$rfxendtc, dm$dmdtc_Frag, "DemogDataCollectionDate")

    # Study ID. Triples about the study are created ONE time, therefore not here!
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "study_", dm$studyid)
    )
    # Randomization
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "Randomization_", dm$personNum)
    )

        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Randomization_", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"Randomization" )
        ) 
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "Randomization_", dm$personNum),
            paste0(prefix.RDFS,"label" ),
            paste0("Randomization ",dm$personNum), type="string"
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Randomization_", dm$personNum),
            paste0(prefix.STUDY,"hasActivityOutcomeCode" ),
            paste0(prefix.CUSTOM,"armcd_",dm$arm_)
        )
}) # end of ddply for DM domain   