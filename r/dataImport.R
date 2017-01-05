###############################################################################
# FILE : dataMassage.R
# DESCR: Massage the data as needed for the prototype. 
# SRC  : 
# KEYS : 
# NOTES: 
#        
# INPUT: 
#      : 
# OUT  : 
# REQ  : Called from buildRDF-Driver.R
# TODO : 
###############################################################################
# Add the id var "Peson_<n>" for each HumanStudySubject observation 
id<-1:(nrow(masterData))   # Generate a list of ID numbers
masterData$pers<-paste0("Person_",id)  # Defines the person identifier as Person_<n>

#-- CODED values 
# UPPERCASE and remove spaces values of fields that will be coded to codelists
# Phase:  "Phase 2" becomes "PHASE2"
masterData$studyCoded      <- toupper(gsub(" ", "", masterData$study))
masterData$ageuCoded       <- toupper(gsub(" ", "", masterData$ageu))
# for arm, use the coded form of both armcd and actarmcd to allow a short-hand linkage
#    to the codelist where both ARM/ARMCD adn ACTARM/ACTARMCD are located.
masterData$armCoded        <- toupper(gsub(" ", "", masterData$armcd))
masterData$actarmCoded     <- toupper(gsub(" ", "", masterData$actarmcd))
masterData$domainCoded     <- toupper(gsub(" ", "", masterData$domain))

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
#-- Country code translation
#   Match to the code in the ontology identified by AO
masterData$countryCode <- recode(masterData$country,
                                  "'USA' = '840';"
)

# Create date needed for testing purposes. Eg: Set a deathFlag value to allow testing of code.
source('R/dataCreate.R')

