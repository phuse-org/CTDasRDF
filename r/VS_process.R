###############################################################################
# FILE : VS_process.R
# DESC: Create VS domain triples
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: Logic decisions made on the vs field 
#    vstestOrder = sequence number created to facilitate triple creation/identification
# TODO: 
#   Move all value *creation* into VS_Frag and VS_Impute
#   Clear all #TODO and questions to AO   
#   Proof all columns in vs to find their actual usage in this code. REMOTE unused.
#   Cross check all Date_nn to ensure they capture each type of thing they 
#      particiapte in. Eg: ScreeningVisit, Body position within Screening visit??etc. etc.
# !!! SEE WIP COMMENT for current construction.
###############################################################################

# Data cleanup from artifact created in Impute? 
vs <- subset(vs, (!is.na(vs$vstestCat)))

# Create Visit triples that should be created ONLY ONCE: Eg: Triples that describe an 
# individual visit. Eg: VisitScreening1_1
u_Visit <- vs[,c("visit_Frag", "visitPerson_Frag","personNum", "persVis_Label", "visit", 
  "visitnum", "vsdtc_Frag", "vsstat_Frag", "vsreasnd", "testRes_Label")]

u_Visit <- u_Visit[!duplicated(u_Visit$visitPerson_Frag),] # remove duplicates

ddply(u_Visit, .(visitPerson_Frag), function(u_Visit)
{
  person <-  paste0("Person_", u_Visit$personNum)

  # Person_(n) ---> visit (visitPerson_Frag)
  # Add visit to Person. Eg: Person_1 participatesIn visitScreening1_1
  # VisitScreening
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, person),
    paste0(prefix.STUDY,"participatesIn" ),
    paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag)
  )
     #-- Visit sub triples. Eg: VisitScreening1_1
     # Removed 2017-07-07 to match AO file
     #add.triple(cdiscpilot01,
     #  paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
     #  paste0(prefix.RDF,"type" ),
     #  paste0(prefix.OWL,"NamedIndividual")
     #)
     add.triple(cdiscpilot01,
       paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
       paste0(prefix.RDF,"type" ),
       paste0(prefix.CUSTOM,u_Visit$visit_Frag)
     )
     add.data.triple(cdiscpilot01,
       paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
       paste0(prefix.RDFS,"label" ),
       paste0(u_Visit$persVis_Label)
     )
    #DEL add.data.triple(cdiscpilot01,
    #   paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
    #   paste0(prefix.RDFS,"label" ),
    #   paste0(gsub(" ", "", u_Visit$visit)), type="string"
    # )
     add.data.triple(cdiscpilot01,
       paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
       paste0(prefix.SKOS,"prefLabel" ),
       paste0(gsub(" ", "", u_Visit$visit)), type="string"
     )
     if (! is.na(u_Visit$vsstat_Frag)){
       add.triple(cdiscpilot01,
         paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
         paste0(prefix.STUDY,"activityStatus" ),
         paste0(prefix.CODE, u_Visit$vsstat_Frag)   
       )
     } 
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
      paste0(prefix.STUDY,"hasCode" ),
      paste0(prefix.CUSTOM,u_Visit$visit_Frag)
    )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
      paste0(prefix.STUDY,"hasDate" ),
      paste0(prefix.CDISCPILOT01,u_Visit$vsdtc_Frag)   
    )
    # This date is a Visit Date (Date_<n> is a study:VisitDate)
    assignDateType(u_Visit$vsdtc, u_Visit$vsdtc_Frag, "VisitDate")
})

