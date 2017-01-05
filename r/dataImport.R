###############################################################################
# FILE : dataImpport.R
# DESCR: Import and code data 
# SRC  : 
# KEYS : 
# NOTES: Creates the numeric personNum : index variable for each person in the
#           DM domain, used for iterating through and across domains, building the
#           the triples for each person.
#        
# INPUT: 
#      : 
# OUT  : Calls dataCreate.R
# FNT  : readXPT - reads XPT files 
# REQ  : Called from buildRDF-Driver.R
# TODO : Move domain-specific code like DM and VS work to their respective scripts:
#         processDM.R , processVS.R (above the function calls.)
###############################################################################

#------------------------------------------------------------------------------
# FNT: readXPT
#      Read the requested domains into dataframes for processing.
# TODO: Consider placing in separate Import.R script called by this driver.
readXPT<-function(domains)
{
    resultList <- vector("list", length(domains)) # initialize vector to hold dataframes
    for (i in seq(1, length(domains))) {
        sourceFile <- paste0("data/source/", domains[i], ".XPT")
        # resultList[[i]]<-sasxport.get(sourceFile)
        # Each domain assembled into resultList by name "dm", "vs" etc.
        resultList[[domains[i]]]<-sasxport.get(sourceFile)
    }
    resultList # return the dataframes from the function
    #TODO Merge the multiple SDTM Domains into a single Master dataframe.
}

# Access individual dataframes based on name:  domainsDF["vs"], etc.
domainsDF<-readXPT(c("dm", "vs")) 

# Consider the utility of having the domain prefix (dm.usubjid, vs.usubjid) vs. stripping it as done here.
# No name overlap due to SDTM naming conventions that add vs to vsdtc, dm to dmdtc, etc.
# If keeping, make it a function to process the list of domains.
dm <- data.frame(domainsDF["dm"])
names(dm) <- gsub( "^dm.",  "", names(dm), perl = TRUE)
dm <- dm[, !(names(dm) %in% c("domain"))]  # drop unnecessary columns

# vs domain
vs <- data.frame(domainsDF["vs"])
names(vs) <- gsub( "^vs.",  "", names(vs), perl = TRUE)
#DEL vs <- vs[, !(names(vs) %in% c("studyid", "domain"))]  # drop unnecessary columns NOT NEEDED

# For testing, keep only the first 6 patients in DM
dm <- head(dm, 6)


# Create the Person ID (Person_(n)) in the DM dataset for merging data across domains 
# during construction of the triples
# Add the id var "Peson_<n>" for each HumanStudySubject observation 
id<-1:(nrow(dm))   # Generate a list of ID numbers
# dm$personNum<- dm[i,"pers"]
dm$personNum<- id
# dm$pers<-paste0("Person_",id)  # Defines the person identifier as Person_<n>

# Create an merge Index file for the other domains.
personIndex <- dm[,c("personNum", "usubjid")]

#-- Merge the personIndex into the other domains to allow later looping during triple creation. 
#-- vs domain subset down to the test population specified in the dm subsetting.
vs <- merge(x = personIndex, y = vs, by="usubjid", all.x = TRUE)

# -------------------------------------------------------------


#-- CODED values 
# UPPERCASE and remove spaces values of fields that will be coded to codelists
# Phase:  "Phase 2" becomes "PHASE2"
dm$studyCoded      <- toupper(gsub(" ", "", dm$study))
dm$ageuCoded       <- toupper(gsub(" ", "", dm$ageu))
# for arm, use the coded form of both armcd and actarmcd to allow a short-hand linkage
#    to the codelist where both ARM/ARMCD adn ACTARM/ACTARMCD are located.
dm$armCoded        <- toupper(gsub(" ", "", dm$armcd))
dm$actarmCoded     <- toupper(gsub(" ", "", dm$actarmcd))
#DEL dm$domainCoded     <- toupper(gsub(" ", "", dm$domain))

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
dm$sexSDTMCode <- recode(dm$sex, 
    "'M' = 'C66731.C20197';
     'F'  = 'C66731.C16576';
     'U'  = 'C66731.C17998';
    'UNDIFFERENTIATED' = 'C66731.C45908'"
)
#-- Ethnicity code translation
dm$ethnicSDTMCode <- recode(dm$ethnic,
     "'HISPANIC OR LATINO'    = 'C66790.C17459';
    'NOT HISPANIC OR LATINO' = 'C66790.C41222';
    'NOT REPORTED'           = 'C66790.C43234';
    'UNKNOWN'                = 'C66790.C17998'"
)
#-- Race code translation
dm$raceSDTMCode <- recode(dm$race,
                                  "'AMERICAN INDIAN OR ALASKA NATIVE' = 'C74457.C41259';
    'ASIAN'                             = 'C74457.C41260';
    'BLACK OR AFRICAN AMERICAN'         = 'C74457.C16352';
    'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER' = 'C74457.C41219';
    'WHITE'                             = 'C74457.C41261'"
)
#-- Country code translation
#   Match to the code in the ontology identified by AO
dm$countryCode <- recode(dm$country,
                                  "'USA' = '840';"
)


