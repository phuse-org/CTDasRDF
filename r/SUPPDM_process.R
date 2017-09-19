#______________________________________________________________________________
# FILE: SUPPDM_process.R
# DESC: Create triples from SUPPDM
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: TESTING MODE: Uses only first 6 patients (set for DM migrates across 
#       all domains)
#     Coded values cannot have spaces or special characters. See Data Coding
#     Method uses ddply instead of FOR loop. 
#     Study Sponsor value is hard coded here and in SUPPDM_impute.R

#     HARDCODE:  Population Flag activity status  (activityStatus_1)
# TODO: 
#______________________________________________________________________________

suppdm <- readXPT("suppdm")

source("R/SUPPDM_impute.R")

# Hard coded. Study sponsor triple creation
#TODO: Move to processing of TSPARMCD or other source domain later in the project.
add.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "Sponsor_1" ),
  paste0(prefix.RDF,"type" ),
  paste0(prefix.STUDY, "Sponsor")
)
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "Sponsor_1" ),
  paste0(prefix.RDFS,"label" ),
  "CLINICAL STUDY SPONSOR", type="string" 
)

# Create triple attached to Person_, tnen second level descriptor triples
ddply(suppdm, .(personNum, qnam_), function(suppdm){
  #-- First level triples attached to Person_(n)  
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, "Person_", suppdm$personNum ),
    paste0(prefix.STUDY,"participatesIn" ),
    paste0(prefix.CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum)
  )
    # "Population Flag
    # Types are assigned depending on the qnam. 
    #   C8WK,C16WK,C21WK are custom:
    #   EFF,ITT,SAF are code:
    #   May to need add more conditions when default of CODE: not appropriate.
    # note use of lowercase for custom: class
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum),
      paste0(prefix.RDF,"type" ),
      paste0(prefix.CUSTOM, "PopFlag", suppdm$qnam_)
    )
    
    #HARDCODE activityStatus
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum),
      paste0(prefix.STUDY,"activityStatus" ),
      paste0(prefix.CODE, "ActivityStatus_1")
    )
  
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum),
      paste0(prefix.STUDY,"hasCode" ),
      # paste0(prefix.CD01P, "PopulationFlag", suppdm$qnamClass_)
      paste0(prefix.CUSTOM, "PopFlag", suppdm$qnam_)
    )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum),
      paste0(prefix.STUDY,"hasPerformer" ),
      paste0(prefix.CD01P, suppdm$sponsor_Frag)
    )
    add.data.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum),
      paste0(prefix.STUDY,"outcome" ),
      paste0(suppdm$qval_Frag)
    )
  }
)