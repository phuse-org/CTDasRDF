#########################################################################
# NAME  : triples.R 
# AUTH  : Tim W.
# DESCR : Create the RDF Triples from the spreadsheet data source. Some recoding
#             of original data occurs in buildRDF-Driver.R
# NOTES : 
# IN    : Input of raw data with minor massaging occurs in buildRDF-Driver.R
# OUT   : 
# REQ   : 
# TODO  : CLean up the code so dates are only written to the file when the value
#            is non-missing. Now writes N/A, which is good for debugging but 
#            little else.
###############################################################################

# Add the id var "Peson_<n>" for each HumanStudySubject observation 
id<-1:(nrow(masterData))   # Generate a list of ID numbers
masterData$pers<-paste0("Person_",id)  # Defines the person identifier as Person_<n>


#---- Data Massage
#-- Create values not in the source that are required for testing or for later 
#      versions of SDTM.
# Birthdate 
masterData$brthdate <- strptime(dmData$rfstdtc, "%m/%d/%Y") - (strtoi(dmData$age) * 365 * 24 * 60*60)

# Informed Consent  (column present with missing values in DM source).
masterData$rficdtc <- masterData$dmdtc

# Investigator name and ID not present in source data
masterData$invnam <- 'Jones'
masterData$invid  <- '123'


#-- CODED values 
# UPPERCASE and remove spaces values of fields that will be coded to codelists
# Phase:  "Phase 2" becomes "PHASE2"
masterData$studyCoded      <- toupper(gsub(" ", "", masterData$study))
masterData$ageuCoded       <- toupper(gsub(" ", "", masterData$ageu))
# for arm, use the coded form of both armcd and actarmcd to allow a short-hand linkage
#    to the codelist where both ARM/ARMCD adn ACTARM/ACTARMCD are located.
masterData$armCoded        <- toupper(gsub(" ", "", masterData$arm))
masterData$actarmCoded     <- toupper(gsub(" ", "", masterData$actarm))
masterData$domainCoded     <- toupper(gsub(" ", "", masterData$domain))
masterData$dthflCoded      <- toupper(gsub(" ", "", masterData$dthfl))


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
#-- Sex code translation
masterData$sexSDTMCode <- recode(masterData$sex, 
    "'M' = 'C66731.C20197';
    'F'  = 'C66731.C16576';
    'U'  = 'C66731.C17998';
    'UNDIFFERENTIATED' = 'C66731.C45908'"
)
#-- Ethnicity code translation
masterData$ethnicSDTMCode <- recode(masterData$ethnic,
    "'HISPANIC OR LATINO'    = 'C66790.C17459';
    'NOT HISPANIC OR LATINO' = 'C66790.C41222';
    'NOT REPORTED'           = 'C66790.C43234';
    'UNKNOWN'                = 'C66790.C17998'"
)
#-- Race code translation
masterData$raceSDTMCode <- recode(masterData$race,
    "'AMERICAN INDIAN OR ALASKA NATIVE' = 'C74457.C41259';
    'ASIAN'                             = 'C74457.C41260';
    'BLACK OR AFRICAN AMERICAN'         = 'C74457.C16352';
    'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER' = 'C74457.C41219';
    'WHITE'                             = 'C74457.C41261'"
)

# Date conversions. Convert to Date and DateTime as noted in the DEFINE doc
#     for this study.
masterData$rfstdtc_DT  <- as.Date(masterData$rfstdtc, "%m/%d/%Y")
masterData$rfendtc_DT  <- as.Date(masterData$rfendtc, "%m/%d/%Y")
masterData$rfxstdtc_DT <- as.Date(masterData$rfxstdtc, "%m/%d/%Y")
masterData$dmdtc_DT    <- as.Date(masterData$dmdtc, "%m/%d/%Y")
masterData$rfxendtc_DT <- as.POSIXct(masterData$rfxendtc, format="%m/%d/%Y")
masterData$rficdtc_DT  <- as.POSIXct(masterData$rficdtc,  format="%m/%d/%Y")
masterData$rfpendtc_DT <- as.POSIXct(masterData$rfpendtc, format="%m/%d/%Y")
masterData$dthdtc_DT   <- as.POSIXct(masterData$dthdtc,   format="%m/%d/%Y")


#------------------------------------------------------------------------------
# Create triples 
#     TODO: add is as "a" Study when creating the code list!
#----------------------- Data -------------------------------------------------

