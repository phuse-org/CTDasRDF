###############################################################################
# FILE: fullTripleComp-Stardog.R
# DESC: Compare all Ontology instance triples graph (CTDasRDFOnt) with those 
#         created by SMS Mapping (CTDasRDF) graph.
# SRC : Based on code fullTriplesComp.R from comparing TTL files.
# IN  : Stardog graphs: CTDasRDFOnt, CTDasRDF
# OUT : datatable
# REQ : Stardog running, graph populated.
# NOTE:  CAUTION: Not comparing skos:prefLabel as of 21JUN18
# TODO: Add "exceptions" dataframe to remove artifacts from either source in the
#        in the comparison.
###############################################################################
library(plyr)    #  rename
library(dplyr)   # anti_join. MUst load dplyr AFTER plyr!!
library(reshape) #  melt
library(SPARQL)
library(DT)

setwd("C:/_gitHub/CTDasRDF/r")
source("validation/Functions.R")

# Endpoints
epOnt = "http://localhost:5820/CTDasRDFOnt/query"
epSMS = "http://localhost:5820/CTDasRDFSMS/query"

## May need this again later.
## Subjects in Ontology for testing that are not in the R conversion (yet)
##   these will be deleted from the ontology dataframe prior to comparison
## Source of cd01p:StartRuleNone is unknown. Not in cdiscpilot01.ttl
## Some of hasEntity is in the file...but why?
## study:HumanStudySubject  - several triples appear due to inferencing, due to:
##  <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/sdtm#hasEntity>
##  rdfs:range study:HumanStudySubject ;
##                          
## cdiscpilot01:UnscheduledVisit_1  - will be present later when patient 01-716-1026 is processed
##       AO email 15Sep17
#removeSubjects <- c("cdiscpilot01:Site_2", "cdiscpilot01:Site_3","cdiscpilot01:Site_4",
#  "cdiscpilot01:Site_5","cdiscpilot01:Site_6","cdiscpilot01:Site_7","cdiscpilot01:Site_8",
#  "cdiscpilot01:Site_9","cdiscpilot01:Site_10","cdiscpilot01:Site_11","cdiscpilot01:Site_12",
#  "cdiscpilot01:Site_13","cdiscpilot01:Site_14","cdiscpilot01:Site_15","cdiscpilot01:Site_16",
#  "https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/sdtm#hasEntity",
#  "study:HumanStudySubject",
#  "study:UnscheduledVisit",
#  "cdiscpilot01:UnscheduledVisit_1"
#  )

# No longer omitting:
#   "cd01p:StartRuleNone",
# "study:HumanStudySubject",



# Read in the prefixes
prefixList <- read.csv(file="prefixList.csv", header=TRUE, sep=",")

# Create a combined prefix IRI column.
prefixList$prefix_ <- paste0("PREFIX ",prefixList$prefix, " ", prefixList$iri)

# Collapse into a single string
prefixBlock <- paste(prefixList$prefix_, collapse = "\n")

# All s,p,o from both files. 
query = paste0(paste(prefixBlock, collapse=""),
  "SELECT ?s ?p ?o 
   WHERE {?s ?p ?o .}
  ORDER BY ?s ?p ?o")


#---- Ontology Triples---------------------------------------------------------
qrOnt <- SPARQL(url=epOnt, query=query)
triplesOnt <- qrOnt$results

# Remove triples that describe the source TTL file. Artifact from TopBraid.
triplesOnt <- triplesOnt[ !(triplesOnt$s =='<<http://w3id.org/phuse/cdiscpilot01#>'), ]



# Shorten from IRI to qnam
triplesOnt <- IRItoPrefix(sourceDF=triplesOnt, colsToParse=c("s", "p", "o"))

# Sort the dataframe values for display
triplesOnt<-triplesOnt[with(triplesOnt, order(p, o)), ]


# Remove cases where O is missing in the Ontology source(atrifact from TopBraid)
triplesOnt <-triplesOnt[!(triplesOnt$o==""),]
triplesOnt <- triplesOnt[complete.cases(triplesOnt), ]

## May need to reinstate:
# Remove extra test data from the ont triples
# triplesOnt <- triplesOnt[ ! triplesOnt$s %in% removeSubjects, ]

#---- SMS Triples ---------------------------------------------------------------
qrSMS <- SPARQL(url=epSMS, query=query)
triplesSMS <- qrSMS$results
# Shorten from IRI to qnam
triplesSMS <- IRItoPrefix(sourceDF=triplesSMS, colsToParse=c("s", "p", "o"))



#--- In R and not in Ontology 
SMSNotOnt <-anti_join(triplesSMS, triplesOnt)
SMSNotOnt <-SMSNotOnt[with(SMSNotOnt, order(s,p,o)), ]  # Not needed...

OntNotSMS <- anti_join(triplesOnt, triplesSMS)
OntNotSMS <- OntNotSMS[with(OntNotSMS, order(s,p,o)), ]  # Not needed...

# TEMP!!
# Remove preflabel for current checks.
# OntNotSMS <- OntNotSMS[!(OntNotSMS$p=="skos:prefLabel"),]

datatable(OntNotSMS)
