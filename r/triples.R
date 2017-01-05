#########################################################################
# NAME  : triples.R 
# AUTH  : Tim W.
# DESCR : Create the RDF Triples from the spreadsheet data source. Some recoding
#             of original data occurs in buildRDF-Driver.R
# NOTES : 
# IN    : Input of raw data with minor massaging occurs in buildRDF-Driver.R
# OUT   : 
# REQ   : 
# TODO  : CLean up the code so dates are only written to the file when the value
#            is non-missing. Now writes N/A, which is good for debugging but 
#            little else.
###############################################################################

#------------------------------------------------------------------------------
# Create triples 
#     TODO: add is as "a" Study when creating the code list!
#----------------------- Data -------------------------------------------------

#-- Part 1:  Graph Metadata
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
# Later change these to link to FOAF description of the people as separate resources
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
        " Platform:", R.version$platform, " swith scripts from SDTM Data to RDF Working group"), type="string"
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
#TODO:  Reinstate, listing source folder of files instead of indivdual files?
#add.data.triple(store,
#    paste0(prefix.CDISCPILOT01, "sdtm-graph"),
#    paste0(prefix.PROV, "wasDerivedFrom"),
#    paste0(inFilename)
#)
#-- Part 2: For values created only once:
#TODO: MOVE THIS TO THE CODELIST R SCRIPT.
#  Value is hard coded here. Make it data driven.
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

#-- DOMAIN PROCESSING ---------------------------------------------------------
#---- DM DOMAIN
source('R/processDM.R')
processDM()


#---- VS DOMAIN
source('R/processVS.R')
processVS()

