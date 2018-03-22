#______________________________________________________________________________
# FILE: SUPPDM_impute.R
# DESC: Impute data needed for development purposes.
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: 
#       
#       
# TODO: move code at end to DM_frag.R?? OR delete if not used.
#______________________________________________________________________________

#DEL Now subsetting in buildRDF-Driver.R
#OLDE suppdmSubset <-c(1:6)  # only first patient for dev testing
#OLDE suppdm <- suppdm[suppdmSubset, ]

# Add personID for merge with DM dataset
suppdm <- addPersonId(suppdm)

# Hardcoded: Later get Study Sponsor value from  from TSPARMCD domain?
suppdm$sponsor_Frag <- "Sponsor_1"

# Data Coding ----
#   Used in formation of URIs where the original data can/should not be used
qnamCode <- function(x) {
  switch(as.character(x),
    'COMPLT8'  = 'Cmpltr8Wk',
    'COMPLT16' = 'Cmpltr16Wk',
    'COMPLT24' = 'Cmpltr24Wk',
    'EFFICACY' = 'Eff',
    'SAFETY'   = 'Saf',
    'ITT'      = 'Itt',
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
suppdm$qnam_  <- sapply(suppdm$qnam,  qnamCode) # Upper cased for cdiscpilot01:
suppdm$qval_  <- sapply(suppdm$qval,  qvalCode)
suppdm$qeval_ <- sapply(suppdm$qeval, qevalCode)

# qval fragment ----
# Currently no SUPPDM_Frag.R
#  In other code this is accomplished by createFrag(). 
#    Matches values in code.ttl
#    Later convert to use createFrag()
# Create a new column to be recoded
#TODO: move this to DM_frag?????
suppdm$qval_Frag <- suppdm$qval
# Now recode the value as a fragment.
suppdm$qval_Frag <- sapply(suppdm$qval_Frag,function(x) {
    switch(as.character(x),
       'N'  = 'false',
       'Y'  = 'true',
        as.character(x) ) } )
