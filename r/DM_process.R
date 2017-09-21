# FILE: DM_process.R
# DESC: Create DM domain triples
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: TESTING MODE: Uses only first 6 patients (set for DM migrates across 
#       all domains)
#     Birthdate and Deathdate are of the Lifespan interval. 
#     StudyParticipationBegin = date of informed consent: AO email 2071-02-16
#     Instance  data named lowercase. Eg:  arm_1
#     Class codes named using CamelCase. Eg: InformedConsentAdult_1
#     S,O value creation takes place in DM_Impute.R and DM_Frag.R
# Hardcoding:
#   DemographicsDataCollection to ActivityStatus_1 = CO = Completed
# TODO:  Build out code.ttl at a later time. See comment in code, below.
#______________________________________________________________________________ 

# Person ----
# ** hasStudyParticipant ----
# List of persons assigned to study
u_Person <- dm[!duplicated(dm$personNum),]
ddply(u_Person, .(personNum), function(u_Person)
{
  add.triple(cdiscpilot01,
    paste0(prefix.CD01P, u_Person$study),
    paste0(prefix.STUDY,"hasStudyParticipant" ),
    paste0(prefix.CDISCPILOT01, "Person_", u_Person$personNum)
  )
})
rm(u_Person) # Clean up

# Investigators ----
investigators <- dm[,c("invnam", "invid", "inv", "invid_Frag")]
u_Invest <- investigators[!duplicated(investigators),]  # Unique investigator ID 
ddply(u_Invest, .(invnam), function(u_Invest)
{
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, u_Invest$inv),
    paste0(prefix.RDF,"type" ),
    paste0(prefix.STUDY, "Investigator")
  )
  add.data.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, u_Invest$inv),
    paste0(prefix.SKOS, 'prefLabel'),
    paste0("Investigator ", u_Invest$invid), type="string"
  )
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, u_Invest$inv),
    paste0(prefix.STUDY,"hasInvestigatorID" ),
    paste0(prefix.CDISCPILOT01, u_Invest$invid_Frag)
  )
    # Investigator identifier is further broken down
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, u_Invest$invid_Frag),
      paste0(prefix.RDF,"type" ),
      paste0(prefix.STUDY, "InvestigatorIdentifier")
    )
    add.data.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, u_Invest$invid_Frag),
      paste0(prefix.SKOS,"prefLabel" ),
      paste0(u_Invest$invid)
    )
  add.data.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, u_Invest$inv),
    paste0(prefix.STUDY, 'hasLastName'),
    paste0(u_Invest$invnam), type="string"
  )
    
    

})
rm(u_Invest) # Clean up

# Sites ----
sites <- dm[,c("siteid", "siteid_Frag", "inv", "country", "country_Frag" )]
u_Site <- sites[!duplicated(sites), ]
ddply(u_Site, .(siteid), function(u_Site)
{
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, u_Site$siteid_Frag),
    paste0(prefix.RDF,"type" ),
    paste0(prefix.STUDY,"Site" )
  )
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, u_Site$siteid_Frag),
    paste0(prefix.STUDY, "hasCountry" ),
    paste0(prefix.CODE, u_Site$country_Frag )
  )
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, u_Site$siteid_Frag),
    paste0(prefix.STUDY, "hasInvestigator" ),
    paste0(prefix.CDISCPILOT01, u_Site$inv)
  )
  add.data.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, u_Site$siteid_Frag),
    paste0(prefix.STUDY,"hasSiteID" ),
    paste0(u_Site$siteid), type="string" 
  )
  add.data.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, u_Site$siteid_Frag),
    paste0(prefix.SKOS,"prefLabel" ),
    paste0("site-",u_Site$siteid), type="string" 
  )
})
rm(u_Site) # Clean up

