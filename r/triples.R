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

# CODED values 
# UPPERCASE and remove spaces values of fields that will be coded to codelists
# Phase:  "Phase 2" becomes "PHASE2"
masterData$studyCoded      <- toupper(gsub(" ", "", masterData$study))
masterData$sexCoded        <- toupper(gsub(" ", "", masterData$sex))
masterData$raceCoded       <- toupper(gsub(" ", "", masterData$race))
masterData$ethnicCoded     <- toupper(gsub(" ", "", masterData$ethnic))
masterData$ageuCoded       <- toupper(gsub(" ", "", masterData$ageu))
# for arm, use the coded form of both armcd and actarmcd to allow a short-hand linkage
#    to the codelist where both ARM/ARMCD adn ACTARM/ACTARMCD are located.
masterData$armCoded        <- toupper(gsub(" ", "", masterData$armcd))
masterData$actarmCoded     <- toupper(gsub(" ", "", masterData$actarmcd))
masterData$domainCoded     <- toupper(gsub(" ", "", masterData$domain))
masterData$dthflCoded      <- toupper(gsub(" ", "", masterData$dthfl))


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
        paste0(prefix.STUDY, "Person")
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"participatesInStudy" ),
        paste0(prefix.CODECUSTOM, "study-", masterData[i,"studyCoded"])
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"hasUSUBJID" ),
        paste0(prefix.CDISCPILOT01, masterData[i,"usubjid"])
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"hasSUBJID" ),
        paste0(prefix.CDISCPILOT01, masterData[i,"subjid"])
    )
    
# original coding of AGE and AGEUNIT (coded) direct to the Person_<n>.    
#    add.data.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasAGE" ),
#        paste0(masterData[i,"age"]), "int"
#    )
#    add.triple(store,
#        paste0(prefix.CDISCPILOT01, persNum),
#        paste0(prefix.SDTM,"hasAGEU" ),
#        paste0(prefix.CODE, "unit-", masterData[i,"ageuCoded"])
#    )
    #---- New coding of Age using the Activity Approach
    # Create the Activiy Age_<n>
    # 1. Activity
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"hasActivity" ),
        paste0(prefix.CDISCPILOT01, "Age_", i)
    )
    # 2. ActivityCode
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "Age_", i),
        paste0(prefix.CODE,"hasActivityCode" ),
        paste0(prefix.CODE, "AgeCode")
    )
    # 3. ActivityOutcome
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "Age_", i),
        paste0(prefix.STUDY,"hasActivityOutcome" ),
        paste0(prefix.CDISCPILOT01, "AgeOutcome_",i)
    )
    # 4. Age Outcome Unit
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "AgeOutCome_", i),
        paste0(prefix.STUDY,"hasUnit" ),
        paste0(prefix.CODE, "time-year")
    )
    # 5. Age Outcome Value
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "AgeOutCome_", i),
        paste0(prefix.STUDY,"hasValue" ),
        paste0(masterData[i,"age"]), "int"
    )
    # End of AGE resource.
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasSEX" ),
        paste0(prefix.CODE, "sex-", masterData[i,"sexCoded"]) 
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasRACE" ),
        paste0(prefix.CODE, "race-", masterData[i,"raceCoded"]) 
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasETHNIC" ),
        paste0(prefix.CODE, "ethnic-",masterData[i,"ethnicCoded"]) 
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"allocatedTo" ),
        paste0(prefix.CDISCPILOT01, "arm-",masterData[i,"armCoded"]) 
    )
    # Note how both allocatedTO and treatedAccordingTo use the same codelist 
    #    for ARM. THere is not separate codelist for ARM vs. ACTARM.
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"treatedAccordingTo"),
        paste0(prefix.CDISCPILOT01, "arm-",masterData[i,"actarmCoded"]) 
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasRFSTDTC" ),
        paste0(masterData[i,"rfstdtc_DT"]), "date"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasRFENDTC" ),
        paste0(masterData[i,"rfendtc_DT"]), "date"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasRFXSTDTC" ),
        paste0(masterData[i,"rfxstdtc_DT"]), "date"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasRFXENDTC" ),
        paste0(masterData[i,"rfxendtc_DT"]), "dateTime"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasRFICDTC" ),
        paste0(masterData[i,"rficdtc_DT"]), "dateTime"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasRFPENDTC" ),
        paste0(masterData[i,"rfpendtc_DT"]), "dateTime"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasDTHDTC" ),
        paste0(masterData[i,"dthdtc_DT"]), "dateTime"
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasDTHFL" ),
        paste0(prefix.CODE, "deathflag-",masterData[i,"dthfl"]) 
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.STUDY,"hasSite" ),
        paste0(prefix.CDISCPILOT01, "site-",masterData[i,"siteid"]) 
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasDMDTC" ),
        paste0(masterData[i,"dmdtc_DT"]), "date"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, persNum),
        paste0(prefix.SDTM,"hasDMDY" ),
        paste0(masterData[i,"dmdy"]), "int"
    )
}    # End looping through the study master dataframe.    