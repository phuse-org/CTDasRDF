###############################################################################
# FILE: ListCustomInstanceClasses.R
# DESC: List the classes customterminoloty.TTL that are created from instance 
#         data. These must be created by the R Script process. The other
#         classes are created in Protege/Topbraid
# SRC : 
# IN  : customterminology.TTL
# OUT : 
# REQ : rrdf
# SRC : 
# NOTE: Used during building of TTL files from R
# TODO: 
###############################################################################
library(rrdf)
library(plyr)  # rename
library(reshape)   # melt
# For use with local TTL file:
setwd("C:/_gitHub/SDTMasRDF")

rSource = load.rdf("data/rdf/cdiscpilot01-R.TTL", format="N3")
ontSource = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")


query = 'prefix cdiscpilot01: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/cdiscpilot01#>
prefix study: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/study#>

SELECT  ?dateURI ?dateVal
WHERE { ?dateURI study:dateTimeInXSDString  ?dateVal .}
'

ontTriples = as.data.frame(sparql.rdf(ontSource, query))
ontTriples <-ontTriples[!duplicated(ontTriples), ]  # remove dupes

rTriples = as.data.frame(sparql.rdf(rSource, query))
rTriples <- rTriples[!duplicated(rTriples), ]  # remove dupes

dateComp <- merge(rTriples, ontTriples, by.x="dateVal", by.y="dateVal", all.x=TRUE, all.y=TRUE)





# OLD SHITE BELOW HERE

#classes <- melt(ontTriples, measure.vars = c("class", "subclass"))

#classes <- data.frame(classes[,"value"])
# remote dupes
#classes <- data.frame(classes[!duplicated(classes), ])  # is DF here.

# Rename column
#names(classes)[names(classes) == 'classes..duplicated.classes....'] <- 'class'

# Get list of those that are created from rdf frags in the data. custom: prefix with
#   '_' 
# These are the ones you need to create in R,  others are created in Protege/TopBraid.
# keep the custom: classes
#classes <- subset(classes, grepl("custom:\\S+_\\S+", class, perl=TRUE))