# -- visit -- hasSubActivity --> x
# Loop through vs to add the subActivites to each visit.
ddply(vs, .(personNum, vsseq), function(vs)
{
  
  # Create vs body position triples only if vspos_Frag has a value
  if (!is.na(vs$vspos_Frag) && ! as.character(vs$vspos_Frag)=="") {
    # Body Positions
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, vs$visitPerson_Frag),
      paste0(prefix.STUDY,"hasSubActivity" ),
      paste0(prefix.CDISCPILOT01,vs$vspos_Frag)   
    )
    #---- AsssumeBodyPosition sub-triples....  
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, vs$vspos_Frag),
      paste0(prefix.RDF,"type" ),
      paste0(prefix.CODE, vs$vsposCode_Frag)   
    )
    add.data.triple(cdiscpilot01,
     paste0(prefix.CDISCPILOT01, vs$vspos_Frag),
     paste0(prefix.SKOS,"prefLabel" ),
     paste0(vs$vspos_Label)   
    )
  }
  
  if (! is.na(vs$vsstat_Frag)) {
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01, vs$vspos_Frag),
      paste0(prefix.STUDY,"activityStatus" ),
      paste0(prefix.CODE, vs$vsstat_Frag)   
    )
  }
  add.triple(cdiscpilot01,
   paste0(prefix.CDISCPILOT01, vs$vspos_Frag),
   paste0(prefix.STUDY,"hasCode" ),
   paste0(prefix.CODE, vs$vsposCode_Frag)   
  )
  add.triple(cdiscpilot01,
   paste0(prefix.CDISCPILOT01, vs$vspos_Frag),
   paste0(prefix.STUDY, "hasDate" ),
   paste0(prefix.CDISCPILOT01, vs$vsdtc_Frag)   
  )
  # Link to SDTM terminology "upright position" 
  add.triple(cdiscpilot01,
   paste0(prefix.CDISCPILOT01, vs$vspos_Frag),
   paste0(prefix.STUDY, "outcome" ),
   paste0(prefix.SDTMTERM, vs$vsposSDTM_Frag)   
  )
  add.triple(cdiscpilot01,
    paste0(prefix.CDISCPILOT01, vs$visitPerson_Frag),
    paste0(prefix.STUDY,"hasSubActivity" ),
    paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag)   
  )
# WIP HERE  
    # Test result subtriples : Eg: cdiscpilot01:C67153.C25206_1
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
      paste0(prefix.RDF,"type" ),
      paste0(prefix.CD01P, vs$vstestSDTMCodeType_Frag)
    )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
      paste0(prefix.RDF,"type" ),
      paste0(prefix.SDTMTERM, vs$vstestSDTMCode)
    )
    add.data.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
      paste0(prefix.SKOS,"prefLabel" ),
      paste0(vs$testRes_Label)
    )
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
      paste0(prefix.STUDY,"hasCode" ),
      paste0(prefix.SDTMTERM, vs$vstestSDTMCode)
    )
 
# APPEARS IN LATER CODE??       
#    if (! as.character(vs$vsdrvfl) == "") {
#      add.data.triple(cdiscpilot01,
#        paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
#        paste0(prefix.STUDY,"derivedFlag" ),
#        paste0(vs$vsdrvfl)
#      )
#    }  
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
      paste0(prefix.STUDY,"hasPlannedDate" ),
      paste0(prefix.CDISCPILOT01, vs$vsdtc_Frag)
    )
    # StartRule ----
    add.triple(cdiscpilot01,
      paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
      paste0(prefix.STUDY,"hasStartRule" ),
      paste0(prefix.CDISCPILOT01, vs$startRule_Frag)
    )
      # StartRule sub triples ----
      add.triple(cdiscpilot01,
          paste0(prefix.CDISCPILOT01, vs$startRule_Frag),
          paste0(prefix.RDF,"type" ),
          paste0(prefix.CODE, vs$startRuleType_Frag)
        )
        add.triple(cdiscpilot01,
          paste0(prefix.CDISCPILOT01, vs$startRule_Frag),
          paste0(prefix.STUDY,"hasCode" ),
          paste0(prefix.CODE, vs$startRuleType_Frag)
        )
      # Special case for start Rule NONE: No prerequisite. Has special label
      if ( vs$startRuleType_txt=="None"){
        #TODO: Move this label creation to VS_frag.R
        add.data.triple(cdiscpilot01,
          paste0(prefix.CDISCPILOT01, vs$startRule_Frag),
          paste0(prefix.SKOS,"prefLabel" ),
          paste0(paste0("Start rule none 1"))
        )
      }else{
        add.triple(cdiscpilot01,
          paste0(prefix.CDISCPILOT01, vs$startRule_Frag),
          paste0(prefix.CODE,"hasPrerequisite" ),
          paste0(prefix.CDISCPILOT01, vs$vspos_Frag)
        )
        add.data.triple(cdiscpilot01,
          paste0(prefix.CDISCPILOT01, vs$startRule_Frag),
          paste0(prefix.SKOS,"prefLabel" ),
          paste0(paste0(vs$startRule_Label))
        )
      }
      # End startRule substriples  
    add.triple(cdiscpilot01,
       paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
       paste0(prefix.STUDY,"outcome" ),
       paste0(prefix.CDISCPILOT01, vs$vsorres_Frag)
     )
     add.data.triple(cdiscpilot01,
       paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
       paste0(prefix.STUDY,"seq" ),
       paste0(vs$vsseq), type="int"
     )
    # derived flag. If non-missing, code the value as the object (Y, N...)
    if (! as.character(vs$vsdrvfl) == "") {
      add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
        paste0(prefix.STUDY,"derivedFlag" ),
        paste0(vs$vsdrvfl), type="string"
      )
    }
    if (! as.character(vs$vsgrpid) == "") {
      add.data.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
        paste0(prefix.STUDY,"groupID" ),
        paste0(vs$vsgrpid), type="string"
      )
    }
    if (! as.character(vs$posSDTMCode) == "") {
      add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
        paste0(prefix.STUDY,"bodyPosition" ),
        paste0(prefix.SDTMTERM, vs$posSDTMCode)
      )
    }
    if (! as.character(vs$vsstat_Frag) == "") {
      add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
        paste0(prefix.STUDY,"activityStatus" ),
        paste0(prefix.CODE, vs$vsstat_Frag)
      )
    }
    # Category & Subcategory hard coded in VS_Frag.R
    #MOVE add.triple(cdiscpilot01,
    #  paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
    #  paste0(prefix.STUDY,"hasCategory" ),
    #  paste0(prefix.CD01P, vs$vscat_Frag)
    #)
    #MOVE add.triple(cdiscpilot01,
    #  paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
    #  paste0(prefix.STUDY,"hasSubcategory" ),
    #  paste0(prefix.CD01P, vs$vsscat_Frag)
    #)

     
  #MOVE   add.triple(cdiscpilot01,
  #    paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
  #    paste0(prefix.STUDY,"anatomicLocation" ),
  #    paste0(prefix.SDTMTERM, vs$vslocSDTMCode)
  #  )
    
