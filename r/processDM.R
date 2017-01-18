###############################################################################
# FILE: processDM.R
# DESC: Create DM domain triples
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: TESTING MODE: Uses only first 6 patients (set for DM migrates across 
#           all domains)
#       Coded values cannot have spaces or special characters.
#       SDTM numeric codes, Country, Arm codes are set MANUALLY
# TODO: 
#  - Add is.na to most triple creation blocks. Note may need !="" for some.
#  - Collapse code segments in FUNT()s where possible
#  - Add a function that evaluates each DATE value and types it as either
#     xsd:date if valid yyyy-mm-dd value, or as xsd:string if(invalid/incomplete 
#     date OR is a datetime value)
#  - Consider new triples for incomplete dates (YYYY triple, MON  triple, etc.)
#     for later implmentations
###############################################################################

dm <- readXPT("dm")

# For testing, keep only the first (n) patients in DM
dm <- head(dm, maxPerson)  # maxPerson set in BuildRDF-Driver.R

# Create the Person ID (Person_(n)) in the DM dataset for looping through the data by Person  
#     across domains when creating triples
id<-1:(nrow(dm))   # Generate a list of ID numbers
dm$personNum<- id

# Create an merge Index file for the other domains.
personId <- dm[,c("personNum", "usubjid")]


#-- Data Creation for testing purposes. --------------------------------------- 
#---- Birthdate 
# NOTE: Date calculations based on SECONDS so you must convert the age in Years to seconds
dm$brthdate <- strptime(strptime(dm$rfstdtc, "%Y-%m-%d") - (strtoi(dm$age) * 365.25 * 24 * 60 * 60), "%Y-%m-%d")

#---- Informed Consent  (column present with missing values in DM source).
dm$rficdtc <- dm$dmdtc

#---- Investigator name and ID not present in source data
dm$invnam <- 'Jones'
dm$invid  <- '123'

#---- Set Death values for Person_1
dm$dthfl[dm$personNum == 1 ] <- "Y"
# Unfactorize the dthdtc column to allow entry of a bogus date
dm$dthdtc <- as.character(dm$dthdtc)
dm$dthdtc[dm$personNum == 1 ] <- "2013-12-26"

#-- End Data Creation ---------------------------------------------------------

#-- Data COding ---------------------------------------------------------------
#-- CODED values 
# UPPERCASE and remove spaces values of fields that will be coded to codelists
# Phase:  "Phase 2" becomes "PHASE2"
dm$studyCoded      <- toupper(gsub(" ", "", dm$study))
dm$ageuCoded       <- toupper(gsub(" ", "", dm$ageu))
# For arm, use the coded form of both armcd and actarmcd to allow a short-hand linkage
#    to the codelist where both ARM/ARMCD adn ACTARM/ACTARMCD are located.
dm$armCoded        <- toupper(gsub(" ", "", dm$armcd))
dm$actarmCoded     <- toupper(gsub(" ", "", dm$actarmcd))

#-- Value/Code Translation
# Translate values in the domain to their corresponding codelist code
# for linkage to the SDTM graph
# Example: Sex is coded to the SDTM Terminology graph by translating the value 
#  from the DM domain to its corresponding URI code in the SDTM terminology graph.
#  F C66731.C16576
#  M 
# TODO: This type of recoding to external graphs will be moved to a function
#        and driven by a config file and/or separate SPARQL query against the graph
#        that holds the codes, like SDTMTERM for the CDISC SDTM Terminology.
#---- Sex
dm$sexSDTMCode <- recode(dm$sex, 
    "'M'  = 'C66731.C20197';
     'F'  = 'C66731.C16576';
     'U'  = 'C66731.C17998'; 
     'UNDIFFERENTIATED' = 'C66731.C45908'" )

#---- Ethnicity
dm$ethnicSDTMCode <- recode(dm$ethnic, 
    "'HISPANIC OR LATINO'     = 'C66790.C17459';
     'NOT HISPANIC OR LATINO' = 'C66790.C41222';
     'NOT REPORTED'           = 'C66790.C43234';
     'UNKNOWN'                = 'C66790.C17998'")

#---- Race
dm$raceSDTMCode <- recode(dm$race,
    "'AMERICAN INDIAN OR ALASKA NATIVE'          = 'C74457.C41259';
     'ASIAN'                                     = 'C74457.C41260';
     'BLACK OR AFRICAN AMERICAN'                 = 'C74457.C16352';
     'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER' = 'C74457.C41219';
     'WHITE'                                     = 'C74457.C41261'")

#---- Country
# Match to the code in the ontology identified by AO
dm$countryCode <- recode(dm$country,"'USA' = '840'")

#-- End Data Coding -----------------------------------------------------------

#-- Single Resource Creation --------------------------------------------------
#---- Investigators
# Get unique investigator ID 
investigators <- dm[,c("invnam", "invid")]
# Remove duplicates
investigators <- investigators[!duplicated(investigators),]

# Loop through the unique investigators, building the triples for each one
for (j in 1:nrow(investigators))
{
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators[j,"invid"]),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "Investigator")
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators[j,"invid"]),
        paste0(prefix.STUDY,"hasInvestigatorID" ),
        paste0(investigators[j,"invid"]), type="string"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators[j,"invid"]),
        paste0(prefix.STUDY,"hasLastName" ),
        paste0(investigators[j,"invnam"]), type="string"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators[j,"invid"]),
        paste0(prefix.RDFS,"label" ),
        paste0("Investigator ", investigators[j,"invid"]), type="string"
    )
}