# Process each row of domain ----
#   Triples created from each row, for each Person_<n>
ddply(dm, .(subjid), function(dm)
{
  # ** Person_(n) ----
  person <- paste0("Person_", dm$personNum)

  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, person),
    paste0(prefix.RDF,"type" ),
    paste0(prefix.STUDY, "EnrolledSubject")
  )
  # SubjectID
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, person),
    paste0(prefix.STUDY,"hasSubjectID" ),
    paste0(prefix.CDISCPILOT01, dm$subjid_Frag)
  )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, dm$subjid_Frag),
      paste0(prefix.RDF,"type" ),
      paste0(prefix.STUDY, "SubjectIdentifier")
    )
    add.data.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, dm$subjid_Frag),
      paste0(prefix.SKOS,"prefLabel" ),
      paste0(dm$subjid)
    )
  #Unique Subject ID  
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, person),
    paste0(prefix.STUDY,"hasUniqueSubjectID" ),
    paste0(prefix.CDISCPILOT01, dm$usubjid_Frag)
  )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, dm$usubjid_Frag),
      paste0(prefix.RDF,"type" ),
      paste0(prefix.STUDY, "UniqueSubjectIdentifier")
    )
    add.data.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, dm$usubjid_Frag),
      paste0(prefix.SKOS,"prefLabel" ),
      paste0(dm$usubjid)
    )
  # Treatment arm 
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
    paste0(prefix.CD01P, dm$siteid_Frag) 
  )
  # Person label
  add.data.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, person),
    paste0(prefix.SKOS,"prefLabel" ),
    paste0("Person ", dm$personNum), type="string"
  )
  # Reference Interval
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, person),
    paste0(prefix.STUDY,"hasReferenceInterval" ),
    paste0(prefix.CDISCPILOT01, "ReferenceInterval_", dm$personNum)
  )
    # **** Reference Interval ----
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
    # Type to Date triples
    assignDateType(dm$rfstdtc, dm$rfstdtc_Frag, "ReferenceBegin")

    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "ReferenceInterval_", dm$personNum),
      paste0(prefix.TIME,"hasEnd" ),
      paste0(prefix.CDISCPILOT01, dm$rfendtc_Frag)
    )
    # Type to Date triples
    assignDateType(dm$rfendtc, dm$rfendtc_Frag, "ReferenceEnd")

  # Lifespan Interval
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, person),
    paste0(prefix.STUDY,"hasLifespan" ),
    paste0(prefix.CDISCPILOT01, "Lifespan_", dm$personNum)
  )
    # **** Lifespan Interval ----
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
    # **** Study Participation Interval ----
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
    
  # InformedConsentAdult  
  # Create all triples and subgraphs associated with informed conssent if the 
  #  date of informed consent is non-missing
  if (!is.na(dm$rficdtc_Frag) && ! as.character(dm$rficdtc_Frag)=="") {  
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, person),
      paste0(prefix.STUDY,"participatesIn" ),
      paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum)
    )
      # **** Informed Consent Adult ----
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
      paste0(prefix.RDF,"type" ),
      paste0(prefix.CODE,"InformedConsentAdult")
    )
    add.data.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
      paste0(prefix.SKOS,"prefLabel"),
      paste0("Informed consent ", dm$personNum), type="string"
    )
    #HARDCODE to completed. Add logic later.
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
      paste0(prefix.STUDY,"activityStatus"),
      paste0(prefix.CODE, "ActivityStatus_1")
    )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
      paste0(prefix.STUDY,"outcome" ),
      paste0(prefix.CODE, dm$informedConsentOut_Frag)
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
      # StudyParticipationBegin set as date of informed consent as per 
      # mail from AO 2071-02-16
      assignDateType(dm$rficdtc, dm$rficdtc_Frag, "InformedConsentBegin")
      assignDateType(dm$rficdtc, dm$rficdtc_Frag, "StudyParticipationBegin")
      #Note: There is no informedConsentEnd in the source data
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
      paste0(prefix.STUDY,"hasCode" ),
      paste0(prefix.CODE,"InformedConsentAdult")
    )
    #HARDCODE 
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
      paste0(prefix.STUDY,"hasStartRule" ),
      paste0(prefix.STUDY,"StartRuleDefault_1")
    )
 } # end informed consent adult
    
  # Product Administration
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, person),
    paste0(prefix.STUDY,"participatesIn" ),
    paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum)
  )
    
    # **** Product Administration ---- 
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum),
      paste0(prefix.RDF,"type" ),
      paste0(prefix.STUDY, "ProductAdministration")
    )
    add.data.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum),
      paste0(prefix.SKOS,"prefLabel" ),
      paste0("Product administration ", dm$personNum), type="string"
    )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum),
      paste0(prefix.STUDY,"hasCode" ),
      paste0(prefix.STUDY, "ProductAdministration")
    )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "ProductAdministration_", dm$personNum),
      paste0(prefix.STUDY,"hasActivityInterval" ),
      paste0(prefix.CDISCPILOT01, "ProductAdministrationInterval_", dm$personNum)
    )
      # ****** Product Adminstration Interval ----
      add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, "ProductAdministrationInterval_", dm$personNum),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "ProductAdministrationInterval")
      )
      add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, "ProductAdministrationInterval_", dm$personNum),
        paste0(prefix.RDFS,"label" ),
        paste0("Product Administration Interval ", dm$personNum), type="string"
      )
      # Product Administration Begin
      add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, "ProductAdministrationInterval_", dm$personNum),
        paste0(prefix.TIME,"hasBeginning" ),
        paste0(prefix.CDISCPILOT01, dm$rfxstdtc_Frag)
      )
      #---- Assign Date Type
      assignDateType(dm$rfxstdtc, dm$rfxstdtc_Frag, "ProductAdministrationBegin")

      # Product Administration End
      add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, "ProductAdministrationInterval_", dm$personNum),
        paste0(prefix.TIME,"hasEnd" ),
        paste0(prefix.CDISCPILOT01, dm$rfxendtc_Frag)
      )
      #---- Assign Date Type
      assignDateType(dm$rfxendtc, dm$rfxendtc_Frag, "ProductAdministrationEnd")

  # Demographic Data Collection ----
  #  Age, Ethnicity, Race, Sex, etc. are all part of the Demographic Data collection
  #  triples for a specific person. Person_<n> -->  DemographicDataCollection_<n>     
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, person),
    paste0(prefix.STUDY,"participatesIn" ),
    paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum)
  )
    # ** Age ----
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
      paste0(prefix.CODE,"hasAge" ),
      paste0(prefix.CDISCPILOT01, dm$age_Frag)
    )
       # Age unit from ageu
       if (grepl("YEARS",dm$ageu)){
         add.triple(cdiscpilot01,
           paste0(prefix.CDISCPILOT01, dm$age_Frag),
           paste0(prefix.CODE, "hasUnit" ),
           paste0(prefix.TIME, dm$ageu_Frag)
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
         paste0(prefix.SKOS,"prefLabel" ),
         paste0(dm$age, " ", dm$ageu), type="string"
       )
       add.triple(cdiscpilot01,
         paste0(prefix.CDISCPILOT01, dm$age_Frag),
         paste0(prefix.RDF,"type" ),
         paste0(prefix.STUDY,"AgeOutcome")
       )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
      paste0(prefix.RDF,"type" ),
      paste0(prefix.CODE,"DemographicDataCollection" )
    )  
    #TODO Screening 1 currently hard coded because demog info collected at screening 1
    #  Either fix data or change label?
    add.data.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
      paste0(prefix.SKOS,"prefLabel" ),
      paste0("P",dm$personNum, " Screening 1 Demographic data collection"), type="string"
    ) 
    
    #activityStatus
    #!!HARDCODE = CO hard coded for completed! 
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
      paste0(prefix.STUDY,"activityStatus" ),
      paste0(prefix.CODE, "ActivityStatus_1") 
    )
    
    # Ethnicity
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
      paste0(prefix.STUDY,"ethnicity" ),
      paste0(prefix.SDTMTERM, dm$ethnic_Frag) 
    )
    # Code
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
      paste0(prefix.STUDY,"hasCode" ),
      paste0(prefix.CODE, "DemographicDataCollection") 
    )
    # Demog Data Collection Date
    add.triple(cdiscpilot01,
       paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
       paste0(prefix.STUDY,"hasDate" ),
       paste0(prefix.CDISCPILOT01,dm$dmdtc_Frag)
    )  
      #---- Assign Date Type
      assignDateType(dm$rfxendtc, dm$dmdtc_Frag, "DemogDataCollectionDate")
    # Race
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
      paste0(prefix.STUDY,"race" ),
      paste0(prefix.SDTMTERM, dm$race_Frag) 
    )
    # Sex 
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
      paste0(prefix.STUDY,"sex" ),
      paste0(prefix.SDTMTERM, dm$sex_Frag) 
    )
  # RandomizationBAL
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, person),
    paste0(prefix.STUDY,"participatesIn" ),
    paste0(prefix.CDISCPILOT01, dm$rand, "_", dm$personNum)
  )
    # ** Randomization ----
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, dm$rand, "_", dm$personNum),
      paste0(prefix.RDF,"type" ),
      paste0(prefix.CODE, dm$rand )
    ) 
    add.data.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, dm$rand, "_", dm$personNum),
      paste0(prefix.SKOS,"prefLabel" ),
      paste0("Randomization ",dm$personNum), type="string"
    )
    #!!HARDCODE activityStatus    
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, dm$rand, "_", dm$personNum),
      paste0(prefix.STUDY,"activityStatus" ),
      paste0(prefix.CODE, "ActivityStatus_1")
    )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, dm$rand, "_", dm$personNum),
      paste0(prefix.STUDY,"hasCode" ),
      paste0(prefix.CODE, dm$rand)
    )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, dm$rand, "_", dm$personNum),
      paste0(prefix.STUDY,"outcome" ),
      paste0(prefix.CD01P,dm$armcd_Frag)
    )
}) # end of ddply for DM domain   