#______________________________________________________________________________
# FILE: study_owl_vis.R
# DESC: Visualization of study.ttl OWL file in CTDasRDF Project
# STATUS: EARLY DEV, INCOMPLETE
# SRC : 
# IN  : 
# OUT : visNetwork graph
# REQ : 
# SRC : 
#    
# NOTE: 
#   label - appears on the node/edge.  HTML is not prermitted
#   title - appears on mouseover.      HTML is permitted
#   rdf:type predicates shown in orange 
#         
#         
#______________________________________________________________________________

library(stringr)
library(visNetwork)
library(reshape)  #  melt
library(dplyr)

# Configuration
setwd("C:/Temp/git/CTDasRDF")
maxLabelSize <- 40

#' Parse TTL file
#' Parse TTL File into triples for plotting
#'
#' @param sourceFiles List of files to parse
#' @param subfolder location of subfolder, e.g. "data/source/"
#' @return s,p,o triples in a dataframe, used for plotting with visNetwork
#'
#' @examples
#' parseTTLFile(sourceFiles=list("a.TTL", "b.TTL"), subfolder="data/source/") 
#' 
parseTTLFile <- function(sourceFiles, subfolder){
  
  triples <- data.frame(s               = character(),
                        p               = character(), 
                        o               = character(), 
                        mapFile         = character(), 
                        stringsAsFactors = FALSE) 
  
  sourceContent <- lapply(sourceFiles, function(fileName) {
    
    fileNamePath <- paste0(subfolder,fileName)
    print(paste0("FILE: ", fileNamePath))
    conn <- file(fileNamePath,open="r")
    linn <-readLines(conn)
    #DEUBUG print(linn)
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
  })
  foo <<- triples
}  


triples<-data.frame(parseTTLFile(sourceFiles=list("study.ttl"), subfolder = "data/rdf/"))

unique(triples$p)
write.csv(triples, file="Katja/study_tripples.csv", 
          row.names = F,
          na = "")


trans = read.csv(file = "Katja/study_tripples_transformed2.csv")
trans = read.csv(file = "Katja/study_interest_humanStudySubject.csv")


nodeList <- melt(trans, id.vars=c("subject", "label", "typeClass", "typeProp"))
nodeList <- nodeList[,c("value","typeClass")]

nodeList <- nodeList[!duplicated(nodeList$value),]
nodeList<-reshape::rename(nodeList, c("value" = "subject"))
class(nodeList)

nodupNodes <- trans[!duplicated(trans$subject),]

nodesList <- as.data.frame(nodupNodes[!is.na(nodupNodes["typeClass"] == 1), c("subject", "label")])
nodesList <- reshape::rename(nodesList, c("subject" = "id","label" = "description" ))
nodesList$label <- strtrim(nodesList$id, maxLabelSize) 
nodesList$shape <- "box"
nodesList$borderWidth <- 2

edgesList <- as.data.frame(trans[!is.na(trans["typeProp"]) & trans["fromDomain"] != ""  & trans["toRange"] != "", 
                                 c("subject", "fromDomain", "toRange")])
edgesList<-reshape::rename(edgesList, c("fromDomain" = "from", "toRange" = "to"))
edgesList$arrows <- "to"
edgesList$title <- edgesList$subject  # title: present when mouseover edge.
edgesList$label <- edgesList$subject  #TW  May need to shorten as did for node label
edgesList$color <-"#808080" # Default edge color
edgesList$length <- 500

#---- Visualize 
visNetwork(nodesList, edgesList, width= "100%", height=1100)


#---- Visualize 
visNetwork(nodesList, edgesList, width= "100%", height=1100) %>%
  
  visIgraphLayout(layout = "layout_nicely",
                  physics = FALSE)



# visNetwork(nodesList, edgesList, width= "100%", height=1100) %>%
#   
#   visIgraphLayout(layout = "layout_nicely",
#                   physics = FALSE) %>%  
#   
#   visIgraphLayout(avoidOverlap = 1) %>%
#   
#   visEdges(smooth=FALSE) 