#---- Sites
# Get unique investigator ID 
sites <- dm[,c("siteid", "invid", "countryCode" )]
# Remove duplicates
sites <- sites[!duplicated(sites),]

# Loop through the unique investigators, building the triples for each one
for (s in 1:nrow(sites))
{
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "site-",sites[s,"siteid"]),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY,"Site" )
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "site-",sites[s,"siteid"]),
        paste0(prefix.STUDY,"hasCountry" ),
        paste0(prefix.COUNTRY,sites[s,"countryCode"] )
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "site-", sites[s,"siteid"]),
        paste0(prefix.STUDY,"hasInvestigator" ),
        paste0(prefix.CDISCPILOT01,"Investigator_", sites[s,"invid"])
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "site-",sites[s,"siteid"]),
        paste0(prefix.STUDY,"hasSiteID" ),
        paste0(sites[s,"siteid"]), type="string" 
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "site-",sites[s,"siteid"]),
        paste0(prefix.RDFS,"label" ),
        paste0("site-",sites[s,"siteid"]), type="string" 
    )
}    

#---- Treatment Arms
arms <- dm[,c("arm", "armcd")]
# Remove duplicates
arms <- arms[!duplicated(arms),]
arms$armUC   <- toupper(gsub(" ", "", arms$arm))
arms$armcdUC <- toupper(gsub(" ", "", arms$armcd))
for (a in 1:nrow(arms))
{
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "arm-", arms[a,"armUC"]),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "Arm")
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "arm-", arms[a,"armUC"]),
        paste0(prefix.STUDY,"hasArmCode" ),
        paste0(prefix.CUSTOM, "armcd-", arms[a,"armcdUC"])
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "arm-", arms[a,"armUC"]),
        paste0(prefix.RDFS,"label" ),
        paste0(arms[a,"arm"]), type="string"
    )
}

