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


# Later get Study Sponsor value from  from TSPARMCD domain?
suppdm$sponsor_ <- "STUDYSPONSOR"


#---- qval fragment Creation
#  In other code this is accomplished by createFrag(). 
#    Matches values in code.ttl
#    Later convert to use createFrag()
# Create a new column to be recoded
suppdm$qval_Frag <- suppdm$qval
# Now recode the value as a fragment.
suppdm$qval_Frag <- sapply(suppdm$qval_Frag,function(x) {
    switch(as.character(x),
       'N'  = 'popflagoutcome_1',
       'Y'  = 'popflagoutcome_2',
        as.character(x) ) } )



#-- End Data Coding -----------------------------------------------------------
# Study sponsor triple creation.
#TODO: Move to processing of TSPARMCD or other source domain later in the project.
add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, "sponsor_STUDYSPONSOR" ),
    paste0(prefix.RDF,"type" ),
    paste0(prefix.STUDY, "Sponsor")
)
add.data.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, "sponsor_STUDYSPONSOR" ),
    paste0(prefix.RDFS,"label" ),
    "CLINICAL STUDY SPONSOR", type="string" 
)



# Loop over the dataframe using ddply 
ddply(suppdm, .(personNum, qnam_), function(suppdm){
    #-- First level triples attached to Person_(n)    
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, "Person_", suppdm$personNum ),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum)
    )
        # Types are assigned depending on the qnam. 
        #   C8WK,C16WK,C21WK are custom:
        #   EFF,ITT,SAF are code:
        #   May to need add more conditions when default of CODE: not appropriate.
        if (grepl("WK", suppdm$qnam_)){
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.CUSTOM, "popflag_", suppdm$qnam_)
            )
        }
        else{
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.CODE, "popflag_", suppdm$qnam_)
            )
        }
        #DEL
        #add.triple(cdiscpilot01,
        #    paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
        #    paste0(prefix.STUDY,"hasActivityCode" ),
        #    paste0(prefix.CUSTOM, "popflagterm_", suppdm$qnam_)
        #)
        
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
            paste0(prefix.CODE,"hasOutcome" ),
            paste0(prefix.CODE, suppdm$qval_Frag)
        )
        #DEL
        #add.triple(cdiscpilot01,
        #    paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
        #    paste0(prefix.STUDY,"hasMethod" ),
        #    paste0(prefix.CODE, "method_", suppdm$qorig)
        #)
        
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
            paste0(prefix.STUDY,"hasPerformer" ),
            paste0(prefix.CDISCPILOT01, "sponsor_", suppdm$sponsor_)
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, "popflag_", suppdm$qnam_,"_",suppdm$personNum),
            paste0(prefix.RDFS,"label" ),
            paste0("popflag-P", suppdm$personNum, suppdm$qnam_), type="string" 
        )
    }
)