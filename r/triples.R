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




#------------------------------------------------------------------------------
# Create triples 
#     TODO: add is as "a" Study when creating the code list!
#----------------------- Data -------------------------------------------------

#-- Part 1:  Metadata about the graph

add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.RDFS, "comment"),
    paste0("Example SDTM data converted from CDISC SDTM to RDF Graph as part of the SDTM Data to RDF project."), type="string"
)

add.data.triple(store,
paste0(prefix.CDISCPILOT01, "sdtm-graph"),
paste0(prefix.RDFS, "label"),
paste0("SDTM data as a graph."), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.DCTERMS, "description"),
    paste0("Data converted from the CDISCPILOT01 SDTM DM domain to RDF."), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.DCTERMS, "title"),
    paste0("SDTM data as RDF."), type="string"
)
# Later change these to link to FOAF description of the people as separate resources
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.DCTERMS, "contributor"),
    paste0("Tim Williams"), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.DCTERMS, "contributor"),
    paste0("Armando Oliva"), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.PAV, "createdOn"),
    paste0(gsub("(\\d\\d)$", ":\\1",strftime(Sys.time(),"%Y-%m-%dT%H:%M:%S%z"))), type="dateTime"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.PAV, "createdWith"),
    paste0("R Version ", R.version$major, ".", R.version$minor,
        " Platform:", R.version$platform, " swith scripts from SDTM Data to RDF Working group"), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.PAV, "version"),
    paste0(version), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.DCAT, "distribution"),
    paste0(outFilename)
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.PROV, "wasDerivedFrom"),
    paste0(inFilename)
)
#-- Part 2: For values created only once:
#TODO: MOVE THIS TO THE CODELIST R SCRIPT.
#  Value is hard coded here. Make it data driven.
add.triple(store,
    paste0(prefix.CDISCPILOT01, "study-CDISCPILOT01"),
    paste0(prefix.RDF,"type" ),
    paste0(prefix.STUDY,"Study")
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "study-CDISCPILOT01"),
    paste0(prefix.STUDY,"hasStudyID" ),
    paste0("CDISCPILOT01"), type="string" 
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "study-CDISCPILOT01"),
    paste0(prefix.RDFS,"label" ),
    paste0("Study-CDISCPILOT01"), type="string" 
)