###############################################################################
# Create triples from source domain
# Loop through each row, creating triples for each Person_<n>
for (i in 1:nrow(dm))
{
    # Create var to shorten code during repeats in following lines
    person <-  paste0("Person_", dm[i,"personNum"])
   
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "EnrolledSubject")
    )
    #DELadd.triple(store,
    #    paste0(prefix.CDISCPILOT01, person),
    #    paste0(prefix.RDF,"type" ),
    #    paste0(prefix.RDFS, "Resource")
    #)
    #DELadd.triple(store,
    #DEL    paste0(prefix.CDISCPILOT01, person),
    #DEL    paste0(prefix.RDF,"type" ),
    #DEL    paste0(prefix.STUDY, "HumanStudySubject")
    #DEL)
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasSubjectID" ),
        paste0(dm[i,"subjid"]), type="string"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasUniqueSubjectID" ),
        paste0( dm[i,"usubjid"]), type="string"
    )
    #-- Birthdate
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasBirthdate" ),
        paste0(prefix.CDISCPILOT01, "Birthdate_", i)
    )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Birthdate_", i),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"Birthdate" )
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "Birthdate_", i),
            paste0(prefix.RDFS,"label" ),
            paste0("Birthdate ",i), type="string"
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "Birthdate_", i),
            paste0(prefix.STUDY,"dateTimeInXSDSTring" ),
            paste0(dm[i,"brthdate"]), type="string"
        )
    #-- Deathdate
    # Note the funky conversion testing for missing! is.na will NOT work here. 
    #    There is something in the field even when "blank"
    if (! as.character(dm[i,"dthdtc"])=="") {
        add.triple(store,
            paste0(prefix.CDISCPILOT01, person),
            paste0(prefix.STUDY,"hasDeathdate" ),
            paste0(prefix.CDISCPILOT01, "Deathdate_", i)
        )  
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "Deathdate_", i),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.STUDY,"Deathdate" )
            )
            
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "Deathdate_", i),
                paste0(prefix.STUDY,"dateTimeInXSDString" ),
                paste0( dm[i,"dthdtc"]), type="string"
            )
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "Deathdate_", i),
                paste0(prefix.RDFS,"label" ),
                paste0("Deathdate ",i), type="string"
            )
    }
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasEthnicity" ),
        paste0(prefix.CDISCSDTM, dm[i,"ethnicSDTMCode"]) 
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasRace" ),
        paste0(prefix.CDISCSDTM, dm[i,"raceSDTMCode"]) 
    )
    # Sex - coded to the SDTM Terminology graph in code above.
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasSex" ),
        paste0(prefix.CDISCSDTM, dm[i,"sexSDTMCode"]) 
    )
    # Age
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasAgeMeasurement" ),
        paste0(prefix.CDISCPILOT01, "AgeMeasurement_", i)
    )
        # Level 2
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "AgeMeasurement_", i),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"AgeMeasurement" )
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "AgeMeasurement_", i),
            paste0(prefix.STUDY,"hasActivityCode" ),
            paste0(prefix.CODE, "observationterm-AGE")
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "AgeMeasurement_", i),
            paste0(prefix.STUDY,"hasActivityOutcome" ),
            paste0(prefix.CDISCPILOT01, "Age_",i)
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "AgeMeasurement_", i),
            paste0(prefix.RDFS,"label" ),
            paste0("Age ",i)
        )
            # Level 3
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "Age_", i),
                paste0(prefix.RDFS,"label" ),
                paste0("Age ",i), type="string"
            ) 
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "Age_", i),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.STUDY,"Age")
            )        
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "Age_", i),
                paste0(prefix.STUDY,"hasUnit" ),
                paste0(prefix.TIME, "unitYear")
            )        
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "Age_", i),
                paste0(prefix.STUDY,"hasValue" ),
                paste0(dm[i,"age"]), type="float"
            )
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "Age_", i),
                paste0(prefix.RDFS,"label" ),
                paste0("Age ",i), type="string"
            )
   #-- Arm 
   add.triple(store,
       paste0(prefix.CDISCPILOT01, person),
       paste0(prefix.STUDY,"allocatedToArm" ),
       paste0(prefix.CUSTOM, "armcd-",dm[i,"armCoded"]) 
   )
      # These triples are coded in the customTerminology file.
      #   and not needed here.
      #DEL add.triple(store,
      #DEL     paste0(prefix.CDISCPILOT01, "armcd-",dm[i,"armCoded"]) ,
      #DEL     paste0(prefix.RDF,"type" ),
      #DEL     paste0(prefix.STUDY,"Arm" )
      #DEL )
      #DEL add.triple(store,
      #DEL     paste0(prefix.CDISCPILOT01, "armcd-",dm[i,"armCoded"]) ,
      #DEL     paste0(prefix.STUDY,"hasArmCode" ),
      #DEL     paste0(prefix.CUSTOM,"armcd-PBO" )
      #DEL )
   
    # Death flag
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"deathFlag" ),
        paste0(dm[i,"dthfl"]), type="string"
    )
    # DemographicDataCollection
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", i)
    )
        # Level 2
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", i),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"DemographicDataCollection" )
        )    
        add.data.triple(store,
           paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", i),
           paste0(prefix.STUDY,"studyDay" ),
           paste0( dm[i,"dmdy"])
        )
        add.data.triple(store,
           paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", i),
           paste0(prefix.RDFS,"label" ),
           paste0("Demographic data collection ",i), type="string"
        )
        add.triple(store,
           paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", i),
           paste0(prefix.TIME,"hasBeginning" ),
           paste0(prefix.CDISCPILOT01, "DemographicDataCollectionDate_", i)
        )
            # Level 3    
            # DemographicDataCollectionDate_
            add.triple(store,    
                paste0(prefix.CDISCPILOT01, "DemographicDataCollectionDate_", i),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.STUDY,"DemographicDataCollectionDate" )
            )    
            add.data.triple(store,    
                paste0(prefix.CDISCPILOT01, "DemographicDataCollectionDate_", i),
                paste0(prefix.RDFS,"label" ),
                paste0("Demographic data collection date ",i), type="string"
            )
            
            if (! is.na(dm[i,"dmdtc"])) {
                add.data.triple(store,    
                    paste0(prefix.CDISCPILOT01, "DemographicDataCollectionDate_", i),
                    paste0(prefix.TIME,"inXSDDate" ),
                    paste0(dm[i,"dmdtc"]), type="date"
                )
            }
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "InformedConsent_", i)
    )
        # Level 2
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "InformedConsent_", i),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"InformedConsent")
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "InformedConsent_", i),
            paste0(prefix.STUDY,"hasActivityOutcome" ),
            paste0(prefix.CDISCPILOT01,"InformedConsentOutcome_", i)
        )
            # Level 3
            add.triple(store,
                paste0(prefix.CDISCPILOT01,"InformedConsentOutcome_", i),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.STUDY,"InformedConsentOutcome" )
            )
            # match to code.ttl graph
            add.triple(store,
                paste0(prefix.CDISCPILOT01,"InformedConsentOutcome_", i),
                paste0(prefix.STUDY,"hasActivityOutcomeCode" ),
                paste0(prefix.CODE,"InformedConsent_granted" )
            )
            add.data.triple(store,    
                paste0(prefix.CDISCPILOT01,"InformedConsentOutcome_", i),
                paste0(prefix.RDFS,"label" ),
                paste0("Informed consent outcome ",i), type="string"
            )
        # Level 2
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "InformedConsent_", i),
            paste0(prefix.RDFS,"label" ),
            paste0("Informed consent ", i)
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "InformedConsent_", i),
            paste0(prefix.TIME,"hasBeginning" ),
            paste0(prefix.CDISCPILOT01,"InformedConsentBegin_", i)
        )
            # Level 3
            add.triple(store,
                paste0(prefix.CDISCPILOT01,"InformedConsentBegin_", i),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.STUDY,"InformedConsentBegin" )
            )
            add.triple(store,
                paste0(prefix.CDISCPILOT01,"InformedConsentBegin_", i),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.STUDY,"StudyParticipationBegin" )
            )
            add.data.triple(store,    
                paste0(prefix.CDISCPILOT01,"InformedConsentBegin_", i),
                paste0(prefix.RDFS,"label" ),
                paste0("Informed consent begin ",i), type="string"
            )
            add.data.triple(store,    
                paste0(prefix.CDISCPILOT01,"InformedConsentBegin_", i),
                paste0(prefix.STUDY,"dateTimeInXSDString" ),
                paste0(dm[i,"rficdtc"]), type="string"
            )
    # Product Administration         
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "ProductAdministration_", i)
    )
        # Level 2
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "ProductAdministration_", i),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"ProductAdministration" )
        ) 
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "ProductAdministration_", i),
            paste0(prefix.RDFS,"label" ),
            paste0("Product administration ",i), type="string"
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "ProductAdministration_", i),
            paste0(prefix.TIME,"hasBeginning"),
            paste0(prefix.CDISCPILOT01, "ProductAdministrationBegin_", i)
        )
            #  Level 3
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "ProductAdministrationBegin_", i),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.STUDY,"ProductAdministrationBegin")
            )
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "ProductAdministrationBegin_", i),
                paste0(prefix.RDFS,"label" ),
                paste0("Product administration begin ",i), type="string"
            )
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "ProductAdministrationBegin_", i),
                paste0(prefix.STUDY,"dateTimeInXSDString"),
                paste0(dm[i,"rfstdtc"]), type="string"
            )
        # Level 2    
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "ProductAdministration_", i),
            paste0(prefix.TIME,"hasEnd"),
            paste0(prefix.CDISCPILOT01, "ProductAdministrationEnd_", i)
        )
            # Level 3
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "ProductAdministrationEnd_", i),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.STUDY,"ProductAdministrationEnd")
            )
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "ProductAdministrationEnd_", i),
                paste0(prefix.RDFS,"label" ),
                paste0("Product administration end ",i), type="string"
            )
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "ProductAdministrationEnd_", i),
                paste0(prefix.STUDY,"dateTimeInXSDString"),
                paste0(dm[i,"rfendtc"]), type="string"
            )
    # Randomization
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "Randomization_", i)
    )
        # Level 2        
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Randomization_", i),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"Randomization" )
        ) 
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "Randomization_", i),
            paste0(prefix.RDFS,"label" ),
            paste0("Randomization ",i), type="string"
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Randomization_", i),
            paste0(prefix.STUDY,"hasActivityOutcome" ),
            paste0(prefix.CDISCPILOT01, "RandomizationOutcome_",i)
        )
            # Level 3
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "RandomizationOutcome_",i),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.STUDY,"RandomizationOutcome" )
            )
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "RandomizationOutcome_",i),
                paste0(prefix.STUDY,"hasActivityOutcomeCode" ),
                paste0(prefix.CUSTOM,"armcd-",dm[i,"armCoded"] )
            )
            
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "RandomizationOutcome_",i),
                paste0(prefix.RDFS,"label" ),
                paste0("Randomization outcome ",i), type="string"            
            )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "study-", dm[i,"studyCoded"])
    )
    # Both allocatedTo and treatedAccordingTo use the same ARM codelist.
    #    THere is not separate codelist for ARM vs. ACTARM.
    # Codes are in customterminology.ttl
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"treatedAccordingToArm"),
        paste0(prefix.CUSTOM, "armcd-",dm[i,"actarmCoded"]) 
    )
    # Site
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"hasSite" ),
        paste0(prefix.CDISCPILOT01, "site-",dm[i,"siteid"]) 
    )
    # Person label
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.RDFS,"label" ),
        paste0("Person ", i) 
    )
    # Reference start date
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.TIME,"hasBeginning" ),
        paste0(prefix.CDISCPILOT01, "ReferenceStartDate_", i)
    )
        # Level 2   
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "ReferenceStartDate_", i),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"ReferenceStartDate" )
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "ReferenceStartDate_", i),
            paste0(prefix.RDFS,"label" ),
            paste0("Reference start date ", i )
        )
        #TODO Add !is.na for this time.
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "ReferenceStartDate_", i),
            paste0(prefix.STUDY,"dateTimeInXSDString"),
            paste0(dm[i,"rfstdtc"]), type="string"
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "ReferenceStartDate_", i),
            paste0(prefix.RDFS,"label" ),
            paste0("Reference start date ",i), type="string"
        )

    # Reference end date
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.TIME,"hasEnd" ),
        paste0(prefix.CDISCPILOT01, "ReferenceEndDate_", i)
    )
        # Level 2   
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "ReferenceEndDate_", i),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"ReferenceEndDate" )
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "ReferenceEndDate_", i),
            paste0(prefix.RDFS,"label" ),
            paste0("Reference end date ", i )
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "ReferenceEndDate_", i),
            paste0(prefix.STUDY,"dateTimeInXSDString"),
            paste0(dm[i,"rfendtc"]), type="string"
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "ReferenceEndDate_", i),
            paste0(prefix.RDFS,"label" ),
            paste0("Reference end date ",i), type="string"
        )

    # Create triples for rfpendtc only if a value is present
    if (! is.na(dm[i,"rfpendtc"])){
        add.triple(store,
            paste0(prefix.CDISCPILOT01, person),
            paste0(prefix.TIME,"hasEnd" ),
            paste0(prefix.CDISCPILOT01, "StudyParticipationEnd_", i)
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "StudyParticipationEnd_", i),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY,"StudyParticipationEnd" )
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "StudyParticipationEnd_", i),
            paste0(prefix.RDFS,"label" ),
            paste0("Study participation end ", i )
        )
        # Embarrassing kludge follows...
        if (! grepl(":",dm[i,"rfpendtc"])
            & (
                ! is.na(as.Date(dm[i,"rfpendtc"], format = "%Y-%m-%d")) # UNTESTED
                | 
                ! is.na(as.Date(dm[i,"rfpendtc"], format = "%m-%d-%Y"))
            )){
            add.data.triple(store,
                            paste0(prefix.CDISCPILOT01, "StudyParticipationEnd_", i),
                            paste0(prefix.STUDY,"dateTimeInXSDString"),
                            paste0(dm[i,"rfpendtc"]), type="string"
            )
        }else{
            # all other values in the date field are coded as string, including dateTime
            #   values (which lack :ss, so are incomplete semantically)
            add.data.triple(store,
                            paste0(prefix.CDISCPILOT01, "StudyParticipationEnd_", i),
                            paste0(prefix.STUDY,"dateTimeInXSDString"),
                            paste0(dm[i,"rfpendtc"]), type="string"
            )            
        } # End of else
    } # End of creating the rfpendtc triple
}    # End looping through the dataframe.    