# dim(!is.na(trans["typeProp"]))
# dim(trans["fromDomain"] != "")
# 
# !is.na(trans["typeProp"]) & trans["fromDomain"] != ""  & trans["toRange"] != ""
# 
# edgesList
# 
# trans[!is.na(trans["typeProp"] == 1), c("subject", "fromDomain", "toRange")]
# 
# trans[!is.na(trans["typeProp"] == 1) && edgesList["fromDomain"] != "", c("subject", "fromDomain", "toRange")]
# #trans[!is.na(trans["typeProp"] == 1) && edgesList[fromDomain] != "", c("subject", "fromDomain", "toRange")]
# 
# edgesList[edgesList[fromDomain != ""]]

# 
# trans[c("subject", "label")]
# trans[!is.na(trans["typeClass"] == 1), c("subject", "label")]
# 
# 
# nodesList <- data.frame(s               = character(),
#                         p               = character(), 
#                         o               = character(), 
#                         mapFile         = character(), 
#                         stringsAsFactors = FALSE) 
# df <- data.frame(Date=as.Date(character()),
#                  File=character(), 
#                  User=character(), 
#                  stringsAsFactors=FALSE) 
# 
# for (i in 1 : dim(trans)[1]){
#   if (!is.na(trans[i,"typeClass"]) && trans[i,"typeClass"] == 1) {
#     nodesList$id <- trans[i,"subject"]
#     nodesList$label <- trans[i,"label"]
#   } 
# }
# nodesList$color.border <- "#B3CDE3"
# 
# trans[1,"typeClass"]
# trans[65,"typeClass"]
# 
# !is.na(trans[1,"typeClass"]) && trans[1,"typeClass"] == 1
# !is.na(trans[65,"typeClass"]) && trans[65,"typeClass"] == 1
# 
# singleNodes <- trans[!is.na(trans["typeClass"] == 1), "subject"]
# nodesList$id <- singleNodes



  
#nodes <- as.data.frame(nodeList[c("id", "mapFile")])