#TW out for troubleshooting 2017-07-25    
    #AOQUESTION: Possible data fabrication issue. email to AO 2017-05-26
#    if (! as.character(vs$vsblfl) == "") {
#      add.data.triple(cdiscpilot01,
#        paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
#        paste0(prefix.STUDY,"baselineFlag" ),
#        paste0(vs$vsblfl), type="string"
#      )
#    }
    
#TW out for current dev work 2017-07-28        
#      add.triple(cdiscpilot01,
#        paste0(prefix.CDISCPILOT01, vs$startRule_Frag),
#        paste0(prefix.RDF,"type" ),
#        paste0(prefix.CODE, "StartRule")
#      )
#      add.triple(cdiscpilot01,
#        paste0(prefix.CDISCPILOT01, vs$startRule_Frag),
#        paste0(prefix.CODE,"hasPrerequisite" ),
#        paste0(prefix.CDISCPILOT01, vs$vspos_Frag)
#      )
#    if (! is.na(vs$vslatSDTMCode)){
#       add.triple(cdiscpilot01,
#         paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
#         paste0(prefix.STUDY,"laterality" ),
#         paste0(prefix.SDTMTERM, vs$vslatSDTMCode)
#        )
#     }
     
 
       # Build out the result triples
#       add.triple(cdiscpilot01,
#         paste0(prefix.CDISCPILOT01, vs$vsorres_Frag),
#         paste0(prefix.RDF,"type" ),
#         paste0(prefix.STUDY, vs$vstestOutcomeType_Frag)
#       )
       add.data.triple(cdiscpilot01,
         paste0(prefix.CDISCPILOT01, vs$vsorres_Frag),
         paste0(prefix.SKOS,"prefLabel" ),
         paste0(vs$vsorres_Label)
       )
       add.triple(cdiscpilot01,
         paste0(prefix.CDISCPILOT01, vs$vsorres_Frag),
         paste0(prefix.CODE,"hasUnit" ),
         paste0(prefix.CODE, vs$vsstresu_Frag)
       )
       add.data.triple(cdiscpilot01,
         paste0(prefix.CDISCPILOT01, vs$vsorres_Frag),
         paste0(prefix.CODE,"hasValue" ),
         paste0(vs$vsorres)
       )
       add.triple(cdiscpilot01,
         paste0(prefix.CDISCPILOT01, vs$vsorres_Frag),
         paste0(prefix.RDF,"type" ),
         paste0(prefix.STUDY, vs$vstestCatOutcome)
       )
       

       
#     if (! is.na(vs$vsreasnd) && ! as.character(vs$vsreasnd)==""){
#       add.data.triple(cdiscpilot01,
#         paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
#         paste0(prefix.STUDY,"reasonNotDone" ),
#         paste0(vs$vsreasnd), type="string"
#       )
#     }
#    #MOVE add.data.triple(cdiscpilot01,
    #   paste0(prefix.CDISCPILOT01,vs$vstestSDTMCode_Frag),
    #   paste0(prefix.STUDY,"sponsordefinedID" ),
    #   paste0(vs$invid), type="string"
    # )
})
