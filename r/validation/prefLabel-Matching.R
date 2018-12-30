###############################################################################
# FILE: fullTripleComp-Stardog.R
# DESC: Compare the prefLabel values to standardize the values. .
# SRC : 
# IN  : Stardog graphs: CTDasRDFOnt, CTDasRDFSMS
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


# Read in the prefixes
prefixList <- read.csv(file="prefixList.csv", header=TRUE, sep=",")

# Create a combined prefix IRI column.
prefixList$prefix_ <- paste0("PREFIX ",prefixList$prefix, " ", prefixList$iri)

# Collapse into a single string
prefixBlock <- paste(prefixList$prefix_, collapse = "\n")

# All s,skosPrefLabel,o from both files. 
query = paste0(paste(prefixBlock, collapse=""),
  "SELECT ?s ?p ?o
   WHERE{
      ?s skos:prefLabel ?o
     BIND('skos:prefLabel' AS ?p)
   }")

#---- Ontology Triples---------------------------------------------------------
qrOnt <- SPARQL(url=epOnt, query=query)
triplesOnt <- qrOnt$results

# Shorten from IRI to qnam
triplesOnt <- IRItoPrefix(sourceDF=triplesOnt, colsToParse=c("s", "p", "o"))

# Sort later merge
triplesOnt<-triplesOnt[with(triplesOnt, order(s, p, o)), ]

# Rename object for later merge
names(triplesOnt)[names(triplesOnt) == 'o'] <- 'o.ont'



#---- SMS Triples ---------------------------------------------------------------
qrSMS <- SPARQL(url=epSMS, query=query)
triplesSMS <- qrSMS$results

# Shorten from IRI to qnam
triplesSMS <- IRItoPrefix(sourceDF=triplesSMS, colsToParse=c("s", "p", "o"))

# Sort later merge
triplesSMS<-triplesSMS[with(triplesSMS, order(s, p, o)), ]

# Rename object for later merge
names(triplesSMS)[names(triplesSMS) == 'o'] <- 'o.sms'


# Merge the data together
OntSMSdf <- merge(triplesOnt, triplesSMS, by.x = "s", by.y = "s")

#---- Clean up
# Rename object for later merge
names(OntSMSdf)[names(OntSMSdf) == 'p.x'] <- 'p'
OntSMSdf <- OntSMSdf[ , !(names(OntSMSdf) == "p.y")]

OntSMSdf$match<-"N"
OntSMSdf[OntSMSdf$o.ont == OntSMSdf$o.sms, "match"]  <- "Y"


# sort by s, o
OntSMSdf <- OntSMSdf[with(OntSMSdf, order(s, p, o.ont)), ]

datatable(OntSMSdf)

library(xlsx)  # this is the Java one. Eeew.
write.xlsx(OntSMSdf, "C:/_gitHub/CTDasRDF/data/source/prefLabel-QC.xlsx")


#--- In R and not in Ontology 
#SMSNotOnt <-anti_join(triplesSMS, triplesOnt)
#SMSNotOnt <-SMSNotOnt[with(SMSNotOnt, order(s,p,o)), ]  # Not needed...

#OntNotSMS <- anti_join(triplesOnt, triplesSMS)
#OntNotSMS <- OntNotSMS[with(OntNotSMS, order(s,p,o)), ]  # Not needed...
# 
# TEMP!!
# Remove preflabel for current checks.
#OntNotSMS <- OntNotSMS[!(OntNotSMS$p=="skos:prefLabel"),]

