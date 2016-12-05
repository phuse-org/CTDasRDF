#########################################################################
# $HeadURL: file:///C:/SVNLocalRepos/PhUSE/Projects/SDTM2RDF/r/triples.R $
# $Rev: 86 $
# $Date: 2016-12-05 10:31:14 -0500 (Mon, 05 Dec 2016) $
# $Author: U041939 $
#-----------------------------------------------------------------------------
# DESCR : Create the RDF Triples from the spreadsheet data source. Some recoding
#             of original data occurs in buildRDF-Driver.R
# STATUS: 
# NOTES : 
# INPUT : Input of raw data with minor massaging occurs in buildRDF-Driver.R
# OUT   : 
# TODO  : CLean up the code so dates are only written to the file when the value
#            is non-missing. Now writes N/A, which is good for debugging but 
#            little else.
###############################################################################

# Add the id var "pers<n>" for each HumanStudySubject observation 
id<-1:(nrow(masterData))   # Generate a list of ID numbers
masterData$pers<-paste0("Person_",id)  # Defines the person identifier as Person_<n>

# Defines the person identifier in this study.  Link to ontology?
masterData$persID<-paste0("PersonID_",id)  

# CODED values 
# UPPERCASE and remove spaces values of fields that will be coded to codelists
# Phase:  "Phase 2" becomes "PHASE2"
masterData$studyCoded      <- toupper(gsub(" ", "", masterData$study))
masterData$sexCoded        <- toupper(gsub(" ", "", masterData$sex))
masterData$raceCoded       <- toupper(gsub(" ", "", masterData$race))
masterData$ethnicCoded     <- toupper(gsub(" ", "", masterData$ethnic))
masterData$ageuCoded       <- toupper(gsub(" ", "", masterData$ageu))
masterData$armcdCoded      <- toupper(gsub(" ", "", masterData$armcd))
masterData$actarmcdCoded   <- toupper(gsub(" ", "", masterData$actarmcd))
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
# TODO: Add the ENROLLID , non-coded value!
# code:study-DISCPILOT01 is defined in the codelistCSV.R script;
#        TODO: add is as "a" Study when creating the code list!
#----------------------- Data -------------------------------------------------


# Loop through the masterData dataframe and create the triples for each 
#     HumandStudySubject (pers<n>)

# Create data for a Person
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
               paste0(prefix.STUDY,"hasUniqueIdentifier" ),
               paste0(prefix.CDISCPILOT01, masterData[i,"persID"])
    )
    

    add.triple(store,
                    paste0(prefix.CDISCPILOT01, persNum),
                    paste0(prefix.SDTM,"participatesInStudy" ),
                    paste0(prefix.CODE, "study-", masterData[i,"studyCoded"])
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.SDTM,"hasUSUBJID" ),
               paste0(prefix.CDISCPILOT01, masterData[i,"usubjid"])
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.SDTM,"hasSUBJID" ),
               paste0(prefix.CDISCPILOT01, masterData[i,"subjid"])
    )
    add.data.triple(store,
                    paste0(prefix.CDISCPILOT01, persNum),
                    paste0(prefix.SDTM,"hasAGE" ),
                    paste0(masterData[i,"age"]), "int"
    )
    add.triple(store,
                    paste0(prefix.CDISCPILOT01, persNum),
                    paste0(prefix.SDTM,"hasAGEU" ),
                    paste0(prefix.CODE, "unit-", masterData[i,"ageuCoded"])
    )
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
               paste0(prefix.SDTM,"hasARMCD" ),
               paste0(prefix.CODE, "armcd-",masterData[i,"armcdCoded"]) 
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, persNum),
               paste0(prefix.SDTM,"hasACTARMCD" ),
               paste0(prefix.CODE, "actarmcd-",masterData[i,"actarmcdCoded"]) 
    )
    
    # NO. The Human Subject does not get a DOMAIN.
    #add.triple(store,
    #           paste0(prefix.CDISCPILOT01, persNum),
    #           paste0(prefix.SDTM,"hasSdtmDomain" ),
    #           paste0(prefix.CODE, "sdtmdomain-",masterData[i,"domainCoded"]) 
    #)
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
               paste0(prefix.SDTM,"hasSITEID" ),
               paste0(prefix.CODE, "site-",masterData[i,"siteid"]) 
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