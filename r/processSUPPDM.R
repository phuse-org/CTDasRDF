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
qvalRecode <- function(x) {
    switch(as.character(x),
           'Y' = 'YES',
           'N' = 'NO',
           as.character(x)
    )
}

qevalRecode <- function(x) {
    switch(as.character(x),
           'CLINICAL STUDY SPONSOR' = 'STUDYSPONSOR',
           as.character(x)
    )
}

# Apply the function over the qnam values
suppdm$qnam_ <- sapply(suppdm$qnam, qnamRecode)
suppdm$qval_ <- sapply(suppdm$qval, qvalRecode)
suppdm$qeval_ <- sapply(suppdm$qeval, qevalRecode)


suppdm$qnam_C <- paste0(prefix.CDISCPILOT01, "popflag-P", suppdm$personNum,"_", suppdm$qnam_)

# Loop over the dataframe using ddply 
ddply(suppdm, .(personNum, qnam_), function(suppdm){
    
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "Person_", suppdm$personNum ),
            paste0(prefix.STUDY,"participatesIn" ),
            paste0(prefix.CDISCPILOT01, "popflag-P", suppdm$personNum,"_", suppdm$qnam_)
        )
        #---- Second level triples for each popflag
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "popflag-P", suppdm$personNum,"_", suppdm$qnam_),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY, "PopulationFlag")
        )
        # Note use of qnam and not qnam_ in the following object 
        # is qnam avail?
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "popflag-P", suppdm$personNum,"_", suppdm$qnam_),
            paste0(prefix.STUDY,"hasActivityCode" ),
            paste0(prefix.CODE, "popflagterm-", suppdm$qnam_, "POP")
        )

        #TODO: TEST BELOW HERE 
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "popflag-P", suppdm$personNum,"_", suppdm$qnam_),
            paste0(prefix.STUDY,"hasActivityOutcome" ),
            paste0(prefix.CODE, "popflagoutcome-", suppdm$qval_)
        )
        add.triple(store,
                   paste0(prefix.CDISCPILOT01, "popflag-P", suppdm$personNum,"_", suppdm$qnam_),
                   paste0(prefix.STUDY,"hasMethod" ),
                   paste0(prefix.CODE, "activitymethod-", suppdm$qorig)
        )
        add.triple(store,
                   paste0(prefix.CDISCPILOT01, "popflag-P", suppdm$personNum,"_", suppdm$qnam_),
                   paste0(prefix.STUDY,"hasPerformer" ),
                   paste0(prefix.CDISCPILOT01, "sponsor-", suppdm$qeval_)
        )
        add.data.triple(store,
                   paste0(prefix.CDISCPILOT01, "popflag-P", suppdm$personNum,"_", suppdm$qnam_),
                   paste0(prefix.RDFS,"label" ),
                   paste0("popflag-P", suppdm$personNum,"_", suppdm$qnam_), type="string" 
        )
    }
)