#-- PART 3
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
        paste0(prefix.STUDY,"hasBirthdate" ),
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
        paste0(prefix.TIME,"inXSDDate" ),
        #DEL paste0( strptime(masterData[i,"brthdate"], "%Y-%m-%d")), type="date"
        paste0(masterData[i,"brthdate"]), type="date"
    )
    #Deathdate
    # Note the funky conversion testing for missing! is.an will NOT work here. There is something
    #     in the field even when "blank"
    if (! as.character(masterData[i,"dthdtc"])=="") {
        add.triple(store,
            paste0(prefix.CDISCPILOT01, persNum),
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
                paste0(prefix.TIME,"inXSDDate" ),
                #DEL paste0( strptime(masterData[i,"dthdtc"], "%Y-%m-%d"), "T00:00:00"), type="date"
                paste0( masterData[i,"dthdtc"]), type="date"
            )
    }
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.STUDY,"hasEthnicity" ),
               paste0(prefix.CDISCSDTM, masterData[i,"ethnicSDTMCode"]) 
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.STUDY,"hasRace" ),
               paste0(prefix.CDISCSDTM, masterData[i,"raceSDTMCode"]) 
    )
    # Sex
    # Sex is coded to the SDTM Terminology graph by translating the value 
    #  the DM domain to its corresponding URI code in that graph.
    #  F C66731.C16576
    #  M 
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.STUDY,"hasSex" ),
               paste0(prefix.CDISCSDTM, masterData[i,"sexSDTMCode"]) 
    )
    # Age
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.STUDY,"hasAgeMeasurement" ),
               paste0(prefix.CDISCPILOT01, "AgeMeasurement_", i)
    )
        #>>
        add.triple(store,
                   paste0(prefix.CDISCPILOT01, "AgeMeasurement_", i),
                   paste0(prefix.RDF,"type" ),
                   paste0(prefix.STUDY,"AgeMeasurement" )
        )
        add.triple(store,
                   paste0(prefix.CDISCPILOT01, "AgeMeasurement_", i),
                   paste0(prefix.STUDY,"hasActivityOutcome" ),
                   paste0(prefix.CDISCPILOT01, "Age_",i)
        )
        add.data.triple(store,
                        paste0(prefix.CDISCPILOT01, "Age_", i),
                        paste0(prefix.RDFS,"label" ),
                        paste0("Age ",i), type="string"
        )
            #>>>>
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
               paste0(masterData[i,"age"]), type="float"
            )
            add.data.triple(store,
               paste0(prefix.CDISCPILOT01, "Age_", i),
               paste0(prefix.RDFS,"label" ),
               paste0("Age ",i), type="string"
            )
    #-- end of Age definition
    #-- Arm allocation
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"allocatedToArm" ),
        paste0(prefix.CUSTOM, "armcd-",masterData[i,"armCoded"]) 
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "armcd-",masterData[i,"armCoded"]) ,
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY,"Arm" )
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "armcd-",masterData[i,"armCoded"]) ,
        paste0(prefix.STUDY,"hasArmCode" ),
        paste0(prefix.CUSTOM,"armcd-PBO" )
    )
    # Currently omit label because it will be added for each obs of that type
    #    as a repeat.
    #add.data.triple(store,
    #    paste0(prefix.CDISCPILOT01, "arm-",masterData[i,"armCoded"]) ,
    #    paste0(prefix.RDFS,"label" ),
    #    paste0("Placebo"), type="string"
    #)
    #-- end Arm allocation
    
    # Death flag
    #TODO: Code to blank when not present? 
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"deathFlag" ),
        paste0(masterData[i,"dthfl"]), type="string"
    )
    # DemographicDataCollection
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

    if (! is.na(masterData[i,"dmdtc"])) {
       add.data.triple(store,    
           paste0(prefix.CDISCPILOT01, "DemographicDataCollectionDate_", i),
           paste0(prefix.TIME,"inXSDDate" ),
           #DEL paste0( strptime(masterData[i,"dmdtc"], "%m/%d/%Y")), type="date"
           paste0(masterData[i,"dmdtc"]), type="date"
       )
    }
    #TW: Remove. do not code NA into dataTime. if different types of missing require identification, 
    #    code this using additional triples.
    #else{
    #    add.data.triple(store,    
    #        paste0(prefix.CDISCPILOT01, "DemographicDataCollectionDate_", i),
    #        paste0(prefix.TIME,"inXSDDateTime" ),
    #        paste0( "NA"), type="dateTime"
    #    )
    #}
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "InformedConsent_", i)
    )
        #>>
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
            #>>>>
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
            #>>>>
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
                paste0(prefix.TIME,"inXSDDate" ),
                #DEL paste0(strptime(masterData[i,"rficdtc"], "%m/%d/%Y")), type="date"
                paste0(masterData[i,"rficdtc"]), type="date"
            )
    # Product Administration         
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "ProductAdministration_", i)
    )
        #>>
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
            #>>>>
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
                paste0(prefix.TIME,"inXSDDate"),
                #DEL paste0(strptime(masterData[i,"rfstdtc"], "%Y-%m-%d")), type="date"
                paste0(masterData[i,"rfstdtc"]), type="date"
            )
        #>>    
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "ProductAdministration_", i),
            paste0(prefix.TIME,"hasEnd"),
            paste0(prefix.CDISCPILOT01, "ProductAdministrationEnd_", i)
        )
            #>>>>
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
                paste0(prefix.TIME,"inXSDDate"),
                #DELpaste0(strptime(masterData[i,"rfendtc"], "%m/%d/%Y")), type="date"
                paste0(masterData[i,"rfendtc"]), type="date"
            )
    # Randomization
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "Randomization_", i)
    )
        #>>        
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
            #>>>>
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "RandomizationOutcome_",i),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.STUDY,"RandomizationOutcome" )
            )
            # New addition pre email on 16DEC16
            add.triple(store,
                paste0(prefix.CDISCPILOT01, "RandomizationOutcome_",i),
                paste0(prefix.STUDY,"hasActivityOutcomeCode" ),
                paste0(prefix.CUSTOM,"armcd-",masterData[i,"armCoded"] )
            )
            
            add.data.triple(store,
                paste0(prefix.CDISCPILOT01, "RandomizationOutcome_",i),
                paste0(prefix.RDFS,"label" ),
                paste0("Randomization Outcome ",i), type="string"            
            )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"participatesInStudy" ),
        paste0(prefix.CDISCPILOT01, "study-", masterData[i,"studyCoded"])
    )
    # Note how both allocatedTO and treatedAccordingTo use the same codelist 
    #    for ARM. THere is not separate codelist for ARM vs. ACTARM.
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"treatedAccordingToArm"),
        paste0(prefix.CUSTOM, "armcd-",masterData[i,"actarmCoded"]) 
    )
    # Site
    # QUESTION: Is treatedAtSite appropriate for all types of studies?
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"hasSite" ),
        paste0(prefix.CDISCPILOT01, "site-",masterData[i,"siteid"]) 
    )
    # Person label
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.RDFS,"label" ),
        paste0("Person ", i) 
    )
    # Reference start date
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.TIME,"hasBeginning" ),
        paste0(prefix.CDISCPILOT01, "ReferenceStartDate_", i)
    )
        #>>    
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
            paste0(prefix.TIME,"inXSDDate"),
            #DEL paste0(strptime(masterData[i,"rfstdtc"], "%m/%d/%Y")), type="date"
            paste0(masterData[i,"rfstdtc"]), type="date"
        )
        # Reference end date
        add.triple(store,
            paste0(prefix.CDISCPILOT01, persNum),
            paste0(prefix.TIME,"hasEnd" ),
            paste0(prefix.CDISCPILOT01, "ReferenceEndDate_", i)
        )
        #>>    
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
        #TODO Add !is.na for this time.
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, "ReferenceEndDate_", i),
            paste0(prefix.TIME,"inXSDDate"),
            #DEL paste0(strptime(masterData[i,"rfendtc"], "%m/%d/%Y")), type="date"
            paste0(masterData[i,"rfendtc"]), type="date"
        )
        # Create triples for rfpendtc only if a value is present
        if (! is.na(masterData[i,"rfpendtc"])){
            add.triple(store,
                paste0(prefix.CDISCPILOT01, persNum),
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
            #TODO Add a function that evaluates each DATE field value, then types it as either
            #     xsd:date if valid yyyy-mm-dd value, or as xsd:string if(invalid/incomplete date OR
            #     is a datetime value)
            # If valid either valid month format, type as xsd:date
            # Be ashamed of this programming....
            if (! grepl(":",masterData[i,"rfpendtc"])
                & (
                ! is.na(as.Date(masterData[i,"rfpendtc"], format = "%Y-%m-%d")) # UNTESTED
                | 
                ! is.na(as.Date(masterData[i,"rfpendtc"], format = "%m-%d-%Y"))
                )){
                add.data.triple(store,
                    paste0(prefix.CDISCPILOT01, "StudyParticipationEnd_", i),
                    paste0(prefix.TIME,"inXSDDate"),
                    paste0(masterData[i,"rfpendtc"]), type="date"
                )
            }else{
            # all other values in the date field are coded as string, including dateTime
            #   values (which lack :ss, so are incomplete semantically)
                add.data.triple(store,
                    paste0(prefix.CDISCPILOT01, "StudyParticipationEnd_", i),
                    paste0(prefix.TIME,"inXSDString"),
                    paste0(masterData[i,"rfpendtc"]), type="string"
                )            
            } # end of else
        } # end of creating the rfpendtc triple
}    # End looping through the study master dataframe.    