#______________________________________________________________________________
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
#   Proof all columns in vs to find their actual usage in this code.
#______________________________________________________________________________

# Data cleanup - from artifact created in Impute? 
vs <- subset(vs, (!is.na(vs$vstestCat)))

# Individual Visit Subtriples ----
#  eg: Triples for VisitScreening1_1, VisitBaseline_1, VisitWk2_1, VisitWk24_1
# Create Visit triples that should be created ONLY ONCE: Eg: Triples that describe an 
# individual visit. Eg: VisitScreening1_1
u_Visit <- vs[,c("visit_Frag", "visitPerson_Frag","personNum", "persVis_Label", "visit", 
  "visitnum", "vsdtc_Frag", "vsstat_Frag", "vsreasnd", "testRes_Label")]

u_Visit <- u_Visit[!duplicated(u_Visit$visitPerson_Frag),] # remove duplicates

ddply(u_Visit, .(visitPerson_Frag), function(u_Visit)
{
  person <-  paste0("Person_", u_Visit$personNum)

  # Person_(n) ---> visit (visitPerson_Frag)
  # Assign person to visit: Eg: Person_1 participatesIn visitScreening1_1
  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, person),
      predicate = paste0(STUDY,"participatesIn"),
      object    = paste0(CDISCPILOT01, u_Visit$visitPerson_Frag)))

    # Subtriples for each visit ----    
    # Y
    addStatement(cdiscpilot01,
      new("Statement", world=world,
         subject   = paste0(CDISCPILOT01, u_Visit$visitPerson_Frag),
         predicate = paste0(RDF,"type"),
         object    = paste0(CUSTOM,u_Visit$visit_Frag)))

  
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01, u_Visit$visitPerson_Frag),
        predicate = paste0(RDFS,"label"),
        object    = paste0(u_Visit$persVis_Label),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))

    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01, u_Visit$visitPerson_Frag),
        predicate = paste0(SKOS,"prefLabel"),
        object    = paste0(gsub(" ", "", u_Visit$visit)),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))

    if (! is.na(u_Visit$vsstat_Frag)){
      addStatement(cdiscpilot01,
        new("Statement", world=world,
           subject   = paste0(CDISCPILOT01, u_Visit$visitPerson_Frag),
           predicate = paste0(STUDY,"activityStatus"),
           object    = paste0(CODE, u_Visit$vsstat_Frag)))
    } 
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01, u_Visit$visitPerson_Frag),
        predicate = paste0(STUDY,"hasCode"),
        object    = paste0(CUSTOM,u_Visit$visit_Frag)))
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01, u_Visit$visitPerson_Frag),
        predicate = paste0(STUDY,"hasDate"),
        object    = paste0(CDISCPILOT01,u_Visit$vsdtc_Frag)))

    # This date is a Visit Date (Date_<n> is a study:VisitDate)
    assignDateType(u_Visit$vsdtc, u_Visit$vsdtc_Frag, "VisitDate")
})



# visit -- hasSubActivity --> x ----
# Loop through vs to add the subActivites to each visit.
ddply(vs, .(personNum, vsseq), function(vs)
{
  #TW Now using vsposCode_Frag instead o f vspos_Frag
  # Create vs body position triples only if vsposCode_Frag has a value
  # if (!is.na(vs$vspos_Frag) && ! as.character(vs$vspos_Frag)=="") {
  if (!is.na(vs$vsposCode_Frag)) {

    
    #  VisitScreening1_1 -x->
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01, vs$visitPerson_Frag),
        predicate = paste0(STUDY,"hasSubActivity"),
        object    = paste0(CDISCPILOT01,vs$vsposCode_Frag)))

    # Body Positions
    # AsssumeBodyPosition sub-triples ----
# Y
    addStatement(cdiscpilot01,
      new("Statement", world=world,
       subject   = paste0(CDISCPILOT01, vs$vsposCode_Frag),
       predicate = paste0(RDF,"type"),
       object    = paste0(CUSTOM, vs$vsposCode)))

