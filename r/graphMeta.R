#______________________________________________________________________________
# FILE : graphMeta.R 
# DESC: Create the RDF Triples for graph metadata 
# REQ :
# SRC :
# IN  : 
# OUT : 
# NOTE: 
# TODO: 
#_____________________________________________________________________________

# Graph Metadata ----
addStatement(cdiscpilot01, 
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "sdtm-graph"),
    predicate = paste0(DCTERMS, "description"),
    object    = "Clinical Trials data as an RDF graph.",
    objectType = "literal", datatype_uri = paste0(XSD,"string")))

addStatement(cdiscpilot01, 
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "sdtm-graph"),
    predicate = paste0(RDFS, "label"),
    object    = paste("The CDISCPILOT01 namespace is populated from CDISCPILOT01-R.TTL,",
      "created by conversion of CDISCPILOT01 .XPT files using R. Triples will NOT be an",
      "exact match with CDISCPILOT01.TTL created from Protege/Topbraid instance data. ",
      "Only select observations from source XPT are present, including a subset of VS results."),
    objectType = "literal", datatype_uri = paste0(XSD,"string")))

addStatement(cdiscpilot01, 
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "sdtm-graph"),
    predicate = paste0(BIBO, "status"),
    object    = paste("Under Construction/incomplete: Blood pressure, Pulse, Weight. ",
      "Only 1 patient and a subset of obs. from that patient."),
    objectType = "literal", datatype_uri = paste0(XSD,"string")))

addStatement(cdiscpilot01, 
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "sdtm-graph"),
    predicate = paste0(DCTERMS, "title"),
    object    = "PhUSE Project: Clinical Trials Data as RDF",
    objectType = "literal", datatype_uri = paste0(XSD,"string")))

addStatement(cdiscpilot01, 
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "sdtm-graph"),
    predicate = paste0(DCTERMS, "contributor"),
    object    = "Tim Williams",
    objectType = "literal", datatype_uri = paste0(XSD,"string")))

addStatement(cdiscpilot01, 
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "sdtm-graph"),
    predicate = paste0(DCTERMS, "contributor"),
    object    = "Armando Oliva",
    objectType = "literal", datatype_uri = paste0(XSD,"string")))

addStatement(cdiscpilot01, 
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "sdtm-graph"),
    predicate = paste0(PAV, "createdOn"),
    object    = paste0(gsub("(\\d\\d)$", ":\\1",strftime(Sys.time(),"%Y-%m-%dT%H:%M:%S%z"))),
    objectType = "literal", datatype_uri = paste0(XSD,"dateTime")))

addStatement(cdiscpilot01, 
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "sdtm-graph"),
    predicate = paste0(PAV, "createdWith"),
    object    = paste0("R Version ", R.version$major, ".", R.version$minor,
      " Platform:", R.version$platform, " with scripts from project: Clinical Trials Data as RDF"),
    objectType = "literal", datatype_uri = paste0(XSD,"string")))

addStatement(cdiscpilot01, 
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "sdtm-graph"),
    predicate = paste0(PAV, "version"),
    object    = paste(version),
    objectType = "literal", datatype_uri = paste0(XSD,"string")))

addStatement(cdiscpilot01, 
  new("Statement", world=world, 
    subject   = paste0(CDISCPILOT01, "sdtm-graph"),
    predicate = paste0(DCAT, "distribution"),
    object    = paste(outFileMain),
    objectType = "literal", datatype_uri = paste0(XSD,"string")))
