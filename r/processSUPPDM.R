###############################################################################
# FILE: processSUPPDM.R
# DESC: Create triples from SUPPDM
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: TESTING MODE: Uses only first 6 patients (set for DM migrates across 
#           all domains)
#       Coded values cannot have spaces or special characters. See Data Coding
#       Method uses ddply instead of FOR loop. 
# TODO: 
###############################################################################

suppdm <- readXPT("suppdm")

# Add personID for merge with DM dataset
suppdm <- addPersonId(suppdm)

 # Other data needed for testing (??)

#-- End Data Creation ---------------------------------------------------------

#-- Data COding ---------------------------------------------------------------
#   Used in formation of URIs where the original data can/should not be used
qnamCode <- function(x) {
    switch(as.character(x),
        'COMPLT8'  = 'C8WK',
        'COMPLT16' = 'C16WK',
        'COMPLT24' = 'C24WK',
        'EFFICACY' = 'EFF',
        'SAFETY'   = 'SAF',
        as.character(x)
    )
}
qvalCode <- function(x) {
    switch(as.character(x),
        'Y' = 'YES',
        'N' = 'NO',
        as.character(x)
    )
}

qevalCode <- function(x) {
    switch(as.character(x),
        'CLINICAL STUDY SPONSOR' = 'STUDYSPONSOR',
        as.character(x)
    )
}
suppdm$qnam_  <- sapply(suppdm$qnam, qnamCode)
suppdm$qval_  <- sapply(suppdm$qval, qvalCode)
suppdm$qeval_ <- sapply(suppdm$qeval, qevalCode)

#-- End Data Coding -----------------------------------------------------------

#DEL? suppdm$qnam_C <- paste0(prefix.CDISCPILOT01, "popflag-P", suppdm$personNum,"_", suppdm$qnam_)

# Loop over the dataframe using ddply 
ddply(suppdm, .(personNum, qnam_), function(suppdm){
    #-- First level triples attached to Person_(n)    
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, "Person_", suppdm$personNum ),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum)
    )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.CUSTOM, "popflagterm_", suppdm$qnam_)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
            paste0(prefix.STUDY,"hasActivityCode" ),
            paste0(prefix.CUSTOM, "popflagterm_", suppdm$qnam_)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
            paste0(prefix.STUDY,"hasActivityOutcome" ),
            paste0(prefix.CODE, "popflagoutcome_", suppdm$qval_)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
            paste0(prefix.STUDY,"hasMethod" ),
            paste0(prefix.CODE, "method_", suppdm$qorig)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
            paste0(prefix.STUDY,"hasPerformer" ),
            paste0(prefix.CDISCPILOT01, "sponsor_", suppdm$qeval_)
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
            paste0(prefix.RDFS,"label" ),
            paste0("popflag_", suppdm$qnam_,"_",suppdm$personNum), type="string" 
        )
    }
)