# Y    
    addStatement(cdiscpilot01,
      new("Statement", world=world,
       subject   = paste0(CDISCPILOT01, vs$vsposCode_Frag),
       predicate = paste0(SKOS,"prefLabel"),
       object    = paste0(vs$vspos_Label),
         objectType = "literal", datatype_uri = paste0(XSD,"string")))
  }
  
  if (! is.na(vs$vsstat_Frag)) {
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01, vs$vsposCode_Frag),
        predicate = paste0(STUDY,"activityStatus"),
        object    = paste0(CODE, vs$vsstat_Frag)))
  }
  
  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, vs$vsposCode_Frag),
      predicate = paste0(STUDY,"hasCode"),
      object    = paste0(CUSTOM, vs$vsposCode)))

  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, vs$vsposCode_Frag),
      predicate = paste0(STUDY, "hasDate"),
      object    = paste0(CDISCPILOT01, vs$vsdtc_Frag)))

  # StartRule : AssumeBodyPositionStanding_1 ----     
  # AssumeBodyPositionStanding_1 has a start rule, as assigned to vsposCodeStartRule_Frag
  #   in VS_Frag.R. See email from AO 2017-11-02.  
  # TODO: Make more efficient with loop through only !duplicated vsposCode_Frag + vsposCodeStartRule_Frag
  if (! is.na(vs$vsposCodeStartRule_Frag)){
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01, vs$vsposCode_Frag),
        predicate = paste0(STUDY, "hasStartRule"),
        object    = paste0(CDISCPILOT01, vs$vsposCodeStartRule_Frag)))
  }
  
  
  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0(CDISCPILOT01, vs$vsposCode_Frag),
      predicate = paste0(STUDY, "outcome"),
      object    = paste0(SDTMTERM, vs$posSDTMCode)))
  # !!END WORK!! ----     

  
  
  # SDTM terminology: Position ----
  addStatement(cdiscpilot01,
    new("Statement", world=world,
     subject   = paste0(CDISCPILOT01, vs$vspos_Frag),
     predicate = paste0(STUDY, "outcome"),
     object    = paste0(SDTMTERM, vs$vsposSDTM_Frag)))
  
  addStatement(cdiscpilot01,
  new("Statement", world=world,
    subject   = paste0(CDISCPILOT01, vs$visitPerson_Frag),
    predicate = paste0(STUDY,"hasSubActivity"),
    object    = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag)))
  
    # Test result subtriples : Eg: cdiscpilot01:C67153.C25206_1
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
        predicate = paste0(RDF,"type"),
        object    = paste0(CD01P, vs$vstestSDTMCodeType_Frag)))
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
        predicate = paste0(RDF,"type"),
        object    = paste0(SDTMTERM, vs$vstestSDTMCode)))
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
        predicate = paste0(SKOS,"prefLabel"),
        object    = paste0(vs$testRes_Label),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
        predicate = paste0(STUDY,"hasCode"),
        object    = paste0(SDTMTERM, vs$vstestSDTMCode)))
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
        predicate = paste0(STUDY,"hasScheduledDate"),
        object    = paste0(CDISCPILOT01, vs$vsdtc_Frag)))
    # Category & Subcategory hard coded in VS_Frag.R
    if (! is.na(vs$vscat_Frag)){
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
          predicate = paste0(STUDY,"hasCategory"),
          object    = paste0(CD01P, vs$vscat_Frag)))
    }
    if (! is.na(vs$vsscat_Frag)){
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
          predicate = paste0(STUDY,"hasSubcategory"),
          object    = paste0(CD01P, vs$vsscat_Frag)))
    }
    if (! is.na(vs$vslatSDTMCode)){
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
          predicate = paste0(STUDY,"laterality"),
          object    = paste0(SDTMTERM, vs$vslatSDTMCode)))
    }
    # StartRule ----
      if (! is.na(vs$startRule_Frag)){
        addStatement(cdiscpilot01,
          new("Statement", world=world,
            subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
            predicate = paste0(STUDY,"hasStartRule"),
            object    = paste0(CDISCPILOT01, vs$startRule_Frag)))
      }
      # StartRule sub triples ----
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01, vs$startRule_Frag),
          predicate = paste0(RDF,"type"),
          object    = paste0(CODE, vs$startRuleType_Frag)))
        addStatement(cdiscpilot01,
          new("Statement", world=world,
            subject   = paste0(CDISCPILOT01, vs$startRule_Frag),
            predicate = paste0(STUDY,"hasCode"),
            object    = paste0(CODE, vs$startRuleType_Frag)))
        addStatement(cdiscpilot01,
          new("Statement", world=world,
            subject   = paste0(CDISCPILOT01, vs$startRule_Frag),
            predicate = paste0(CODE,"hasPrerequisite"),
            object    = paste0(CDISCPILOT01, vs$vspos_Frag)))
        addStatement(cdiscpilot01,
          new("Statement", world=world,
            subject   = paste0(CDISCPILOT01, vs$startRule_Frag),
            predicate = paste0(SKOS,"prefLabel"),
            object    = paste0(vs$startRule_Label),
              objectType = "literal", datatype_uri = paste0(XSD,"string")))
    # End startRule substriples  
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
        predicate = paste0(STUDY,"outcome"),
        object    = paste0(CDISCPILOT01, vs$vsorres_Frag)))
     addStatement(cdiscpilot01,
       new("Statement", world=world,
         subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
         predicate = paste0(STUDY,"seq"),
         object    = paste0(vs$vsseq),
           objectType = "literal", datatype_uri = paste0(XSD,"int")))

    # derived flag. If non-missing, code the value as the object (Y, N...)
    if (! is.na(vs$vsdrvfl)) {
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
          predicate = paste0(STUDY,"derivedFlag"),
          object    = paste0(vs$vsdrvfl),
            objectType = "literal", datatype_uri = paste0(XSD,"string")))
    }
     
    if (! is.na(vs$vsgrpid)) {
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
          predicate = paste0(STUDY,"groupID"),
          object    = paste0(vs$vsgrpid),
            objectType = "literal", datatype_uri = paste0(XSD,"string")))
    }
    # Missing vsblfl is "", not NA 
    if (! as.character(vs$vsblfl) =="") {
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
          predicate = paste0(STUDY,"baselineFlag"),
          object    = paste0(vs$vsblfl),
            objectType = "literal", datatype_uri = paste0(XSD,"string")))
      }

    if (! as.character(vs$posSDTMCode) == "") {
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
          predicate = paste0(STUDY,"bodyPosition"),
          object    = paste0(SDTMTERM, vs$posSDTMCode)))
    }
    if (! as.character(vs$vsstat_Frag) == "") {
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
          predicate = paste0(STUDY,"activityStatus"),
          object    = paste0(CODE, vs$vsstat_Frag)))
    }
    if (! as.character(vs$vslocSDTMCode) == "") {
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
          predicate = paste0(STUDY,"anatomicLocation"),
          object    = paste0(SDTMTERM, vs$vslocSDTMCode)))
    }
     
     addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01, vs$vsorres_Frag),
        predicate = paste0(SKOS,"prefLabel"),
        object    = paste0(vs$vsorres_Label),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01, vs$vsorres_Frag),
        predicate = paste0(CODE,"hasUnit"),
        object    = paste0(CODE, vs$vsstresu_Frag)))
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(CDISCPILOT01, vs$vsorres_Frag),
        predicate = paste0(CODE,"hasValue"),
        object    = paste0(vs$vsorres),
          objectType = "literal", datatype_uri = paste0(XSD,"string")))
    addStatement(cdiscpilot01,
      new("Statement", world=world,
       subject   = paste0(CDISCPILOT01, vs$vsorres_Frag),
       predicate = paste0(RDF,"type"),
       object    = paste0(STUDY, vs$vstestCatOutcome)))
    if (! is.na(vs$vsreasnd) && ! as.character(vs$vsreasnd)==""){
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
          predicate = paste0(STUDY,"reasonNotDone"),
          object    = paste0(vs$vsreasnd),
            objectType = "literal", datatype_uri = paste0(XSD,"string")))
    }
    if (! is.na(vs$vsspid)){       
      addStatement(cdiscpilot01,
        new("Statement", world=world,
          subject   = paste0(CDISCPILOT01,vs$vstestSDTMCode_Frag),
          predicate = paste0(STUDY,"sponsordefinedID"),
          object    = paste0(vs$vsspid),
            objectType = "literal", datatype_uri = paste0(XSD,"string")))
    }
})