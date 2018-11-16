#______________________________________________________________________________
# FILE: r/vis/PathQuery-app/global.R
# DESC: Path Query App
# SRC :
# IN  : Stardog triplestore  CTDasRDFOnt (triples from Onotology instances)
# OUT : 
# REQ : r/validation/Functions.R
#       Stardog running on localhost with database CTDasRDFOnt populated
# SRC : 
# NOTE: 
# TODO: 
#
#______________________________________________________________________________
library(plyr)     #  rename
library(reshape)  #  melt
library(SPARQL)
library(visNetwork)

# Set wd 3 levels up, to folder CTDasRDF. Navigate down from 
# there to data/source/ to obtain TTL source data.
setwd("c:/Temp/git/CTDasRDF")
currDir<-getwd()
source("r/validation/Functions.R")  # IRI to prefix and other fun

Sys.setenv(http_proxy="")
Sys.setenv(https_proxy="")

# Endpoint
endpoint <- "http://localhost:5820/CTDasRDFOnt/query"

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
'Start Node'  'red'         'yellow'       'black'
cdiscpilot01  'black'       '#2C52DA'      'white'
cdo1p         'black'       '#008D00'      'white'
code          'black'       '#1C5B64'      'white'
study         'black'       '#FFBD09'      'white'
custom        'black'       '#C71B5F'      'white'
Literal       'black'       'white'        'black'
")

lnodes$shape <- "box"
lnodes$title <- "Legend"