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
    s <- gsub(" ", "", s)  # Remove all spaces from subjects
    p <- NULL
    o <- NULL
    # print(paste("S LINE::", linn[i]))
  }
  else if(grepl("\\s+\\S+:\\S+\\s*\\S*:\\S+\\s*;", linn[i], perl=TRUE)){
    # print(paste("P,O LINE::", linn[i]))
    p <- str_extract(linn[i], "^\\s+\\S+:\\S+")
    o <- str_extract(linn[i], "\\S*:\\S+\\s*;$")
    o <- sub(";$|\\s+$", "", o, perl = TRUE)  # remove ending ; and extra spaces
    o <- gsub(" ", "", o)  # Remove all spaces from objects. TODO: need to only remove from non-literals

    # bind to dataframe 
    triples <- rbind(triples, data.frame(s=s, p=p, o=o))
  }
}  
close(conn)

# Add aa 1 NA root node in the first column , needed by collapsible tree
# Create root nodes and append to start of dataframes
# NARootNode <- data.frame(s=NA,p="foo", o=input$rootNodeOnt,
# stringsAsFactors=FALSE)

NARootNode <- data.frame(s=NA,p="foo", o="cdiscpilot01:Person_{usubjid}",
  stringsAsFactors=FALSE)

triples <- rbind(NARootNode, triples)
    
# Assign titles ----
triples$Title <- triples$o
# triples[1,"Title"] <- input$rootNodeOnt  
triples[1,"Title"] <- "Start"  # Delete this

# Re-order dataframe. The s,o must be the first two columns.
triples<-triples[c("s", "o", "p", "Title")]


library(collapsibleTree)
    
collapsibleTreeNetwork(
      triples,
      c("s", "o"),
      tooltipHtml="p",
      width = "100%"
    )




#collapsibleTreeNetwork(df, inputId = NULL, attribute = "leafCount",
#  aggFun = sum, fill = "lightsteelblue", linkLength = NULL,
#  fontSize = 10, tooltip = TRUE, tooltipHtml = NULL, nodeSize = NULL,
#  collapsed = TRUE, zoomable = TRUE, width = NULL, height = NULL)




