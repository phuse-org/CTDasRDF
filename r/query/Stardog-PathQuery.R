###############################################################################
# FILE: Stardog-PathQuery.R
# DESC: Developing the Stardog path query functionality for later use in 
#         RShiny app.
# SRC : 
# IN  : triplestore database CTDasRDFOnt
# OUT : 
# REQ : Stardog running: 1. on port  5820
#       2. with --disable-security option during start
# SRC : 
# NOTE:
# TODO: Adjust code for use in a new version of CollapsibeTree-Shiny.R to use
#       paths instead of SPARQL.
###############################################################################
library(SPARQL)

# Query StardogTriple Store ----
endpoint <- "http://localhost:5820/CTDasRDFOnt/query"

queryOnt = paste0("
    PREFIX cdiscpilot01: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#> 
    PREFIX study: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#> 
    PATHS
    START ?s = cdiscpilot01:Person_1 
    END ?o
    VIA ?p     
")



# Or: ready prefixes in from prefixes.csv project file.
prefix <- c("cd01p",        "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01-protocol.ttl",
            "cdiscpilot01", "<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#>",
            "code",         "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/code.ttl#",
            "custom",       "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/custom#",
            "owl",          "http://www.w3.org/2002/07/owl#",
            "rdf",          "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            "rdfs",         "http://www.w3.org/2000/01/rdf-schema#",
            "sdtmterm",     "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/sdtm-terminology.rdf#",
            "skos",         "http://www.w3.org/2004/02/skos/core#",
            "study",        "https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#",
            "time",         "http://www.w3.org/2006/time#")

# qd <- SPARQL(endpoint, queryOnt, ns=prefix)
qd <- SPARQL(endpoint, queryOnt)
triplesDF <- qd$results
# Post query processing
triplesDF <- triplesDF[complete.cases(triplesDF), ]  # remove blank rows. 
triplesDF <- triplesDF[, c("s", "p", "o")]   # remove o.l, s.l
triplesDF <- unique(triplesDF)  # Remove dupes


# Create a function for this:
triplesDF$s <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#", 
  "cdiscpilot01:", triplesDF$s)

# Predicates 
triplesDF$p <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#", 
  "cdiscpilot01:", triplesDF$p)
triplesDF$p <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/code.ttl#", 
  "code:", triplesDF$p)
triplesDF$p <- gsub("<http://www.w3.org/1999/02/22-rdf-syntax-ns#", 
  "rdf:", triplesDF$p)
triplesDF$p <- gsub("<http://www.w3.org/2000/01/rdf-schema#", 
  "rdfs:", triplesDF$p)
triplesDF$p <- gsub("<http://www.w3.org/2004/02/skos/core#", 
  "skos:", triplesDF$p)
triplesDF$p <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#", 
  "study:", triplesDF$p)
triplesDF$p <- gsub("<http://www.w3.org/2006/time#", 
  "time:", triplesDF$p)

# Objects
triplesDF$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#", 
  "cdiscpilot01:", triplesDF$o)
triplesDF$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/code.ttl#", 
  "code:", triplesDF$o)
triplesDF$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01-protocol.ttl", 
  "cd01p:", triplesDF$o)
triplesDF$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/custom#", 
  "custom:", triplesDF$o)
triplesDF$o <- gsub("<http://www.w3.org/1999/02/22-rdf-syntax-ns#", 
  "rdf:", triplesDF$o)
triplesDF$o <- gsub("<http://www.w3.org/2000/01/rdf-schema#", 
  "rdfs:", triplesDF$o)
triplesDF$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/sdtm-terminology.rdf#", 
  "sdtmterm:", triplesDF$o)
triplesDF$o <- gsub("<http://www.w3.org/2004/02/skos/core#", 
  "skos:", triplesDF$o)
triplesDF$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#", 
  "study:", triplesDF$o)
triplesDF$o <- gsub("<http://www.w3.org/2006/time#", 
  "time:", triplesDF$o)


# Remove the trailing >
triplesDF$s <- gsub(">", "", triplesDF$s)
triplesDF$p <- gsub(">", "", triplesDF$p)
triplesDF$o <- gsub(">", "", triplesDF$o)


rootNodeDer <- data.frame(s=NA,p="foo", o="cdiscpilot01:Person_1",
  stringsAsFactors=FALSE)
triplesDF <- rbind(rootNodeDer, triplesDF)

head(triplesDF)

# Re-order as needed by collapsibleNodes pkg.

