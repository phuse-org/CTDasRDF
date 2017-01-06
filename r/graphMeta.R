###############################################################################
# FILE: graphMeta.R 
# DESC: Create metadata triples 
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: Version number is set in buildRDFDriver.R
# TODO: Study information is hard coded here. Make it data driven (extracted 
#       from a domain).
###############################################################################
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.RDFS, "comment"),
    paste0("Example SDTM data converted from CDISC SDTM to RDF Graph as part of the SDTM Data to RDF project."), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.RDFS, "label"),
    paste0("SDTM data as a graph."), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.DCTERMS, "description"),
    paste0("Data converted from the CDISCPILOT01 SDTM DM domain to RDF."), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.DCTERMS, "title"),
    paste0("SDTM data as RDF."), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.DCTERMS, "contributor"),
    paste0("Tim Williams"), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.DCTERMS, "contributor"),
    paste0("Armando Oliva"), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.PAV, "createdOn"),
    paste0(gsub("(\\d\\d)$", ":\\1",strftime(Sys.time(),"%Y-%m-%dT%H:%M:%S%z"))), type="dateTime"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.PAV, "createdWith"),
    paste0("R Version ", R.version$major, ".", R.version$minor,
        " Platform:", R.version$platform, " with scripts from SDTM Data to RDF Working group"), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.PAV, "version"),
    paste0(version), type="string"
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.DCAT, "distribution"),
    paste0(outFilename)
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
    paste0(prefix.PROV, "wasDerivedFrom"),
    paste0("/SDTM2RDF/data/source/")
)
#-- Study Information. 
add.triple(store,
    paste0(prefix.CDISCPILOT01, "study-CDISCPILOT01"),
    paste0(prefix.RDF,"type" ),
    paste0(prefix.STUDY,"Study")
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "study-CDISCPILOT01"),
    paste0(prefix.STUDY,"hasStudyID" ),
    paste0("CDISCPILOT01"), type="string" 
)
add.data.triple(store,
    paste0(prefix.CDISCPILOT01, "study-CDISCPILOT01"),
    paste0(prefix.RDFS,"label" ),
    paste0("Study-CDISCPILOT01"), type="string" 
)