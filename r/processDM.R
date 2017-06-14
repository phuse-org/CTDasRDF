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
#       StudyParticipationBegin set as date of informed consent as per email from AO 2071-02-16
#       Instance  data named lowercase. Eg:  arm_1
#       Class codes named using CamelCase. Eg: InformedConsentAdult_1
# TODO: 
#   
#  - Collapse code segments in FUNT()s where possible
#  - Add a function that evaluates each DATE value and types it as either
#     xsd:date if valid yyyy-mm-dd value, or as xsd:string if(invalid/incomplete 
#     date OR is a datetime value)
#  - Consider new triples for incomplete dates (YYYY triple, MON  triple, etc.)
#     for later implmentations
###############################################################################

#------------------------------------------------------------------------------
#  Single/Unique Resource Creation for CUSTOM, CODE, CDISCPILOT01 namespaces
#   Create triples for unique values (ones that are not one obs per patient)
#    eg. Treatment arm, country, etc.
#------------------------------------------------------------------------------
#-- CUSTOM namespace ----------------------------------------------------------
#-- Treatment Arms 
#   Create custom terminlogy list for arm_1, arm_2 etc.
#TODO: Change this to a melt() similar to processVS.R
dm1 <- dm[,c("actarm", "actarmcd", "actarmcd_Frag")]

# ERROR IN THE FOLLOWING
dm1 <- rename(dm1, c("actarm"= "arm", "actarmcd" = "armcd", "actarmcd_Frag" = "armcd_Frag"))

dm2 <- dm[,c("arm", "armcd", "armcd_Frag")]
dmArms <- rbind(dm1,dm2)
dmArms <- dmArms[!duplicated(dmArms), ]
ddply(dmArms, .(armcd_Frag), function(dmArms)
{
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.OWL, "Class")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CUSTOM, "CustomConcept")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CODE, "RandomizationOutcome")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CUSTOM, "Arm")
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"label" ),
        paste0(dmArms$arm), type="string"
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"label" ),
        paste0(dmArms$armcd), type="string"
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "Arm")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "RandomizationOutcome")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "AdministrativeActivityOutcome")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "CustomConcept")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "ActivityOutcome")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDFS,"subClassOf" ),
        paste0(prefix.CUSTOM, "RandomizationOutcome")
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.SKOS,"altLabel" ),
        paste0(dmArms$armcd), type="string"
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.SKOS,"prefLabel" ),
        paste0(dmArms$arm), type="string"
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, dmArms$armcd_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CUSTOM, "Arm")
    )
})
#-- Age
#   Keep only the columns needed to create triples in the terminology file
ageList <- dm[,c("age", "ageu", "age_Frag")]
ageList <- ageList[!duplicated(ageList), ]
# Loop through the arm_ codes to create  custom-terminology triples
#ddply(ageList, .(age_Frag), function(ageList)
#{
#    add.triple(custom,
#        paste0(prefix.CUSTOM, ageList$age_Frag),
#        paste0(prefix.RDF,"type" ),
#        paste0(prefix.CUSTOM, "AgeOutcomeTerm")
#    )
#    add.data.triple(custom,
#        paste0(prefix.CUSTOM, ageList$age_Frag),
#        paste0(prefix.RDFS,"label" ),
#        paste0(ageList$age, " ", ageList$ageu), type="string"
#    )
#    #TODO Make this triple conditional: if ageu=YEARS, then:
#    add.triple(custom,
#        paste0(prefix.CUSTOM, ageList$age_Frag),
#        paste0(prefix.CODE,"hasUnit" ),
#        paste0(prefix.TIME, "unitYear")
#    )
#    add.triple(custom,
#        paste0(prefix.CUSTOM, ageList$age_Frag),
#        paste0(prefix.CODE,"hasUnit" ),
#        paste0(prefix.TIME, "unitYear")
#    )
#    add.data.triple(custom,
#        paste0(prefix.CUSTOM, ageList$age_Frag),
#        paste0(prefix.CODE,"hasValue" ),
#        paste0(ageList$age), type="int"
#    )
#})    
#-- CODE namespace ------------------------------------------------------------
#-- Country
countries <- dm[,c("country", "country_Frag" )]
countries <<- countries[!duplicated(countries), ]
countries <-na.omit(countries)

