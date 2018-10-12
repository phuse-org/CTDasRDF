#______________________________________________________________________________
# FILE: SMSMapVis.R
# DESC: Visualization of SMS files in CTDasRDF Project
#       Used to understand the mapping of SDTM domains to the graph schema and
#       as an aid in creatin queries. 
# SRC : 
# IN  : hard coded TTL source files
# OUT : visNetwork graph
# REQ : 
# SRC : Map files in data/source folder:
#           A.TTL
#           B.TTL
#           C.TTL
#    
# NOTE: 
#   label - appears on the node/edge.  HTML is not prermitted
#   title - appears on mouseover.      HTML is permitted
#
#   Nodes that are the object of an rdf:type subject are identified as 
#         Onotology nodes and are styled distinctly to imply their link to 
#         ontology files. 
# TODO:  Change Edge color to dark orange when value is rdf:type 
#______________________________________________________________________________
library(stringr)
library(visNetwork)
library(reshape)  #  melt
library(dplyr)

# Configuration
setwd("C:/_gitHub\\CTDasRDF")
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

    sourceContent <- lapply(sourceFiles, function(fileName) {
    
    fileNamePath <- paste0("data/source/",fileName)
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

#triples<-data.frame(parseFile(sourceFiles=list("ut_kricreatval_parsed_map.TTL", 
#  "macros_parsed_map.TTL", "macros_type_parsed_map.TTL", "KRITemplate_parsed_map.TTL")))

#triples<-data.frame(parseFile(sourceFiles=list("DM_Mappings.TTL", "VS_Mappings.TTL",
#  "EX_Mappings.TTL")))

triples<-data.frame(parseFile(sourceFiles=list("DM_Mappings.TTL")))


# Assign titles ----
triples$Title <- triples$o

# Re-order dataframe. 
triples<-triples[c("s", "p", "o", "Title", "mapFile")]

# Ontology Nodes --------------------------------------------------------------
# Create a dataframe to assign the Ontology Group to objects preceded by
#   the predicate rdf:type. Later merge back into the nodes list.
#   Create a copy of the triples df otherwise get nodes named Ont and group
#   in later transformations.
ontMassage <- triples
ontMassage[grepl("rdf:type", ontMassage$p) , "group"] <- 'Ontology'
# Keep the O designated as ontology objects
ontologyNodes <- ontMassage[ontMassage$group =="Ontology", c("o", "group")]
ontologyNodes <- ontologyNodes[complete.cases(ontologyNodes), ]
ontologyNodes <- ontologyNodes[!duplicated(ontologyNodes$o),] # Remove duplicate Objects

# Rename to allow later merge name
names(ontologyNodes)[1] <- "id"


#-----------------------------------------------------
# Remove duplicates from the df
triples <- triples[!duplicated(triples),]

#---- Nodes Construction
# Get the unique list of nodes 
# Combine Subject and Object into a single column
# "id.vars" is the list of columns to keep untouched. The unamed ones (s,o) are 
# melted into the "value" column.
nodeList <- melt(triples, id.vars=c("p", "mapFile"))

# A node can be both a Subject and a Predicate so ensure a unique list of node names
#  by dropping duplicate values.
nodeList <- nodeList[!duplicated(nodeList$value),]

# Rename to ID for use in visNetwork and keep only that column
nodeList <- reshape::rename(nodeList, c("value" = "id" ))
nodes <- as.data.frame(nodeList[c("id", "mapFile")])


# nodes$foo <- paste0(">", nodes$id, "<")
nodes <- as.data.frame(nodes[!duplicated(nodes), ])

# Merge in the Ontology designations
nodes <- merge(nodes, ontologyNodes, by="id", all=TRUE)

# Assign groups -----
#TODO NEED UPDATESS FOR CTDasRDF!
#  Used for icon types and colours
# Prefixes in various files:
#   cdiscpilot01, study, code, time, cdo1p, owl, 


nodes$group[ is.na(nodes$group) & 
             grepl("DM_Mappings.TTL",  nodes$mapFile, perl=TRUE) &
             grepl("^study:",                          nodes$id, perl=TRUE)] <- "ut_kricreatvalIRI"  

nodes$group[ is.na(nodes$group) & 
             grepl("ut_kricreatval_parsed_map.TTL",  nodes$mapFile, perl=TRUE) &
             grepl("^\"",                            nodes$id, perl=TRUE)] <- "ut_kricreatval"  


# Macros IRI, non-IRI
nodes$group[is.na(nodes$group) & 
            grepl("macros_parsed_map.TTL",          nodes$mapFile, perl=TRUE) &
            grepl("^rbm:",                          nodes$id, perl=TRUE)] <- "MacrosIRI"
nodes$group[is.na(nodes$group) & 
            grepl("macros_parsed_map.TTL",          nodes$mapFile, perl=TRUE) &
            grepl("^\"",                            nodes$id, perl=TRUE)] <- "Macros"

# KRI Template IRI, non-IRI
nodes$group[is.na(nodes$group) & 
            grepl("KRITemplate_parsed_map.TTL", nodes$mapFile, perl=TRUE) & 
            grepl("^rbm:",                      nodes$id, perl=TRUE)] <- "KRITemplateIRI"
nodes$group[is.na(nodes$group) & 
            grepl("KRITemplate_parsed_map.TTL", nodes$mapFile, perl=TRUE) & 
            grepl("^\"",                        nodes$id, perl=TRUE) ] <- "KRITemplate"
 
# Special hard codes for nodes that join between maps. Later do this programatically
#  by finding nodes that are repeated in more than one file.
# nodes$group[nodes$id =="rbm:KriUid_{kriuid}"] <- "Joiner"
nodes$group[grepl("rbm:KriUid_{kriuid}|rbm:MacroName_{macroname}",   
        nodes$id, perl=TRUE)] <- "Joiner"  

# Label and Title ----
nodes$title <- gsub("\\{", "<font color='red'>\\{", nodes$id, perl=FALSE)
nodes$title <- gsub("\\}", "\\}</font>", nodes$title)

#TW if the id value is longer than maxLabelSize and is a string. truncate using ...
# id gets coerced to integer within ifelse, must use as.character to overcome!
#nodes$label <-nodes$id  # label for the node. No HTMl allowed.
nodes$label="";

nodes$label <- strtrim(nodes$id, maxLabelSize) 

# nodes$label <- paste0(strtrim(nodes$id, 20), "...")
nodes$shape <- "box"



#---- Edges
# Create list of edges by keeping the Subject and Predicate from query result.
edges<-reshape::rename(triples, c("s" = "from", "o" = "to"))
edges$arrows <- "to"
# edges$label <-"Edge"   # label : text always present
edges$title <- edges$p  # title: present when mouseover edge.
edges$label <- edges$p  #TW  May need to shorten as did for node label
edges$color <-"#808080" # Default edge color
edges$color[ grepl("rdf:type", edges$p, perl=TRUE) ] <- "orange"
edges$length <- 500



#---- Legend
#  Examples at : https://datastorm-open.github.io/visNetwork/legend.html  
# Custom Legend dataframes
# Nodes . Colors match assignments within visGroups
#   Styles:  Map file = Background color
#            Prefix   = Border 

lnodes <- read.table(header = TRUE, text = "
label        color.border color.background 
DM           'white'      '#B3CDE3'
VS           'white'      '#CCEBC5'
EX           'white'      '#DECBE4'
TS           'white'      '#FF9A9A'
cdiscpilot01 'blue'       'white'
cdo1p        'lightblue'  'white'
code         'red'        'white'
study        'green'      'white'
time         'purple'     'white'
owl          'orange'     'white'
")
lnodes$shape <- "box"
lnodes$title <- "Legend"


#---- Visualize 
visNetwork(nodes, edges, width= "100%", height=1100) %>%
    
  visIgraphLayout(layout = "layout_nicely",
                  physics = FALSE) %>%  

  visIgraphLayout(avoidOverlap = 1) %>%

  # visEdges(smooth=FALSE, color="#808080") %>%
  visEdges(smooth=FALSE) %>%
  
  #DEBUG  visConfigure(enabled = TRUE) %>%
  
  visGroups(groupname = "ut_kricreatvalIRI", 
              borderWidth = 2,
              color   = list(background="#B3CDE3", border="#7ba8ce"))  %>%
  visGroups(groupname = "ut_kricreatval", 
              borderWidth = 2,
              color   = list(background="#ededed", border="#7ba8ce"))  %>%
  
  
  visGroups(groupname = "MacrosIRI", 
              borderWidth = 2,
              color   = list(background="#CCEBC5", border="#9ad78c")) %>%
  visGroups(groupname = "Macros", 
              borderWidth = 2,
              color   = list(background="#ededed", border="#9ad78c")) %>%
  
  
  visGroups(groupname = "KRITemplateIRI", 
              borderWidth = 2,    
              color   = list(background="#DECBE4", border="#be99ca")) %>%
  visGroups(groupname = "KRITemplate", 
              borderWidth = 2,    
              color   = list(background="#ededed", border="#be99ca")) %>%
    
  visGroups(groupname = "Ontology", 
              borderWidth = 2,    
              color   = list(background="#ffae1a", border="#e69500"))%>%
  
  visGroups(groupname = "Join", 
              borderWidth = 2,    
              color   = list(background="#ff9a9a", border="#ff1a1a"))%>%
  # Legend
  #  Examples at : https://datastorm-open.github.io/visNetwork/legend.html  
  visLegend(addNodes  = lnodes, 
            useGroups = FALSE,
            width     =  .2,
            stepY     = 60)
   


