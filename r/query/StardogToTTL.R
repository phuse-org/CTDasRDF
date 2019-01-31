###############################################################################
# FILE: StardogToTTL.R
# DESC: Query Stardog for triples created from SMS process and craete TTL file
#       for construction of matching instance data in Ontology dev process.
# IN  : triplestore database CTDasRDF
# OUT : data/rdf/cdiscpilot01-SMS.TTL"
# REQ : Stardog running: 1. on port  5820
#       2. with --disable-security option during start
# NOTE:
# TODO: 
###############################################################################
library(plyr)
# library(dplyr)  

library(SPARQL)
library(redland)

# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")


# Query StardogTriple Store ----
endpoint <- "http://localhost:5820/CTDasRDF/query"

# Output filename and location
outTTLFile   = "data/rdf/cdiscpilot01-SMS.TTL"


# Redland declarations ----
world <- new("World") # Model scope
# Storage provides a mechanism to store models; in-memory hashes are convenient for small models
storage <- new("Storage", world, "hashes", name="", options="hash-type='memory'")
# A model is a set of Statements, and is associated with a particular Storage instance
resultsDF <- new("Model", world=world, storage, options="")



# Create Prefix references ----------------------------------------------------
# Or: ready prefixes in from prefixes.csv project file.
prefix <- c("cd01p",        "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01-protocol.ttl",
            "cdiscpilot01", "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#",
            "code",         "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/code.ttl#",
            "custom",       "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/custom#",
            "owl",          "http://www.w3.org/2002/07/owl#",
            "rdf",          "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            "rdfs",         "http://www.w3.org/2000/01/rdf-schema#",
            "sdtmterm",     "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/sdtm-terminology.rdf#",
            "skos",         "http://www.w3.org/2004/02/skos/core#",
            "study",        "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#",
            "time",         "http://www.w3.org/2006/time#")

query <- "SELECT *
  WHERE{
    ?s ?p ?o
  }"

qd <- SPARQL(endpoint, query, ns=prefix)
resultsDF <- qd$results


resultsDF
# Write out to TTL ------------------------------------------------------------
# Serialize the model to a TTL file
serializer <- new("Serializer", world, name="turtle", mimeType="text/turtle")

# Create the prefixes as a last step prior to serialization
ddply(prefixes, .(prefix), function(prefixes)
{
  status <- setNameSpace(serializer, world, 
    namespace=as.character(prefixes$namespace), prefix=as.character(prefixes$prefix))  
})
  
# Serialize to the file
status <- serializeToFile(serializer, world, resultsDF, outTTLFile)

# Validate --------------------------------------------------------------------
#   Always a good idea to validate, friendo.
system(paste('riot --validate ', outFileMain),
  show.output.on.console = TRUE)


