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
library(collapsibleTree)
# Query StardogTriple Store ----
endpoint <- "http://localhost:5820/CTDasRDFOnt/query"

queryOnt = paste0("
    PREFIX cdiscpilot01: <http://w3id.org/phuse/cdiscpilot01#> 
    PREFIX study: <http://w3id.org/phuse/study#> 
    PATHS
    START ?s = cdiscpilot01:Person_1 
    END ?o
    VIA ?p     
")



# Or: ready prefixes in from prefixes.csv project file.
prefix <- c("cd01p",        "http://w3id.org/phuse/cd01p",
            "cdiscpilot01", "<http://w3id.org/phuse/cdiscpilot01#>",
            "code",         "<http://w3id.org/phuse/code#",
            "custom",       "<http://w3id.org/phuse/custom#>",
            "owl",          "http://www.w3.org/2002/07/owl#",
            "rdf",          "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            "rdfs",         "http://www.w3.org/2000/01/rdf-schema#",
            "sdtmterm",     "http://w3id.org/phuse/sdtmterm#",
            "skos",         "http://www.w3.org/2004/02/skos/core#",
            "study",        "http://w3id.org/phuse/study#",
            "time",         "http://www.w3.org/2006/time#")

# qd <- SPARQL(endpoint, queryOnt, ns=prefix)
qd <- SPARQL(endpoint, queryOnt)
triplesDF <- qd$results
# Post query processing
triplesDF <- triplesDF[complete.cases(triplesDF), ]  # remove blank rows. 
triplesDF <- triplesDF[, c("s", "p", "o")]   # remove o.l, s.l
triplesDF <- unique(triplesDF)  # Remove dupes


# Create a function for this:
# Subjects
triplesDF$s <- gsub("<http://w3id.org/phuse/cdiscpilot01#", 
  "cdiscpilot01:", triplesDF$s)
triplesDF$s <- gsub("<http://w3id.org/phuse/cd01p", 
  "cd01p:", triplesDF$s)


# Predicates 
triplesDF$p <- gsub("<http://w3id.org/phuse/cdiscpilot01#", 
  "cdiscpilot01:", triplesDF$p)
triplesDF$p <- gsub("<http://w3id.org/phuse/code#", 
  "code:", triplesDF$p)
triplesDF$p <- gsub("<http://www.w3.org/1999/02/22-rdf-syntax-ns#", 
  "rdf:", triplesDF$p)
triplesDF$p <- gsub("<http://www.w3.org/2000/01/rdf-schema#", 
  "rdfs:", triplesDF$p)
triplesDF$p <- gsub("<http://www.w3.org/2004/02/skos/core#", 
  "skos:", triplesDF$p)
triplesDF$p <- gsub("<http://w3id.org/phuse/study#", 
  "study:", triplesDF$p)
triplesDF$p <- gsub("<http://www.w3.org/2006/time#", 
  "time:", triplesDF$p)

# Objects
triplesDF$o <- gsub("<http://w3id.org/phuse/cdiscpilot01#", 
  "cdiscpilot01:", triplesDF$o)
triplesDF$o <- gsub("<http://w3id.org/phuse/code#", 
  "code:", triplesDF$o)
triplesDF$o <- gsub("<http://w3id.org/phuse/cd01p", 
  "cd01p:", triplesDF$o)
triplesDF$o <- gsub("<http://w3id.org/phuse/custom#>", 
  "custom:", triplesDF$o)
triplesDF$o <- gsub("<http://www.w3.org/1999/02/22-rdf-syntax-ns#", 
  "rdf:", triplesDF$o)
triplesDF$o <- gsub("<http://www.w3.org/2000/01/rdf-schema#", 
  "rdfs:", triplesDF$o)
triplesDF$o <- gsub("<http://w3id.org/phuse/sdtmterm#", 
  "sdtmterm:", triplesDF$o)
triplesDF$o <- gsub("<http://www.w3.org/2004/02/skos/core#", 
  "skos:", triplesDF$o)
triplesDF$o <- gsub("<http://w3id.org/phuse/study#", 
  "study:", triplesDF$o)
triplesDF$o <- gsub("<http://www.w3.org/2006/time#", 
  "time:", triplesDF$o)


# Remove the trailing >
triplesDF$s <- gsub(">", "", triplesDF$s)
triplesDF$p <- gsub(">", "", triplesDF$p)
triplesDF$o <- gsub(">", "", triplesDF$o)


rootNodeDF <- data.frame(s=NA,p="Person 1", o="cdiscpilot01:Person_1",
  stringsAsFactors=FALSE)
triplesDF <- rbind(rootNodeDF, triplesDF)

# Code for plotting as collapsible nodes
# Re-order as needed by collapsibleNodes pkg.
triplesDF$Title <- triplesDF$o
triplesDF[1,"Title"] <- "cdiscpilot01:Person_1" # THis will come from the drop down selector
# Re-order dataframe. The s,o must be the first two columns.
triplesDF<-triplesDF[c("s", "o", "p", "Title")]


# 25 is to the end of Person_!
# foo<-head(triplesDF, 35)
foo<-triplesDF

collapsibleTreeNetwork(
  foo,
  c("s", "o"),
  tooltipHtml="p",
  width = "100%"
)








