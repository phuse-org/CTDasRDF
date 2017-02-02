###############################################################################
# FILE: processSUPPDM.R
# DESC: Create DM domain triples from SUPPDM
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: TESTING MODE: Uses only first 6 patients (set for DM migrates across 
#           all domains)
#       Coded values cannot have spaces or special characters.
#       SDTM numeric codes, Country, Arm codes are set MANUALLY
# Transform to add column to datframe in ddply
# http://stackoverflow.com/questions/7573144/how-to-use-ddply-to-add-a-column-to-a-data-frame

# TODO: 
#  - Add is.na to most triple creation blocks. Note may need !="" for some.
#  - Collapse code segments in FUNT()s where possible
#  - Add a function that evaluates each DATE value and types it as either
#     xsd:date if valid yyyy-mm-dd value, or as xsd:string if(invalid/incomplete 
#     date OR is a datetime value)
#  - Consider new triples for incomplete dates (YYYY triple, MON  triple, etc.)
#     for later implmentations
###############################################################################

suppdm <- readXPT("suppdm")

# Add personID for merge with DM dataset
suppdm <- addPersonId(suppdm)

#-- End Data Creation ---------------------------------------------------------

#-- Data COding ---------------------------------------------------------------
#-- CODED values 
#TODO: DELETE THESE toupper() statements. No longer used?  2017-01-18 TW ?
# UPPERCASE and remove spaces values of fields that will be coded to codelists
# Phase:  "Phase 2" becomes "PHASE2"
#dm$studyCoded      <- toupper(gsub(" ", "", dm$study))
#dm$ageuCoded       <- toupper(gsub(" ", "", dm$ageu))
# For arm, use the coded form of both armcd and actarmcd to allow a short-hand linkage
#    to the codelist where both ARM/ARMCD adn ACTARM/ACTARMCD are located.
#dm$armCoded        <- toupper(gsub(" ", "", dm$armcd))
#dm$actarmCoded     <- toupper(gsub(" ", "", dm$actarmcd))

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
#dm$sexSDTMCode <- recode(dm$sex, 
#    "'M'  = 'C66731.C20197';
#     'F'  = 'C66731.C16576';
#     'U'  = 'C66731.C17998'; 
#     'UNDIFFERENTIATED' = 'C66731.C45908'" )


#-- End Data Coding -----------------------------------------------------------





###############################################################################
# Create triples from source domain
# Loop through each row, creating triples for each Person_<n>
# Loop through the dataframe and create the triples for each Person_<n>
# New approach using ddply! 

#------------------------------------------------------------------------------
#-- popflag first level triples (attached directly to Person_(n)
# Recode to the qnam as needed to form the object. Note: no need to recode
#     ITT, so it comes across unchanged into qnam_
qnamRecode <- function(x) {
    switch(as.character(x),
           'COMPLT8' = 'C8WK',
           'COMPLT16' = 'C16WK',
           'COMPLT24' = 'C24WK',
           'EFFICACY' = 'EFF',
           'SAFETY' = 'SAF',
           as.character(x)
    )
}

# Apply the function over the qnam values
suppdm$qnam_ <- sapply(suppdm$qnam, qnamRecode)

suppdm$qnam_C <- paste0(prefix.CDISCPILOT01, "popflag-P", suppdm$personNum,"_", suppdm$qnam_)

# Loop over the dataframe using ddply 
ddply(suppdm, .(personNum, qnam_), function(suppdm){
    
    add.triple(store,
               paste0(prefix.CDISCPILOT01, "Person_", suppdm$personNum ),
               paste0(prefix.STUDY,"participatesIn" ),
               paste0(prefix.CDISCPILOT01, "popflag-P", suppdm$personNum,"_", suppdm$qnam_)
    )
}
)


