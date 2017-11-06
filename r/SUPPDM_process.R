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


# Hard coded. Study sponsor triple creation
#TODO: Move to processing of TSPARMCD or other source domain later in the project.
addStatement(cdiscpilot01,      
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "Sponsor_1" ),
    predicate = paste0(RDF,"type" ),
    object    = paste0(STUDY, "Sponsor")))

addStatement(cdiscpilot01,
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "Sponsor_1" ),
    predicate = paste0(RDFS,"label" ),
    object    = "CLINICAL STUDY SPONSOR",
      objectType = "literal", datatype_uri = paste0(XSD,"string")))

# Create triple attached to Person_, tnen second level descriptor triples
ddply(suppdm, .(personNum, qnam_), function(suppdm){
  #-- First level triples attached to Person_(n)  
  addStatement(cdiscpilot01,
    new("Statement", world=world, 
      subject   = paste0(CDISCPILOT01, "Person_", suppdm$personNum ),
      predicate = paste0(STUDY,"participatesIn" ),
      object    = paste0(CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum)))

    # "Population Flag
    # Types are assigned depending on the qnam. 
    #   C8WK,C16WK,C21WK are custom:
    #   EFF,ITT,SAF are code:
    #   May to need add more conditions when default of CODE: not appropriate.
    # note use of lowercase for custom: class
    addStatement(cdiscpilot01,  
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum),
        predicate = paste0(RDF,"type" ),
        object    = paste0(CUSTOM, "PopFlag", suppdm$qnam_)))

    #HARDCODE activityStatus
    addStatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum),
        predicate = paste0(STUDY,"activityStatus" ),
        object    = paste0(CODE, "ActivityStatus_1")))
  
    addStatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum),
        predicate = paste0(STUDY,"hasCode" ),
        object    = paste0(CUSTOM, "PopFlag", suppdm$qnam_)))

    addStatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum),
        predicate = paste0(STUDY,"hasPerformer" ),
        object    = paste0(CD01P, suppdm$sponsor_Frag)))

    addStatement(cdiscpilot01,
      new("Statement", world=world, 
        subject   = paste0(CDISCPILOT01, "PopFlag", suppdm$qnam_,"_",suppdm$personNum),
        predicate = paste0(STUDY,"outcome" ),
        object    = paste0(suppdm$qval_Frag), 
          objectType = "literal", datatype_uri = paste0(XSD,"string")))
})