# Loop through the masterData dataframe and create the triples for each 
#     Person_<n>
for (i in 1:nrow(masterData))
{
    # persNum - Human Study Subject Number. Created in code above. Just in index for the RDF
    #     used as the SUBJECT in each of the following triples in this section
    persNum<- masterData[i,"pers"]
     
    #Define pers(n>) as HumanStudySubject
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "EnrolledSubject")
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"participatesInStudy" ),
        paste0(prefix.CDISCPILOT01, "study-", masterData[i,"studyCoded"])
    )
    
    add.data.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.STUDY,"hasSubjectID" ),
               paste0(masterData[i,"subjid"]), type="string"
    )
    
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"hasUniqueSubjectID" ),
        paste0( masterData[i,"usubjid"]), type="string"
    )
    # Birthdate
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.TIME,"hasBeginning" ),
        paste0(prefix.CDISCPILOT01, "Birthdate_", i)
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "Birthdate_", i),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY,"Birthdate" )
    )
    # Note use of strptime to convert from mm/dd/YYYY to dateTime.
    #   Hokey-assed kludge to add T00:00:00. Fix with a  format
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "Birthdate_", i),
        paste0(prefix.TIME,"inXSDDatetime" ),
        paste0( strptime(masterData[i,"brthdate"], "%Y-%m-%d"), "T00:00:00"), type="dateTime"
    )
    #WIP Deathdate
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.TIME,"hasEnd" ),
        paste0(prefix.CDISCPILOT01, "Deathdate_", i)
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, "Deathdate_", i),
               paste0(prefix.RDF,"type" ),
               paste0(prefix.STUDY,"Deathdate" )
    )
    # Note use of strptime to convert from mm/dd/YYYY to dateTime.
    #   Hokey-assed kludge to add T00:00:00. Fix with a format
    if (! is.na(masterData[i,"dthdtc"])) {
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "Deathdate_", i),
            paste0(prefix.TIME,"inXSDDatetime" ),
            paste0( strptime(masterData[i,"dthdtc"], "%Y-%m-%d"), "T00:00:00"), type="dateTime"
        )
    }
    else{
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "Deathdate_", i),
            paste0(prefix.TIME,"inXSDDatetime" ),
            paste0( "NA"), type="dateTime"
        )               
    }
    
    
    
    # These triples link to elsewhere in the same graph for each individual.
    # The link follows the form:  xxxxxx_<n>
    # TODO: Turn all of the following into a function call since the pattern 
    #       is the same for each.
    #--------------------------------------------------------------------------
    #---- 1. Age
    #-- New coding of Age using the Activity Approach
    # Create the Activiy Age_<n>
    #--Age :  hasAge  
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.STUDY,"hasAge" ),
               paste0(prefix.CDISCPILOT01, "Age_", i)
    )
    #--Age : Age_<n>
    add.triple(store,
               paste0(prefix.CDISCPILOT01, "Age_", i),
               paste0(prefix.RDF,"type" ),
               paste0(prefix.STUDY,"Age" )
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, "Age_", i),
               paste0(prefix.STUDY,"hasActivityOutcome" ),
               paste0(prefix.CDISCPILOT01, "AgeOutcome_",i)
    )
    add.data.triple(store,
                    paste0(prefix.CDISCPILOT01, "Age_", i),
                    paste0(prefix.RDFS,"comment" ),
                    paste0("Linkage from Age_",i, " to age AgeOutcome_", i), lang="en"
    )
    add.data.triple(store,
                    paste0(prefix.CDISCPILOT01, "Age_", i),
                    paste0(prefix.RDFS,"label" ),
                    paste0("Age ",i), type="string"
    )
    #--Age : AgeOutcome_<n>
    add.triple(store,
               paste0(prefix.CDISCPILOT01, "AgeOutcome_", i),
               paste0(prefix.RDF,"type" ),
               paste0(prefix.STUDY,"AgeOutcome")
    )        
    add.triple(store,
               paste0(prefix.CDISCPILOT01, "AgeOutcome_", i),
               paste0(prefix.STUDY,"hasUnit" ),
               paste0(prefix.TIME, "unitYear")
    )        
    #TW Type float or int for year?  OA has as Float from TopBraid.
    add.data.triple(store,
                    paste0(prefix.CDISCPILOT01, "AgeOutcome_", i),
                    paste0(prefix.STUDY,"hasValue" ),
                    paste0(masterData[i,"age"]), type="float"
    )
    add.data.triple(store,
                    paste0(prefix.CDISCPILOT01, "AgeOutcome_", i),
                    paste0(prefix.RDFS,"comment" ),
                    paste0("Specification of AgeOutCome_",i), lang="en"
    )
    add.data.triple(store,
                    paste0(prefix.CDISCPILOT01, "AgeOutcome_", i),
                    paste0(prefix.RDFS,"label" ),
                    paste0("Age outcome ",i), type="string"
    )
    #-- end of Age definition
    #-- Arm allocation
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.STUDY,"allocatedTo" ),
               paste0(prefix.CDISCPILOT01, "arm-",masterData[i,"armCoded"]) 
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, "arm-",masterData[i,"armCoded"]) ,
               paste0(prefix.RDF,"type" ),
               paste0(prefix.STUDY,"Arm" )
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, "arm-",masterData[i,"armCoded"]) ,
               paste0(prefix.STUDY,"hasArmCode" ),
               paste0(prefix.CODECUSTOM,"armcd-PBO" )
    )
    # Currently omit label because it will be added for each obs of that type
    #    as a repeat.
    #add.data.triple(store,
    #           paste0(prefix.CDISCPILOT01, "arm-",masterData[i,"armCoded"]) ,
    #           paste0(prefix.RDFS,"label" ),
    #           paste0("Placebo"), type="string"
    #)
    #-- end Arm allocation
    
    #--Participates in: 
    #    DemographicDataCollection
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", i)
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", i),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY,"DemographicDataCollection" )
    )    
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "DemographicDataCollection_", i),
        paste0(prefix.STUDY,"studyDay" ),
        paste0( masterData[i,"dmdy"])
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
    
    #WIP here.
    if (! is.na(masterData[i,"dmdtc"])) {
        add.data.triple(store,    
            paste0(prefix.CDISCPILOT01, "DemographicDataCollectionDate_", i),
            paste0(prefix.TIME,"inXSDDateTime" ),
            paste0( strptime(masterData[i,"dmdtc"], "%m/%d/%Y"), "T00:00:00"), type="dateTime"
        )
    }
    else{
        add.data.triple(store,    
            paste0(prefix.CDISCPILOT01, "DemographicDataCollectionDate_", i),
            paste0(prefix.TIME,"inXSDDateTime" ),
            paste0( "NA"), type="dateTime"
        )
    }
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "InformedConsent_", i)
    )
        #>> 190
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
            #>>>> 169 
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
    
        #>>
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
            #>>>>   145     
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
                paste0(prefix.TIME,"inXSDDateTime" ),
                paste0(strptime(masterData[i,"rficdtc"], "%m/%d/%Y"), "T00:00:00"), type="dateTime"
            )
        
    #WIP    
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.STUDY,"participatesIn" ),
               paste0(prefix.CDISCPILOT01, "ProductAdministration_", i)
    )
    

    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.STUDY,"hasBeginning" ),
               paste0(prefix.CDISCPILOT01, "ReferenceStartDate_", i)
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.STUDY,"hasEnd" ),
               paste0(prefix.CDISCPILOT01, "ReferenceEndDate_", i)
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.STUDY,"hasEnd" ),
               paste0(prefix.CDISCPILOT01, "StudyParticipationEnd_", i)
    )
    
    
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasEthnicity" ),
        paste0(prefix.CDISCSDTM, masterData[i,"ethnicSDTMCode"]) 
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.SDTM,"hasRACE" ),
               paste0(prefix.CDISCSDTM, masterData[i,"raceSDTMCode"]) 
    )
    # SEX
    # Sex is coded to the SDTM Terminology graph by translating the value 
    #  the DM domain to its corresponding URI code in that graph.
    #  F C66731.C16576
    #  M 
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.SDTM,"hasSEX" ),
               paste0(prefix.CDISCSDTM, masterData[i,"sexSDTMCode"]) 
    )
    
    
    
    
    # Note how both allocatedTO and treatedAccordingTo use the same codelist 
    #    for ARM. THere is not separate codelist for ARM vs. ACTARM.
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"treatedAccordingTo"),
        paste0(prefix.CDISCPILOT01, "arm-",masterData[i,"actarmCoded"]) 
    )