ddply(countries, .(country_Frag), function(countries)
{
    add.triple(code,
        paste0(prefix.CODE, countries$country_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CODE,"Country" )
    )
    add.triple(code,
        paste0(prefix.CODE, countries$country_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CODE,"DefinedConcept" )
    )
    add.triple(code,
        paste0(prefix.CODE, countries$country_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.RDFS,"Resource" )
    )
    add.triple(code,
        paste0(prefix.CODE, countries$country_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.OWL,"Thing" )
    )
    add.data.triple(code,
        paste0(prefix.CODE, countries$country_Frag),
        paste0(prefix.RDFS,"label" ),
        paste0(countries$country), type="string" 
    )
})
#-- CDISCPILOT01 namespace -----------------------------------------------------------
#-- Treatment Arms
#  Note combination of arm and armcd to capture all possible values
arms <- dm[,c("arm", "armcd")]
arms <- arms[!duplicated(arms),]
arms$armUC   <- toupper(gsub(" ", "", arms$arm))
arms$armcdUC <- toupper(gsub(" ", "", arms$armcd))
ddply(arms, .(armUC), function(arms)
{
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, "arm_", arms$armUC),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "Arm")
    )
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, "arm_", arms$armUC),
        paste0(prefix.STUDY,"hasArmCode" ),
        paste0(prefix.CUSTOM, "armcd_", arms$armcdUC)
    )
    add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, "arm_", arms$armUC),
        paste0(prefix.RDFS,"label" ),
        paste0(arms$arm), type="string"
    )
})
#-- Study CDISCPILOT01
# TODO: Recode this kludge to create triples based on unique(studyid)
#       Leave the commented lines intact until kludge recoded.
add.triple(cdiscpilot01,
    # paste0(prefix.CDISCPILOT01, "study_", dm$studyid),
    paste0(prefix.CDISCPILOT01, "study_CDISCPILOT01"),
    paste0(prefix.RDF,"type" ),
    paste0(prefix.STUDY, "Study")
)
add.data.triple(cdiscpilot01,
    # paste0(prefix.CDISCPILOT01, "study_", dm$studyid),
    paste0(prefix.CDISCPILOT01, "study_CDISCPILOT01"),
    paste0(prefix.STUDY,"hasStudyID" ),
    # paste0(dm$studyid), type="string"
    paste0("CDISCPILOT01"), type="string"
)
add.data.triple(cdiscpilot01,
    # paste0(prefix.CDISCPILOT01, "study_", dm$studyid),
    paste0(prefix.CDISCPILOT01, "study_CDISCPILOT01"),
    paste0(prefix.RDFS,"label" ),
    # paste0("study_", dm$studyid), type="string"
    paste0("study_CDISCPILOT01"), type="string"
)
#-- Investigators 
investigators <- dm[,c("invnam", "invid", "invid_Frag")]
investigators <- investigators[!duplicated(investigators),]  # Unique investigator ID 
ddply(investigators, .(invnam), function(investigators)
{
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, investigators$invid_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "Investigator")
    )
    add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, investigators$invid_Frag),
        paste0(prefix.STUDY,"hasInvestigatorID" ),
        paste0(investigators$invid), type="string"
    )
    add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, investigators$invid_Frag),
        paste0(prefix.STUDY,"hasLastName" ),
        paste0(investigators$invnam), type="string"
    )
    add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, investigators$invid_Frag),
        paste0(prefix.RDFS,"label" ),
        paste0("Investigator ", investigators$invid), type="string"
    )
})
#-- Sites 
sites <- dm[,c("siteid", "siteid_Frag", "invid_Frag", "country", "country_Frag" )]
sites <<- sites[!duplicated(sites), ]
ddply(sites, .(siteid), function(sites)
{
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, sites$siteid_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY,"Site" )
    )
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, sites$siteid_Frag),
        paste0(prefix.STUDY,"hasCountry" ),
        paste0(prefix.CODE,sites$country_Frag )
    )
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, sites$siteid_Frag),
        paste0(prefix.STUDY,"hasInvestigator" ),
        paste0(prefix.CDISCPILOT01, sites$invid_Frag)
    )
    add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, sites$siteid_Frag),
        paste0(prefix.STUDY,"hasSiteID" ),
        paste0(sites$siteid), type="string" 
    )
    add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, sites$siteid_Frag),
        paste0(prefix.RDFS,"label" ),
        paste0("site-",sites$siteid), type="string" 
    )
})
#------------------------------------------------------------------------------
# Triples from each row in the source domain
# Loop through each row, creating triples for each Person_<n>
#------------------------------------------------------------------------------
ddply(dm, .(subjid), function(dm)
{
    # Create var to shorten code during repeats in following lines
    person <-  paste0("Person_", dm$personNum)
   
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "EnrolledSubject")
    )
    add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasSubjectID" ),
        paste0(dm$subjid), type="string"
    )
    add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasUniqueSubjectID" ),
        paste0(dm$usubjid), type="string"
    )
    #DEL moved to randomization
    #add.triple(cdiscpilot01,
    #    paste0(prefix.CDISCPILOT01, person),
    #    paste0(prefix.STUDY,"allocatedToArm" ),
    #    paste0(prefix.CUSTOM, dm$armcd_Frag) 
    #)
    # Treated Arm
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"actualArm"),
        paste0(prefix.CD01P, dm$actarmcd_Frag) 
    )
    # Death flag
    add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"deathFlag" ),
        paste0(dm$dthfl), type="string"
    )
    # Site
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasSite" ),
        paste0(prefix.CDISCPILOT01, dm$siteid_Frag) 
    )
    # Person label
    add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.RDFS,"label" ),
        paste0("Person ", dm$personNum), type="string"
    )
    # Reference Interval
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasReferenceInterval" ),
        paste0(prefix.CDISCPILOT01, "ReferenceInterval_", dm$personNum)
    )
        #----Reference Interval triples
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "ReferenceInterval_", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"ReferenceInterval" )
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "ReferenceInterval_", dm$personNum),
            paste0(prefix.RDFS,"label"),
            paste0("Reference Interval ", dm$personNum), type="string"
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "ReferenceInterval_", dm$personNum),
            paste0(prefix.TIME,"hasBeginning" ),
            paste0(prefix.CDISCPILOT01, dm$rfstdtc_Frag)
        )
        #---- Assign Date Type
        assignDateType(dm$rfstdtc, dm$rfstdtc_Frag, "ReferenceBegin")

        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "ReferenceInterval_", dm$personNum),
            paste0(prefix.TIME,"hasEnd" ),
            paste0(prefix.CDISCPILOT01, dm$rfendtc_Frag)
        )
        #---- Assign Date Type
        assignDateType(dm$rfendtc, dm$rfendtc_Frag, "ReferenceEnd")
    # Lifespan Interval
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasLifespan" ),
        paste0(prefix.CDISCPILOT01, "Lifespan_", dm$personNum)
    )
        #----Lifespan Interval triples
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "Lifespan_", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"Lifespan" )
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "Lifespan_", dm$personNum),
            paste0(prefix.RDFS,"label"),
            paste0("Lifespan Interval ", dm$personNum), type="string"
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "Lifespan_", dm$personNum),
            paste0(prefix.TIME,"hasBeginning" ),
            paste0(prefix.CDISCPILOT01, dm$brthdate_Frag)
        )
        #---- Assign Date Type
        assignDateType(dm$brthdate, dm$brthdate_Frag, "Birthdate")

        if (!is.na(dm$dthdtc_Frag) && ! as.character(dm$dthdtc_Frag)=="") {
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "Lifespan_", dm$personNum),
                paste0(prefix.TIME,"hasEnd" ),
                paste0(prefix.CDISCPILOT01, dm$dthdtc_Frag)
            )
            #---- Assign Date Type
            assignDateType(dm$dthdtc, dm$dthdtc_Frag, "Deathdate")
        }
    # Study Participation Interval
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasStudyParticipationInterval" ),
        paste0(prefix.CDISCPILOT01, "StudyParticipationInterval_", dm$personNum)
    )
    #---- Study Participation Interval triples
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "StudyParticipationInterval_", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"StudyParticipationInterval" )
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "StudyParticipationInterval_", dm$personNum),
            paste0(prefix.RDFS,"label"),
            paste0("Study Participation Interval ", dm$personNum), type="string"
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "StudyParticipationInterval_", dm$personNum),
            paste0(prefix.TIME,"hasBeginning" ),
            paste0(prefix.CDISCPILOT01, dm$dmdtc_Frag)
        )
        #---- Assign Date Type
        if (!is.na(dm$rfpendtc_Frag) && ! as.character(dm$rfpendtc_Frag)=="") {
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "StudyParticipationInterval_", dm$personNum),
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
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, person),
            paste0(prefix.STUDY,"participatesIn" ),
            paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum)
        )
            # InformedConsentAdult_(n)
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.CODE,"InformedConsentAdult")
            )
            add.data.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
                paste0(prefix.RDFS,"label"),
                paste0("Informed consent ", dm$personNum), type="string"
            )
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
                paste0(prefix.CODE,"hasOutcome" ),
                paste0(prefix.CODE,"InformedConsentOutcome_", dm$personNum)
            )
                 # InformedConsentAdult_<n> to code.ttl
                add.triple(code,
                    paste0(prefix.CODE, "InformedConsentOutcome_", dm$personNum),
                    paste0(prefix.RDF,"type" ),
                    paste0(prefix.CODE, "InformedConsentOutcome")
                )
                add.data.triple(cdiscpilot01,
                    paste0(prefix.CODE, "InformedConsentOutcome_", dm$personNum),
                    paste0(prefix.RDFS,"label"),
                    paste0("informed consent granted "), type="string"
                )
            # Key triple to link to Interval for Informed consent
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
                paste0(prefix.STUDY,"hasActivityInterval" ),
                paste0(prefix.CDISCPILOT01,"InformedConsentInterval_", dm$personNum)
            )
                #InformedConsentInterval_<n>
                add.triple(cdiscpilot01,
                    paste0(prefix.CDISCPILOT01,"InformedConsentInterval_", dm$personNum),
                    paste0(prefix.RDF,"type" ),
                    paste0(prefix.STUDY,"InformedConsentInterval" )
                )
                add.data.triple(cdiscpilot01,
                    paste0(prefix.CDISCPILOT01,"InformedConsentInterval_", dm$personNum),
                    paste0(prefix.RDFS,"label"),
                    paste0("Informed Consent Interval ", dm$personNum), type="string"
                )            
                add.triple(cdiscpilot01,
                    paste0(prefix.CDISCPILOT01,"InformedConsentInterval_", dm$personNum),
                    paste0(prefix.TIME,"hasBeginning" ),
                    paste0(prefix.CDISCPILOT01, dm$rficdtc_Frag )
                )
                # Create triples for specific date type assignments. 
                # StudyParticipationBegin set as date of informed consent as per email from AO 2071-02-16
                assignDateType(dm$rficdtc, dm$rficdtc_Frag, "InformedConsentBegin")
                assignDateType(dm$rficdtc, dm$rficdtc_Frag, "StudyParticipationBegin")
                #Note: There is no informedConsentEnd in the source data
    }
    # Product Administration
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum)
    )
        #ProductAdministration_(n)
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY, "ProductAdministration")
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum),
            paste0(prefix.RDFS,"label" ),
            paste0("Product administration ", dm$personNum), type="string"
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum),
            paste0(prefix.STUDY,"hasActivityInterval" ),
            paste0(prefix.CDISCPILOT01, "Interval_PA", dm$personNum)
        )
            # Interval_PA(n)
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "Interval_PA", dm$personNum),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.STUDY, "ProductAdministrationInterval")
            )
            add.data.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "Interval_PA", dm$personNum),
                paste0(prefix.RDFS,"label" ),
                paste0("Product Administration Interval ", dm$personNum), type="string"
            )
            # Product Administration Begin
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "Interval_PA", dm$personNum),
                paste0(prefix.TIME,"hasBeginning" ),
                paste0(prefix.CDISCPILOT01, dm$rfxstdtc_Frag)
            )
            #---- Assign Date Type
            assignDateType(dm$rfxstdtc, dm$rfxstdtc_Frag, "ProductAdministrationBegin")

            # Product Administration End
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "Interval_PA", dm$personNum),
                paste0(prefix.TIME,"hasEnd" ),
                paste0(prefix.CDISCPILOT01, dm$rfxendtc_Frag)
            )
            #---- Assign Date Type
            assignDateType(dm$rfxendtc, dm$rfxendtc_Frag, "ProductAdministrationEnd")
    # DemographicDataCollection
    #  Age, Ethnicity, Race, Sex, etc. are all part of the Demographic Data collection
    #    triples for a specific person. Person_<n> -->  DemographicDataCollection_<n>       
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum)
    )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.CODE,"DemographicDataCollection" )
        )  
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.RDFS,"label" ),
            paste0("Demographic data collection ", dm$personNum), type="string"
        )  
        # Age
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.CODE,"hasAge" ),
            paste0(prefix.CDISCPILOT01, dm$age_Frag)
        )
           #----Age Measurement Triples
        
           # Age unit from ageu
           if (grepl("YEARS",dm$ageu)){
               add.triple(cdiscpilot01,
                   paste0(prefix.CDISCPILOT01, dm$age_Frag),
                   paste0(prefix.CODE, "hasUnit" ),
                   paste0(prefix.TIME, "unitYear")
                )
           }
           add.data.triple(cdiscpilot01,
               paste0(prefix.CDISCPILOT01, dm$age_Frag),
               paste0(prefix.CODE, "hasValue" ),
               paste0(dm$age), type="int"
           )
           add.triple(cdiscpilot01,
               paste0(prefix.CDISCPILOT01, dm$age_Frag),
               paste0(prefix.RDF,"type" ),
               paste0(prefix.STUDY, "AgeOutcome")
           )
           add.data.triple(cdiscpilot01,
               paste0(prefix.CDISCPILOT01, dm$age_Frag),
               paste0(prefix.RDFS,"label" ),
               paste0(dm$age, " ", dm$ageu), type="string"
           )
           add.data.triple(cdiscpilot01,
               paste0(prefix.CDISCPILOT01, dm$age_Frag),
               paste0(prefix.SKOS,"prefLabel" ),
               paste0(dm$age, " ", dm$ageu), type="string"
           )
           add.triple(cdiscpilot01,
               paste0(prefix.CDISCPILOT01, dm$age_Frag),
               paste0(prefix.RDF,"type" ),
               paste0(prefix.STUDY,"AgeOutcome")
           )
        # Ethnicity
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.CODE,"hasEthnicity" ),
            paste0(prefix.SDTMTERM, dm$ethnic_) 
        )
        # Race
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.CODE,"hasRace" ),
            paste0(prefix.SDTMTERM, dm$race_) 
        )
        # Sex 
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
            paste0(prefix.CODE,"hasSex" ),
            paste0(prefix.SDTMTERM, dm$sex_) 
        )
        add.triple(cdiscpilot01,
             paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
             paste0(prefix.STUDY,"hasDate" ),
             paste0(prefix.CDISCPILOT01,dm$dmdtc_Frag)
        )    
        #---- Assign Date Type
        assignDateType(dm$rfxendtc, dm$dmdtc_Frag, "DemogDataCollectionDate")
    # Randomization
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "RandomizationBAL3_", dm$personNum)
    )
        #Hard coding of RandomizationBAL3. Email from AO 05May17 for explanation
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "Randomization_", dm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.CODE,"RandomizationBAL3" )
        ) 
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "Randomization_", dm$personNum),
            paste0(prefix.RDFS,"label" ),
            paste0("Randomization ",dm$personNum), type="string"
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "Randomization_", dm$personNum),
            paste0(prefix.CODE,"hasOutcome" ),
            paste0(prefix.CUSTOM,dm$armcd_Frag)
        )
}) # end of ddply for DM domain   