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
  addstatement(cdiscpilot01,   
    new("Statement", world=world, 
      subject   = paste0(CD01P, u_Person$study),
      predicate = paste0(STUDY,"hasStudyParticipant" ),
      object    = paste0(CDISCPILOT01, "Person_", u_Person$personNum)))
})
rm(u_Person) # Clean up

# Sites ----
sites <- dm[,c("siteid_Frag", "investigator_Frag")]
u_sites <- sites[!duplicated(sites$siteid_Frag),]  # Unique site IDs

ddply(u_sites, .(siteid_Frag), function(u_sites)
{
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
    subject   = paste0(CD01P, u_sites$siteid_Frag),
    predicate = paste0(STUDY,"hasInvestigator" ),
    object    = paste0(CDISCPILOT01, u_sites$investigator_Frag)))
})

# Investigators ----
investigators <- dm[,c("invnam", "invid", "inv", "invid_Frag")]
u_Invest <- investigators[!duplicated(investigators),]  # Unique investigator ID 
ddply(u_Invest, .(invnam), function(u_Invest)
{
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, u_Invest$inv),
    predicate = paste0(RDF,"type" ),
    object    = paste0(STUDY, "Investigator")))
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, u_Invest$inv),
    predicate = paste0(SKOS, 'prefLabel'),
    object    = paste0("Investigator ", u_Invest$invid), 
      objectType = "literal", datatype_uri = paste0(XSD,"string")))
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, u_Invest$inv),
    predicate = paste0(STUDY,"hasInvestigatorID" ),
    object    = paste0(CDISCPILOT01, u_Invest$invid_Frag)))

    # Investigator identifier is further broken down
    addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, u_Invest$invid_Frag),
      predicate = paste0(RDF,"type" ),
      object    = paste0(STUDY, "InvestigatorIdentifier")))

    addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, u_Invest$invid_Frag),
      predicate = paste0(SKOS,"prefLabel" ),
      object    = paste0(u_Invest$invid),
        objectType = "literal", datatype_uri = paste0(XSD,"string")))

  addstatement(cdiscpilot01,
    new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, u_Invest$inv),
    predicate = paste0(STUDY, 'hasLastName'),
    object    = paste0(u_Invest$invnam), 
      objectType = "literal", datatype_uri = paste0(XSD,"string")))
})
rm(u_Invest) # Clean up

# Sites ----
sites <- dm[,c("siteid", "siteid_Frag", "inv", "country", "country_Frag" )]
u_Site <- sites[!duplicated(sites), ]
ddply(u_Site, .(siteid), function(u_Site)
{
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, u_Site$siteid_Frag),
    predicate = paste0(RDF,"type" ),
    object    = paste0(STUDY,"Site" )))

  addstatement(cdiscpilot01,
    new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, u_Site$siteid_Frag),
    predicate = paste0(STUDY, "hasCountry" ),
    object    = paste0(CODE, u_Site$country_Frag )))

  addstatement(cdiscpilot01,
    new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, u_Site$siteid_Frag),
    predicate = paste0(STUDY, "hasInvestigator" ),
    object    = paste0(CDISCPILOT01, u_Site$inv)))

  addstatement(cdiscpilot01,
    new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, u_Site$siteid_Frag),
    predicate = paste0(STUDY,"hasSiteID" ),
    object    = paste0(u_Site$siteid), 
      objectType = "literal", datatype_uri = paste0(XSD,"string")))

  addstatement(cdiscpilot01,
    new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, u_Site$siteid_Frag),
    predicate = paste0(SKOS,"prefLabel" ),
    object    = paste0("site-",u_Site$siteid), 
      objectType = "literal", datatype_uri = paste0(XSD,"string")))
})
rm(u_Site) # Clean up