#    add.data.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasRFSTDTC" ),
#        paste0(masterData[i,"rfstdtc_DT"]), "date"
#    )
#    add.data.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasRFENDTC" ),
#        paste0(masterData[i,"rfendtc_DT"]), "date"
#    )
#    add.data.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasRFXSTDTC" ),
#        paste0(masterData[i,"rfxstdtc_DT"]), "date"
#    )
#    add.data.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasRFXENDTC" ),
#        paste0(masterData[i,"rfxendtc_DT"]), "dateTime"
#    )
#    add.data.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasRFICDTC" ),
#        paste0(masterData[i,"rficdtc_DT"]), "dateTime"
#    )
#    add.data.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasRFPENDTC" ),
#        paste0(masterData[i,"rfpendtc_DT"]), "dateTime"
#    )
#    add.data.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasDTHDTC" ),
#        paste0(masterData[i,"dthdtc_DT"]), "dateTime"
#    )
#    add.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasDTHFL" ),
#        paste0(prefix.CODE, "deathflag-",masterData[i,"dthfl"]) 
#    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"hasSite" ),
        paste0(prefix.CDISCPILOT01, "site-",masterData[i,"siteid"]) 
    )
#    add.data.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasDMDTC" ),
#        paste0(masterData[i,"dmdtc_DT"]), "date"
#    )
#    add.data.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasDMDY" ),
#        paste0(masterData[i,"dmdy"]), "int"
#    )
}    # End looping through the study master dataframe.    