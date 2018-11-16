#______________________________________________________________________________
# FILE: r/vis/SMSMapVis-app/global.R
# DESC: SMS Visualization App
#       Includes function to parse map files into s,p,o
# SRC :
# IN  : Hard coded map file names as data source
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
#______________________________________________________________________________
library(stringr)     # str_extract
library(visNetwork)   
library(reshape)     # melt, rename
library(dplyr)  
library(DT)

# Set wd 3 levels up, to folder CTDasRDF. Navigate down from 
# there to data/source/ to obtain TTL source data.
setwd("../../../")
currDir<-getwd()

cat("Current Dir=",currDir)
maxLabelSize <- 40

#' Parse SMS files
#' Parse SMS Files into triples for plotting
#'
#' @param sourceFiles List of files to parse

#' @return s,p,o triples in a dataframe, used for plotting with visNetwork
#'
#' @examples
#' parseFiles(sourceFiles=list("a.TTL", "b.TTL") 
#' 
parseFile <- function(sourceFiles){
  triples <- data.frame(s               = character(),
                        p               = character(), 
                        o               = character(), 
                        mapFile         = character(), 
                        stringsAsFactors = FALSE) 

    # Process each source file in the list
    sourceContent <- lapply(sourceFiles, function(fileName) {
    
    fileNamePath <- paste0("data/source/",fileName, "_map.TTL")
    print(paste0("FILE: ", fileNamePath))
    conn <- file(fileNamePath,open="r")
    linn <-readLines(conn)
    for (i in 1:length(linn)){
      # SUBJECT : Starts Flush left, has prefix ':'
      #          Does not end with ; or .
      if(grepl("^\\S+:\\S+[^.;]", linn[i], perl=TRUE)){
        s <- linn[i]
        s <- gsub(" ", "", s)  # Remove all spaces from subjects
        p <- NULL
        o <- NULL
        #DEBUG print(paste("S LINE::", linn[i]))
      }
      else if(grepl("^\\s+\\S+:\\S+\\s+[\\S+\\s*]*;$", linn[i], perl=TRUE)){
        #DEBUG print(paste("P,O LINE::", linn[i]))
        p <- str_extract(linn[i], "^\\s+\\S+:\\S+")
        o <- gsub(p, "", linn[i]) # o is the line with p removed
        
        o <- sub("\\s*;\\s*$|\\s+$", "", o, perl = TRUE)  # remove ending ; and extra spaces

        # Remove any leading spaces
        s <- gsub("^\\s+", "", s) 
        o <- gsub("^\\s+", "", o) 
        
        mapFile <-fileName  # Name of file without sub path
        triples <<- rbind(triples, data.frame(s=s, p=p, o=o, mapFile=mapFile))
      }
    }  
    close(conn)
    # Assign titles ----
    triples$Title <- triples$o
    # Re-order dataframe. 
    triples<-triples[c("s", "p", "o", "Title", "mapFile")]
    # Remove duplicates from the df
    triples <- triples[!duplicated(triples),]
  })

  foo <- triples
}  

# Create triples DF from known TTL files
triples<-data.frame(parseFile(sourceFiles=list("DM", "SUPPDM", "EX", "VS", "Graphmeta", "Invest")))

#---- Formatting 
#  _bc = background colours
#  _ec = edge colours
cdiscpilot01_bc <-"blue"
cd01p_bc        <- "lightblue"
code_bc         <- "red"
study_bc        <- "green"
time_bc         <- "purple"
owl_bc          <- "orange"
dm_ec           <- '#B3CDE3'

# Legend Nodes
lnodes <- read.table(header = TRUE, text = "
label        color.border color.background 
DM           'blue'        'white'
VS           'white'      '#CCEBC5'
EX           'white'      '#DECBE4'
TS           'white'      '#FF9A9A'
cdiscpilot01 'blue'       'white'
cdo1p        'lightblue'  'white'
code         'red'        'white'
study        'green'      ''
time         'purple'     'white'
owl          'orange'     'white'
")
lnodes$shape <- "box"
lnodes$title <- "Legend"

#-- Legend Nodes Legend ----
# Yellow node:    #FFBD09
# Blue node:      #2C52DA
# Bright. Turq:   #3DDAFD
# Green node:     #008D00
# BlueGreen node: #1C5B64
# DK red node:    #870922
# Br red node:    #C71B5F
# Purp Node:      #482C79
# Br. Or Node:    #FE7900

lnodes <- read.table(header = TRUE, text = "
label         color.border color.background font.color
cdiscpilot01  'black'       '#2C52DA'      'white'
cdo1p         'black'       '#008D00'      'white'
code          'black'       '#1C5B64'      'white'
study         'black'       '#FFBD09'      'white'
custom        'black'       '#C71B5F'      'white'
Literal       'black'       'white'        'black'
")

lnodes$shape <- "box"
lnodes$title <- "Legend"