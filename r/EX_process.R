#______________________________________________________________________________
# FILE: EX_process.R
# DESC: Create EX domain triples
#       
# 
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: 
#       
#       
# TODO: 
#  
#  Add subtriples for FixedDoseInterval_1 :: Await INPUT FROM AO
#  Link in to the rest of the graph (person/visit etc.)
#______________________________________________________________________________


# DrugAdministration_(n) ----
ddply(ex, .(rowID), function(ex)
{

 addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$DrugAdminID_Frag),
      predicate = paste0(RDF, "type"),
      object    = paste0(CDISCPILOT01, ex$visitPerson_Frag)))
  
  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$DrugAdminID_Frag),
      predicate = paste0(RDF, "type"),
      object    = paste0(CUSTOM, ex$visit_Frag)))

  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$DrugAdminID_Frag),
      predicate = paste0(RDF, "type"),
      object    = paste0(STUDY, ex$DrugAdminType_Frag)))

  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$DrugAdminID_Frag),
      predicate = paste0(SKOS, "prefLabel"),
      object    = paste0("Drug administration"),
         objectType = "literal", datatype_uri = paste0(XSD,"string")))

  # Note this fragment applied to the Drug Admin is also assigned to the
  #   product administration activity but with CODE: instead of STUDY:
  #   For this test study, this is re-use
  #   of the same value. For other studies, a sep. fragment needed.
  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$DrugAdminID_Frag),
      predicate = paste0(STUDY, "activityStatus"),
      object    = paste0(CODE, ex$productAdminActStat_Frag)))
  
  
  
  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$DrugAdminID_Frag),
      predicate = paste0(STUDY, "administeredProduct"),
      object    = paste0(CUSTOM, ex$product_Frag)))

  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$DrugAdminID_Frag),
      predicate = paste0(STUDY, "hasActivityInterval"),
      object    = paste0(CDISCPILOT01, ex$FixedDoseInterval_Frag)))
     
      ##TODO: ADD subtriples for FixedDoseInterval_(n)  ** AFTER CLARIFICATION from AO on how to create it
        addStatement(cdiscpilot01,
          new("Statement", world=world,
            subject   = paste0(CDISCPILOT01, ex$FixedDoseInterval_Frag),
            predicate = paste0(RDF, "type"),
            object    = paste0(STUDY, "FixedDoseInterval")))
      # Number for the label is extracted from the fragment value
        
        addStatement(cdiscpilot01,
          new("Statement", world=world,
            subject   = paste0(CDISCPILOT01, ex$FixedDoseInterval_Frag),
            predicate = paste0(SKOS, "prefLabel"),
            object    = paste0("Fixed dose interval ", gsub("\\S+_", "", ex$FixedDoseInterval_Frag)),
               objectType = "literal", datatype_uri = paste0(XSD,"string")))
  
        addStatement(cdiscpilot01,
          new("Statement", world=world,
            subject   = paste0(CDISCPILOT01, ex$FixedDoseInterval_Frag),
            predicate = paste0(TIME, "hasBeginning"),
            object    = paste0(CDISCPILOT01, ex$exstdtc_Frag)))

        addStatement(cdiscpilot01,
          new("Statement", world=world,
            subject   = paste0(CDISCPILOT01, ex$FixedDoseInterval_Frag),
            predicate = paste0(TIME, "hasEnd"),
            object    = paste0(CDISCPILOT01, ex$exendtc_Frag)))
  
   # End FixedDoseInterval_1 ------------   
  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$DrugAdminID_Frag),
      predicate = paste0(STUDY, "hasDosageFrequency"),
      object    = paste0(SDTMTERM, ex$exdosfrqSDTMCode)))
  
  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$DrugAdminID_Frag),
      predicate = paste0(STUDY, "hasRouteOfAdministration"),
      object    = paste0(SDTMTERM, ex$exrouteSDTMCode)))
  
  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$DrugAdminID_Frag),
      predicate = paste0(STUDY, "outcome"),
      object    = paste0(STUDY, paste0("DrugAdministration",ex$DrugAdminOutcome_ ))))
})




# Loop through ex to create the DrugAdministration triples for each
#  ProductAdministration_(n), where (n) = presonNum
#  Note: Additional child triples under productAdmin_Frag are created within
#    DM_process.
ddply(ex, .(personNum, visitnum), function(ex)
{
  #  DrugAdministration_(n)
  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$productAdmin_Frag),
      predicate = paste0(STUDY,"hasSubActivity"),
      object    = paste0(CDISCPILOT01,ex$DrugAdminID_Frag)))
  
    addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, ex$productAdmin_Frag),
      predicate = paste0(STUDY, "activityStatus"),
      object    = paste0(CODE, paste0(ex$productAdminActStat_Frag))))

  
})
