#______________________________________________________________________________
# FILE: SMSVisTesting.R
# DESC: Test visualization of SMS files as way to understand the structure of
#       the data resulting from their use.
# SRC : 
# IN  : hard coded TTL file: SUPPDM_mappings.TTL
# OUT : dataframe
# REQ : 
# SRC : 
# NOTE: 
# TODO: Add process of the triples dataframe to a collapsible tree diagram
#______________________________________________________________________________
library(stringr)
setwd("C:/_gitHub/CTDasRDF/data/source")

fileName <- "SUPPDM_mappings.TTL"

# Process the SMS file ----
# empty dataframe for the triples
triples <- data.frame(s=character(),
                      p=character(), 
                      o=character(), 
                      stringsAsFactors=FALSE) 

conn <- file(fileName,open="r")
linn <-readLines(conn)
for (i in 1:length(linn)){
  # SUBJECT : does not end with ; or . and is on a line by itself
  # p,o lines end in a semicolon after two \S:\S pairs
  if(grepl("^\\S+:\\S+[^.;]\\s*", linn[i], perl=TRUE)){
    s <- linn[i]
    p <- NULL
    o <- NULL
    # print(paste("S LINE::", linn[i]))
  }
  else if(grepl("\\s+\\S+:\\S+\\s*\\S*:\\S+\\s*;", linn[i], perl=TRUE)){
    # print(paste("P,O LINE::", linn[i]))
    p <- str_extract(linn[i], "^\\s+\\S+:\\S+")
    o <- str_extract(linn[i], "\\S*:\\S+\\s*;$")
    o <- sub(";$|\\s+$", "", o, perl = TRUE)  # remove ending ; and extra spaces

    # bind to dataframe 
    triples <- rbind(triples, data.frame(s=s, p=p, o=o))
  }
}  
close(conn)