# Process each row of domain ----
#   Triples created from each row, for each Person_<n>
ddply(dm, .(subjid), function(dm)
{
  # Person_(n) ----
  person <- paste0("Person_", dm$personNum)

  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(RDF,"type" ),
      object    = paste0(STUDY, "EnrolledSubject")))
  # SubjectID
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"hasSubjectID" ),
      object    = paste0(CDISCPILOT01, dm$subjid_Frag)))
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, dm$subjid_Frag),
        predicate = paste0(RDF,"type" ),
        object    = paste0(STUDY, "SubjectIdentifier")))
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, dm$subjid_Frag),
        predicate = paste0(SKOS,"prefLabel" ),
        object    = paste0(dm$subjid),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))

  #Unique Subject ID  
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"hasUniqueSubjectID" ),
      object    = paste0(CDISCPILOT01, dm$usubjid_Frag)))

    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, dm$usubjid_Frag),
        predicate = paste0(RDF,"type" ),
        object    = paste0(STUDY, "UniqueSubjectIdentifier")))
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, dm$usubjid_Frag),
        predicate = paste0(SKOS,"prefLabel" ),
        object    = paste0(dm$usubjid)))

  # Treatment arm 
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"actualArm"),
      object    = paste0(CD01P, dm$actarmcd_Frag)))

  # Death flag
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"deathFlag" ),
      object    = paste0(dm$dthfl),
        objectType = "literal", datatype_uri = paste0(XSD,"string")))

  # Site
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"hasSite" ),
      object    = paste0(CD01P, dm$siteid_Frag)))

  # Person label
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(SKOS,"prefLabel" ),
      object    = paste0("Person ", dm$personNum),
        objectType = "literal", datatype_uri = paste0(XSD,"string")))

  # Reference Interval
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"hasReferenceInterval" ),
      object    = paste0(CDISCPILOT01, "ReferenceInterval_", dm$personNum)))

    # **** Reference Interval ----
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "ReferenceInterval_", dm$personNum),
        predicate = paste0(RDF,"type" ),
        object    = paste0(STUDY,"ReferenceInterval")))

    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "ReferenceInterval_", dm$personNum),
        predicate = paste0(RDFS,"label"),
        object    = paste0("Reference Interval ", dm$personNum),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))
    
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "ReferenceInterval_", dm$personNum),
        predicate = paste0(TIME,"hasBeginning" ),
        object    = paste0(CDISCPILOT01, dm$rfstdtc_Frag)))

    # Type to Date triples
    assignDateType(dm$rfstdtc, dm$rfstdtc_Frag, "ReferenceBegin")

    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "ReferenceInterval_", dm$personNum),
        predicate = paste0(TIME,"hasEnd" ),
        object    = paste0(CDISCPILOT01, dm$rfendtc_Frag)))

    # Type to Date triples
    assignDateType(dm$rfendtc, dm$rfendtc_Frag, "ReferenceEnd")

  # Lifespan Interval
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"hasLifespan" ),
      object    = paste0(CDISCPILOT01, "Lifespan_", dm$personNum)))

    # **** Lifespan Interval ----
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "Lifespan_", dm$personNum),
        predicate = paste0(RDF,"type" ),
        object    = paste0(STUDY,"Lifespan")))
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "Lifespan_", dm$personNum),
        predicate = paste0(RDFS,"label"),
        object    = paste0("Lifespan Interval ", dm$personNum),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))
    addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, "Lifespan_", dm$personNum),
      predicate = paste0(TIME,"hasBeginning" ),
      object    = paste0(CDISCPILOT01, dm$brthdate_Frag)))

    #---- Assign Date Type
    assignDateType(dm$brthdate, dm$brthdate_Frag, "Birthdate")

    if (!is.na(dm$dthdtc_Frag) && ! as.character(dm$dthdtc_Frag)=="") {
      addstatement(cdiscpilot01,
        new("Statement", world=world, 
          subject   = paste0(CDISCPILOT01, "Lifespan_", dm$personNum),
          predicate = paste0(TIME,"hasEnd" ),
          object    = paste0(CDISCPILOT01, dm$dthdtc_Frag)))
      #---- Assign Date Type
      assignDateType(dm$dthdtc, dm$dthdtc_Frag, "Deathdate")
    }
    
  # Study Participation Interval
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"hasStudyParticipationInterval" ),
      object    = paste0(CDISCPILOT01, "StudyParticipationInterval_", dm$personNum)))

    # **** Study Participation Interval ----
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "StudyParticipationInterval_", dm$personNum),
        predicate = paste0(RDF,"type" ),
        object    = paste0(STUDY,"StudyParticipationInterval" )))

    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "StudyParticipationInterval_", dm$personNum),
        predicate = paste0(RDFS,"label"),
        object    = paste0("Study Participation Interval ", dm$personNum),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))

    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "StudyParticipationInterval_", dm$personNum),
        predicate = paste0(TIME,"hasBeginning" ),
        object    = paste0(CDISCPILOT01, dm$dmdtc_Frag)))

    #---- Assign Date Type
    if (!is.na(dm$rfpendtc_Frag) && ! as.character(dm$rfpendtc_Frag)=="") {
      addstatement(cdiscpilot01,
        new("Statement", world=world, 
          subject   = paste0(CDISCPILOT01, "StudyParticipationInterval_", dm$personNum),
          predicate = paste0(TIME,"hasEnd" ),
          object    = paste0(CDISCPILOT01, dm$rfpendtc_Frag)))

      #---- Assign Date Type
      assignDateType(dm$rfpendtc, dm$rfpendtc_Frag, "StudyParticipationEnd")
    }

  # InformedConsentAdult  
  # Create all triples and subgraphs associated with informed conssent if the 
  #  date of informed consent is non-missing
  if (!is.na(dm$rficdtc_Frag) && ! as.character(dm$rficdtc_Frag)=="") {  
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, person),
        predicate = paste0(STUDY,"participatesIn" ),
        object    = paste0(CDISCPILOT01, "InformedConsentAdult_", dm$personNum)))

      # **** Informed Consent Adult ----
      addstatement(cdiscpilot01,
        new("Statement", world=world, 
          subject   = paste0(CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
          predicate = paste0(RDF,"type" ),
          object    = paste0(CODE,"InformedConsentAdult")))

    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
        predicate = paste0(SKOS,"prefLabel"),
        object    = paste0("Informed consent ", dm$personNum), 
          objectType = "literal", datatype_uri = paste0(XSD,"string")))

    #HARDCODE to completed. Add logic later.
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
        predicate = paste0(STUDY,"activityStatus"),
        object    = paste0(CODE, "ActivityStatus_1")))

    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
        predicate = paste0(STUDY,"outcome" ),
        object    = paste0(CODE, dm$informedConsentOut_Frag)))

    # Key triple to link to Interval for Informed consent
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
        predicate = paste0(STUDY,"hasActivityInterval" ),
        object    = paste0(CDISCPILOT01,"InformedConsentInterval_", dm$personNum)))

      #InformedConsentInterval_<n>
      addstatement(cdiscpilot01,
        new("Statement", world=world, 
          subject   = paste0(CDISCPILOT01,"InformedConsentInterval_", dm$personNum),
          predicate = paste0(RDF,"type" ),
          object    = paste0(STUDY,"InformedConsentInterval")))

      addstatement(cdiscpilot01,
        new("Statement", world=world, 
          subject   = paste0(CDISCPILOT01,"InformedConsentInterval_", dm$personNum),
          predicate = paste0(RDFS,"label"),
          object    = paste0("Informed Consent Interval ", dm$personNum), 
            objectType = "literal", datatype_uri = paste0(XSD,"string")))

      addstatement(cdiscpilot01,
        new("Statement", world=world, 
          subject   = paste0(CDISCPILOT01,"InformedConsentInterval_", dm$personNum),
          predicate = paste0(TIME,"hasBeginning" ),
          object    = paste0(CDISCPILOT01, dm$rficdtc_Frag )))

      # Create triples for specific date type assignments. 
      # StudyParticipationBegin set as date of informed consent as per 
      # mail from AO 2071-02-16
      assignDateType(dm$rficdtc, dm$rficdtc_Frag, "InformedConsentBegin")
      assignDateType(dm$rficdtc, dm$rficdtc_Frag, "StudyParticipationBegin")
      #Note: There is no informedConsentEnd in the source data
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
        predicate = paste0(STUDY,"hasCode" ),
        object    = paste0(CODE,"InformedConsentAdult")))

    #HARDCODE 
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "InformedConsentAdult_", dm$personNum),
        predicate = paste0(STUDY,"hasStartRule" ),
        object    = paste0(STUDY,"StartRuleDefault_1")))
 } # end informed consent adult
    
  # Product Administration
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"participatesIn" ),
      object    = paste0(CDISCPILOT01, "ProductAdministration_", dm$personNum)))
    
    # **** Product Administration ---- 
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "ProductAdministration_", dm$personNum),
        predicate = paste0(RDF,"type" ),
        object    = paste0(STUDY, "ProductAdministration")))
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "ProductAdministration_", dm$personNum),
        predicate = paste0(SKOS,"prefLabel" ),
        object    = paste0("Product administration ", dm$personNum),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "ProductAdministration_", dm$personNum),
        predicate = paste0(STUDY,"hasCode" ),
        object    = paste0(STUDY, "ProductAdministration")))

    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "ProductAdministration_", dm$personNum),
        predicate = paste0(STUDY,"hasActivityInterval" ),
        object    = paste0(CDISCPILOT01, "ProductAdministrationInterval_", dm$personNum)))

      # ****** Product Adminstration Interval ----
      addstatement(cdiscpilot01,
        new("Statement", world=world, 
          subject   = paste0(CDISCPILOT01, "ProductAdministrationInterval_", dm$personNum),
          predicate = paste0(RDF,"type" ),
          object    = paste0(STUDY, "ProductAdministrationInterval")))

      addstatement(cdiscpilot01,
        new("Statement", world=world, 
          subject   = paste0(CDISCPILOT01, "ProductAdministrationInterval_", dm$personNum),
          predicate = paste0(RDFS,"label" ),
          object    = paste0("Product Administration Interval ", dm$personNum), 
            objectType = "literal", datatype_uri = paste0(XSD,"string")))

      # Product Administration Begin
      addstatement(cdiscpilot01,
        new("Statement", world=world, 
          subject   = paste0(CDISCPILOT01, "ProductAdministrationInterval_", dm$personNum),
          predicate = paste0(TIME,"hasBeginning" ),
          object    = paste0(CDISCPILOT01, dm$rfxstdtc_Frag)))

      #---- Assign Date Type
      assignDateType(dm$rfxstdtc, dm$rfxstdtc_Frag, "ProductAdministrationBegin")

      # Product Administration End
      addstatement(cdiscpilot01,
        new("Statement", world=world, 
          subject   = paste0(CDISCPILOT01, "ProductAdministrationInterval_", dm$personNum),
          predicate = paste0(TIME,"hasEnd" ),
          object    = paste0(CDISCPILOT01, dm$rfxendtc_Frag)))
      #---- Assign Date Type
      assignDateType(dm$rfxendtc, dm$rfxendtc_Frag, "ProductAdministrationEnd")

  # Demographic Data Collection ----
  #  Age, Ethnicity, Race, Sex, etc. are all part of the Demographic Data collection
  #  triples for a specific person. Person_<n> -->  DemographicDataCollection_<n>     
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"participatesIn" ),
      object    = paste0(CDISCPILOT01, "DemographicDataCollection_", dm$personNum)))

    # ** Age ----
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
        predicate = paste0(CODE,"hasAge" ),
        object    = paste0(CDISCPILOT01, dm$age_Frag)))

       # Age unit from ageu
       if (grepl("YEARS",dm$ageu)){
         addstatement(cdiscpilot01,
           new("Statement", world=world, 
             subject   = paste0(CDISCPILOT01, dm$age_Frag),
             predicate = paste0(CODE, "hasUnit" ),
             object    = paste0(TIME, dm$ageu_Frag)))
       }
       addstatement(cdiscpilot01,
         new("Statement", world=world, 
           subject   = paste0(CDISCPILOT01, dm$age_Frag),
           predicate = paste0(CODE, "hasValue" ),
           object    = paste0(dm$age), 
             objectType = "literal", datatype_uri = paste0(XSD,"string")))
       addstatement(cdiscpilot01,
         new("Statement", world=world, 
           subject   = paste0(CDISCPILOT01, dm$age_Frag),
           predicate = paste0(RDF,"type" ),
           object    = paste0(STUDY, "AgeOutcome")))

       addstatement(cdiscpilot01,
         new("Statement", world=world, 
           subject   = paste0(CDISCPILOT01, dm$age_Frag),
           predicate = paste0(SKOS,"prefLabel" ),
           object    = paste0(dm$age, " ", dm$ageu), 
             objectType = "literal", datatype_uri = paste0(XSD,"string")))
       addstatement(cdiscpilot01,
         new("Statement", world=world, 
           subject   = paste0(CDISCPILOT01, dm$age_Frag),
           predicate = paste0(RDF,"type" ),
           object    = paste0(STUDY,"AgeOutcome")))

    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
        predicate = paste0(RDF,"type" ),
        object    = paste0(CODE,"DemographicDataCollection" )))

    #TODO Screening 1 currently hard coded because demog info collected at screening 1
    #  Either fix data or change label?
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
        predicate = paste0(SKOS,"prefLabel" ),
        object    = paste0("P",dm$personNum, " Screening 1 Demographic data collection"), 
          objectType = "literal", datatype_uri = paste0(XSD,"string")))
    
    #activityStatus
    #!!HARDCODE = CO hard coded for completed! 
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
        predicate = paste0(STUDY,"activityStatus" ),
        object    = paste0(CODE, "ActivityStatus_1")))
    
    # Ethnicity
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
        predicate = paste0(STUDY,"ethnicity" ),
        object    = paste0(SDTMTERM, dm$ethnic_Frag)))

    # Code
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
        predicate = paste0(STUDY,"hasCode" ),
        object    = paste0(CODE, "DemographicDataCollection")))

    # Demog Data Collection Date
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
        predicate = paste0(STUDY,"hasDate" ),
        object    = paste0(CDISCPILOT01,dm$dmdtc_Frag)))
      #---- Assign Date Type
      assignDateType(dm$rfxendtc, dm$dmdtc_Frag, "DemogDataCollectionDate")
    # Race
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
        predicate = paste0(STUDY,"race" ),
        object    = paste0(SDTMTERM, dm$race_Frag)))

    # Sex 
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "DemographicDataCollection_", dm$personNum),
        predicate = paste0(STUDY,"sex" ),
        object    = paste0(SDTMTERM, dm$sex_Frag)))

  # RandomizationBAL
  addstatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"participatesIn" ),
      object    = paste0(CDISCPILOT01, dm$rand, "_", dm$personNum)))
  
    # ** Randomization ----
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, dm$rand, "_", dm$personNum),
        predicate = paste0(RDF,"type" ),
        object    = paste0(CODE, dm$rand )))

    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, dm$rand, "_", dm$personNum),
        predicate = paste0(SKOS,"prefLabel" ),
        object    = paste0("Randomization ",dm$personNum), 
          objectType = "literal", datatype_uri = paste0(XSD,"string")))

    #!!HARDCODE activityStatus    
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, dm$rand, "_", dm$personNum),
        predicate = paste0(STUDY,"activityStatus" ),
        object    = paste0(CODE, "ActivityStatus_1")))
    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, dm$rand, "_", dm$personNum),
        predicate = paste0(STUDY,"hasCode" ),
        object    = paste0(CODE, dm$rand)))

    addstatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, dm$rand, "_", dm$personNum),
        predicate = paste0(STUDY,"outcome" ),
        object    = paste0(CD01P,dm$armcd_Frag)))
}) # end of ddply for DM domain   