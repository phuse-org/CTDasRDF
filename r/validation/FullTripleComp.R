###############################################################################
# FILE: fullTripleComp.R
# DESC: Compare all triples in the Ont and R versions of the TTL file. 
#         TTL file with aonther.
#       Eg Usage: Compare TTL file generated from TopBraid with one created using R
# SRC : Based on VisClasses-Shiny.R and CompareTTL.R
# IN  : Hard coded input files to save time during QC
# OUT : datatable
# REQ : rrdf
# NOTE: Side by side display of the triples available from Ont,R, not just the ones
#         that do not match.
# TODO: Add "exceptions" dataframe to remove artifacts from either source in the
#        in the comparison.
#       Convert to use of redland pkg
###############################################################################
library(plyr)    #  rename
library(dplyr)   # anti_join. MUst load dplyr AFTER plyr!!
library(reshape) #  melt
library(rrdf)
library(DT)

# Subjects in Ontology for testing that are not in the R conversion (yet)
#   these will be deleted from the ontology dataframe prior to comparison
# Source of cd01p:StartRuleNone is unknown. Not in cdiscpilot01.ttl
# Some of hasEntity is in the file...but why?
# study:HumanStudySubject  - several triples appear due to inferencing, due to:
#  <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/sdtm#hasEntity>
#  rdfs:range study:HumanStudySubject ;
#                          
# cdiscpilot01:UnscheduledVisit_1  - will be present later when patient 01-716-1026 is processed
#       AO email 15Sep17
removeSubjects <- c("cdiscpilot01:Site_2", "cdiscpilot01:Site_3","cdiscpilot01:Site_4",
  "cdiscpilot01:Site_5","cdiscpilot01:Site_6","cdiscpilot01:Site_7","cdiscpilot01:Site_8",
  "cdiscpilot01:Site_9","cdiscpilot01:Site_10","cdiscpilot01:Site_11","cdiscpilot01:Site_12",
  "cdiscpilot01:Site_13","cdiscpilot01:Site_14","cdiscpilot01:Site_15","cdiscpilot01:Site_16",
  "https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/sdtm#hasEntity",
  "study:HumanStudySubject",
  "study:UnscheduledVisit",
  "cdiscpilot01:UnscheduledVisit_1"
  )

# No longer omitting:
#   "cd01p:StartRuleNone",
# "study:HumanStudySubject",


setwd("C:/_github/CTDasRDF")
allPrefix <- "data/config/prefixes.csv"  # List of prefixes

# Prefixes from config file ----
prefixes <- as.data.frame( read.csv(allPrefix,
  header=T,
  sep=',' ,
  strip.white=TRUE))
# Create individual PREFIX statements
prefixes$prefixDef <- paste0("PREFIX ", prefixes$prefix, ": <", prefixes$namespace,">")

# All s,p,o from both files. 
query = paste0(paste(prefixes$prefixDef, collapse=""),
  "SELECT ?s ?p ?o 
   WHERE {?s ?p ?o .}
  ORDER BY ?s ?p ?o")

#---- Ontology Triples 
sourceOnt = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")
triplesOnt <- as.data.frame(sparql.rdf(sourceOnt, query))
# Remove cases where O is missing in the Ontology source(atrifact from TopBraid)
triplesOnt <-triplesOnt[!(triplesOnt$o==""),]
triplesOnt <- triplesOnt[complete.cases(triplesOnt), ]
# Remove extra test data from the ont triples
triplesOnt <- triplesOnt[ ! triplesOnt$s %in% removeSubjects, ]

#-- R Triples
sourceR = load.rdf("data/rdf/cdiscpilot01-R.TTL", format="N3")
triplesR <- as.data.frame(sparql.rdf(sourceR, query))

#--- In R and not in Ontology 
RNotOnt <-anti_join(triplesR, triplesOnt)
RNotOnt <-RNotOnt[with(RNotOnt, order(s,p,o)), ]  # Not needed...

OntNotR <- anti_join(triplesOnt, triplesR)
OntNotR <- OntNotR[with(OntNotR, order(s,p,o)), ]  # Not needed...

datatable(OntNotR)
