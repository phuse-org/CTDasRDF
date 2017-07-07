###############################################################################
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
###############################################################################

# Add personID for merge with DM dataset
suppdm <- addPersonId(suppdm)

#-- End Data Creation ---------------------------------------------------------

#-- Data COding ---------------------------------------------------------------
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

# Class codes are camel case in custom: , in contrast to their corresponding
#   instance in cdiscpilot01:
#DEL qnamClassCode <- function(x) {
#DEL     switch(as.character(x),
#DEL         'COMPLT8'  = 'C8Wk',
#DEL         'COMPLT16' = 'C16Wk',
#DEL         'COMPLT24' = 'C24Wk',
#DEL         'EFFICACY' = 'Eff',
#DEL         'SAFETY'   = 'Saf',
#DEL         as.character(x)
#DEL     )
#DEL }
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
suppdm$qnam_  <- sapply(suppdm$qnam, qnamCode)            # Upper cased for cdiscpiloto1:
#DEL suppdm$qnamClass_  <- sapply(suppdm$qnam, qnamClassCode)  # Camel cased  for custom:

suppdm$qval_  <- sapply(suppdm$qval, qvalCode)
suppdm$qeval_ <- sapply(suppdm$qeval, qevalCode)


# Hardcoded: Later get Study Sponsor value from  from TSPARMCD domain?
suppdm$sponsor_Frag <- "Sponsor_1"


#---- qval fragment Creation
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