# 
# 
# #triples<-data.frame(parseFile(sourceFiles=list("ut_kricreatval_parsed_map.TTL", 
# #  "macros_parsed_map.TTL", "macros_type_parsed_map.TTL", "KRITemplate_parsed_map.TTL")))
# 
# #triples<-data.frame(parseFile(sourceFiles=list("DM_Mappings.TTL", "VS_Mappings.TTL",
# #  "EX_Mappings.TTL")))
# 
# triples<-data.frame(parseFile(sourceFiles=list("DM_Mappings.TTL")))
# 
# 
# # Assign titles ----
# triples$Title <- triples$o
# 
# # Re-order dataframe. 
# triples<-triples[c("s", "p", "o", "Title", "mapFile")]
# 
# # Remove duplicates from the df
# triples <- triples[!duplicated(triples),]
# 
# #---- Formatting 
# #  _EC = edge colours
# #  _BC = background colours
# cdiscpilot01_bc <-"blue"
# cd01p_bc        <- "lightblue"
# code_bc         <- "red"
# study_bc        <- "green"
# time_bc         <- "purple"
# owl_bc          <- "orange"
# 
# dm_ec  <- '#B3CDE3'
# 
# 
# #---- Nodes Construction ------------------------------------------------------
# # Legend Nodes
# lnodes <- read.table(header = TRUE, text = "
#                      label        color.border color.background 
#                      DM           'blue'        'white'
#                      VS           'white'      '#CCEBC5'
#                      EX           'white'      '#DECBE4'
#                      TS           'white'      '#FF9A9A'
#                      cdiscpilot01 'blue'       'white'
#                      cdo1p        'lightblue'  'white'
#                      code         'red'        'white'
#                      study        'green'      ''
#                      time         'purple'     'white'
#                      owl          'orange'     'white'
#                      ")
# lnodes$shape <- "box"
# lnodes$title <- "Legend"
# 
# 
# #---- Nodes from the data
# # Get the unique list of nodes 
# # Combine Subject and Object into a single column
# # "id.vars" is the list of columns to keep untouched. The unamed ones (s,o) are 
# # melted into the "value" column.
# nodeList <- melt(triples, id.vars=c("p", "mapFile"))
# 
# # A node can be both a Subject and a Predicate so ensure a unique list of node names
# #  by dropping duplicate values.
# nodeList <- nodeList[!duplicated(nodeList$value),]
# 
# # Rename to ID for use in visNetwork and keep only that column
# nodeList <- reshape::rename(nodeList, c("value" = "id" ))
# nodes <- as.data.frame(nodeList[c("id", "mapFile")])
# 
# # nodes$foo <- paste0(">", nodes$id, "<")
# nodes <- as.data.frame(nodes[!duplicated(nodes), ])
# 
# # Colors
# # Default edge and fill
# #DEL nodes$color.border     <- "black"
# #DEL nodes$color.background <- "white"
# 
# 
# 
# #TW WIP HERE
# # Set the fill color using nodes$color assignment
# # Set the node border colour using visGroup options in visNetwork after assigning groups based on the data.
# 
# 
# # Set the fill based on the source file.
# # Imputations ----
# nodes[nodes$mapFile == "DM_Mappings.TTL", "color.border"] <- dm_ec
# 
# #TODO: Other mappings for edge colour based on source file
# 
# #TODO: Fill colors baed on regex to find cdispilot01, cd01p, study (red) etc.
# 
# 
# head(nodes)
# 
# 
# # Label and Title ----
# nodes$title <- gsub("\\{", "<font color='red'>\\{", nodes$id, perl=FALSE)
# nodes$title <- gsub("\\}", "\\}</font>", nodes$title)
# 
# #TW if the id value is longer than maxLabelSize and is a string. truncate using ...
# # id gets coerced to integer within ifelse, must use as.character to overcome!
# #nodes$label <-nodes$id  # label for the node. No HTMl allowed.
# nodes$label="";
# 
# nodes$label <- strtrim(nodes$id, maxLabelSize) 
# 
# # nodes$label <- paste0(strtrim(nodes$id, 20), "...")
# nodes$shape <- "box"
# nodes$borderWidth <- 2
# 
# 
# #---- Edges
# # Create list of edges by keeping the Subject and Predicate from query result.
# edges<-reshape::rename(triples, c("s" = "from", "o" = "to"))
# edges$arrows <- "to"
# # edges$label <-"Edge"   # label : text always present
# edges$title <- edges$p  # title: present when mouseover edge.
# edges$label <- edges$p  #TW  May need to shorten as did for node label
# edges$color <-"#808080" # Default edge color
# edges$color[ grepl("rdf:type", edges$p, perl=TRUE) ] <- "orange"
# edges$length <- 500
# 
# #---- Legend
# #  Examples at : https://datastorm-open.github.io/visNetwork/legend.html  
# # Custom Legend dataframes
# # Nodes . Colors match assignments within visGroups
# #   Styles:  Map file = Background color
# #            Prefix   = Border 
# 
# # BlUE #B3CDE3
# # Red  #FF9A9A
# 
# # visNetwork(nodes, edges, width= "100%", height=1100)
# head(nodes)
# 
# 
# #---- Visualize 
# visNetwork(nodes, edges, width= "100%", height=1100) %>%
#   
#   visIgraphLayout(layout = "layout_nicely",
#                   physics = FALSE) %>%  
#   
#   visIgraphLayout(avoidOverlap = 1) %>%
#   
#   # visEdges(smooth=FALSE, color="#808080") %>%
#   visEdges(smooth=FALSE) %>%
#   
#   ##  # Legend
#   #  Examples at : https://datastorm-open.github.io/visNetwork/legend.html  
#   visLegend(addNodes  = lnodes, 
#             useGroups = FALSE,
#             width     =  .2,
#             stepY     = 60)
# 
