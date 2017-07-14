#########################################################################
# NAME  : graphMeta.R 
# AUTH  : Tim W.
# DESCR : Create the RDF Triples for graph metadata 
#       
# NOTES : 
# IN    : Input of raw data with minor massaging occurs in buildRDF-Driver.R
# OUT   : 
# REQ   : 
# TODO  : Clean up the code so dates are only written to the file when the value
#      is non-missing. Now writes N/A, which is only really good for 
#      debugging little else.
###############################################################################

#------------------------------------------------------------------------------
# Create triples 
#   TODO: add is as "a" Study when creating the code list!
#----------------------- Data -------------------------------------------------

#-- Part 1:  Graph Metadata
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "sdtm-graph"),
  paste0(prefix.RDFS, "comment"),
  paste0("Example SDTM data converted from CDISC SDTM to RDF Graph as part of the SDTM Data to RDF project."), type="string"
)
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "sdtm-graph"),
  paste0(prefix.RDFS, "label"),
  paste0("SDTM data as a graph."), type="string"
)
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "sdtm-graph"),
  paste0(prefix.DCTERMS, "description"),
  paste0("CDISCPILOT01 namespace is populated from CDISCPILOT01-R.TTL, which is created by converting source .XPT files using R. 
  Triples will NOT be an exact match with CDISCPILOT01.TTL created from Protege/Topbraid instance data. Only select observations from 
  source XPT are present, including a subset of VS results. The focus in July 2017 is on building out the framework for DBP 
  and SBP blood pressure values."), type="string"
)
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "sdtm-graph"),
  paste0(prefix.DCTERMS, "title"),
  paste0("SDTM data as RDF."), type="string"
)
# Later change these to link to FOAF description of the people as separate resources
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "sdtm-graph"),
  paste0(prefix.DCTERMS, "contributor"),
  paste0("Tim Williams"), type="string"
)
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "sdtm-graph"),
  paste0(prefix.DCTERMS, "contributor"),
  paste0("Armando Oliva"), type="string"
)
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "sdtm-graph"),
  paste0(prefix.PAV, "createdOn"),
  paste0(gsub("(\\d\\d)$", ":\\1",strftime(Sys.time(),"%Y-%m-%dT%H:%M:%S%z"))), type="dateTime"
)
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "sdtm-graph"),
  paste0(prefix.PAV, "createdWith"),
  paste0("R Version ", R.version$major, ".", R.version$minor,
    " Platform:", R.version$platform, " with scripts from SDTM Data to RDF Working group"), type="string"
)
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "sdtm-graph"),
  paste0(prefix.PAV, "version"),
  paste0(version), type="string"
)
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "sdtm-graph"),
  paste0(prefix.DCAT, "distribution"),
  paste0(outFileMain)
)
#TODO:  Reinstate, listing source folder of files instead of indivdual files?
#add.data.triple(cdiscpilot01,
#  paste0(prefix.CDISCPILOT01, "sdtm-graph"),
#  paste0(prefix.PROV, "wasDerivedFrom"),
#  paste0(inFilename)
#)

#-- Part 2: For values created only once:
#TODO: MOVE THIS TO THE CODELIST R SCRIPT.
#  Value is hard coded here. Make it data driven.
add.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "study-CDISCPILOT01"),
  paste0(prefix.RDF,"type" ),
  paste0(prefix.STUDY,"Study")
)
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "study-CDISCPILOT01"),
  paste0(prefix.STUDY,"hasStudyID" ),
  paste0("CDISCPILOT01"), type="string" 
)
add.data.triple(cdiscpilot01,
  paste0(prefix.CDISCPILOT01, "study-CDISCPILOT01"),
  paste0(prefix.RDFS,"label" ),
  paste0("study-CDISCPILOT01"), type="string" 
)
