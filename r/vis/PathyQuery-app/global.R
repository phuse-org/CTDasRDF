#______________________________________________________________________________
# FILE: global.R
# DESC: Global for Stardog Path Query App
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
#______________________________________________________________________________
library(plyr)     #  rename
library(reshape)  #  melt
library(SPARQL)
library(visNetwork)
setwd("C:/temp/git/CTDasRDF/r")
source("validation/Functions.R")  # IRI to prefix and other fun


# startNode <- "cdiscpilot01:Person_01-701-1015"

# Endpoint
endpoint <- "http://localhost:5820/CTDasRDFSMS/query"

#-- Legend Nodes Legend ----
# Yellow node: #FFBD09
# Blue node: #2C52DA
# Bright. Turq:  #3DDAFD
# Green node: #008D00
# BlueGreen node: #1C5B64
# DK red node: #870922
# Br red node: #C71B5F
# Purp Node: #482C79
# Br. Or Node: #FE7900

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



