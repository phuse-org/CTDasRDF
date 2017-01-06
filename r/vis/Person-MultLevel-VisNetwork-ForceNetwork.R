###############################################################################
# FILE : Person-MultLevel-VisNetwork-ForeNetwork.R
# DESCR: Visualization of the nodes connected to Person_1 as a FN graph
# SRC  : 
# KEYS : 
# NOTES:  
#         
#
# INPUT: cdiscpilot01.TTL  (OR) local endpoint graph SDTMTORDF
#      : 
# OUT  : 
# REQ  : 
# TODO : add mouseover labels to nodes
#        add mouseover labels to edges
#        add special icon for Person
#        add different colours 
#        change background colour to dark
###############################################################################
library(plyr)  #  rename
library(reshape)  #  melt
library(rrdf)
library(visNetwork)

# Select all the information associated with Obs113
query = 'PREFIX CDISCPILOT01: <http://example.org/cdiscpilot01#> 
PREFIX study: <http://example.org/study#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX cdiscsdtm: <http://rdf.cdisc.org/sdtm-terminology#>
PREFIX code:  <http://www.example.org/code#>
PREFIX custom: <http://www.example.org/custom#>
prefix time:  <http://www.w3.org/2006/time#>
prefix country: <http://psi.oasis-open.org/iso/3166#>
prefix x: <http://example.org/bogus>


SELECT ?s ?p ?o 
FROM <http://localhost:8890/SDTMTORDF>
where { CDISCPILOT01:Person_1 (x:foo|!x:bar)* ?s . 
?s ?p ?o . 
}'


#-- Local Endpoint 
#rdfSource = "http://localhost:8890/sparql"  # local EP
#DMTriples = as.data.frame(sparql.remote(rdfSource, query))  # for local EP

#-- Local TTL file
setwd("C:/_gitHub/SDTM2RDF")
rdfSource = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")

DMTriples = as.data.frame(sparql.rdf(rdfSource, query))

# Remove any rows that have a blank Object. 
DMTriples<-DMTriples[!(DMTriples$o==""),]

# Remove duplicates from the query
DMTriples <- DMTriples[!duplicated(DMTriples),]

#---- Nodes Construction
# Get the unique list of nodes 
# Combine Subject and Object into a single column
# "id.vars" is the list of columns to keep untouched. The unamed ones (s,o) are 
# melted into the "value" column.
nodeList <- melt(DMTriples, id.vars=c("p" ))

# A node can be both a Subject and a Predicate so ensure a unique list of node names
#  by dropping duplicate values.
nodeList <- nodeList[!duplicated(nodeList$value),]

# Rename to ID for use in visNetwork and keep only that column
nodeList <- rename(nodeList, c("value" = "id" ))
nodes<- as.data.frame(nodeList[c("id")])


# Assign groups used for icon types and colours
# Order is important.
# p:Person_1
# nodes$group[nodes$id == "p:Person_1"]    <- "Person"  # Works
nodes$group[grepl("cdiscsdtm", nodes$id, perl=TRUE)] <- "SDTMTerm"  #
nodes$group[grepl("study", nodes$id, perl=TRUE)] <- "Study"  #
nodes$group[grepl("CDISCPILOT01", nodes$id, perl=TRUE)] <- "CDISCPilot"  #
nodes$group[grepl("Person_", nodes$id, perl=TRUE)] <- "Person"  #
nodes$group[! grepl(":", nodes$id, perl=TRUE)] <- "Literal"  #
# temporary kludge that fails if a literal has a colon. Close enough for development.
nodes$shape <- ifelse(grepl(":", nodes$id), "ellipse", "box")

# Assign labels used for mouseover and for label
nodes$title <- nodes$id
nodes$label <- nodes$id
# nodes$size <- 30

#---- Edges
# Create list of edges by keeping the Subject and Predicate from query result.
edges<-rename(DMTriples, c("s" = "from", "o" = "to"))
# edges$arrows <- "to"
# edges$label <-"Edge"   # label : text always present
edges$title <- edges$p  # title: present when mouseover edge.
# edges$length <- 500

# Remove any rows that do not have a TO value since edges must be completed by a destination node
#edges<-edges[!(edges$to==""),]

# Visualize 
# Important options:
# visPhysics(enabled="FALSE")  - enable drag repositioning 
#visNetwork(nodes, edges,  width="1500px", height="1000px") %>%
   # visPhysics(enabled="TRUE") %>%
#    visNodes(font=list(size="20")) %>%
#    visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 0.5)),
#             smooth = list(enabled = TRUE, type = "cubicBezier", roundness=.8)
#            
#    )

# Possible Color Selections
# "#FFFFFF", // 1-Wht     
# "#00FF00", // 2-BrGre   
# "#99FF99", // 3-LtGre   
# "#FF0000", // 4-BrRed   
# "#FA7D7D", // 5-LtRed   
# "#0000FF", // 6-BrBlu   
# "#8080FF", // 7-LtBlu   
# "#FF6600", // 8-BrOr    
# "#FFB280", // 9-LtOr    
# "#CC00FF", // 10-BrPur  
# "#EB99FF", // 11-LtPur  
# "#FFFF00", // 12-BrYel  
# "#FFFF80", // 13-LtYel  
# "#006666", // 14-SlGre  
# "#99C2C2", // 15-LtSlGre 
# "#666699", // 16-BlGry  
# "#A3A3C2"  // 17-LtBlGr 

#TODO Add CLUSTERING. By colour? By x?  See docs
#   fix overlap so there is none
#  fix iterations/physics to get static right away. Try physics=FALSE
visNetwork(nodes, edges, width="1500px", height="1000px") %>%
    # visPhysics(solver = "forceAtlas2Based", forceAtlas2Based = list(gravitationalConstant = -10))%>%
    #centralGravity = 0.3
#    visPhysics(stabilization = TRUE, barnesHut = list(
#        gravitationalConstant = -1000,
#        avoidOverlap = 0.5,
#        centralGravity = .02,
#        springConstant = 0.002,
#        # stabilization = list(iterations=1),
#        stabilization = FALSE,
#        springLength = 100)) %>%
    visNodes(font=list(size="20"),
             borderWidth=1,
             physics=FALSE) %>%
    visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 0.5)),
             smooth = list(enabled = FALSE, type = "cubicBezier", roundness=.8)) %>%
    visGroups(groupname = "Person", color = "#feb24c") %>%
    visGroups(groupname = "SDTMTerm", color = "#99FF99")  %>%
    visGroups(groupname = "Study", color = "#A3A3C2")  %>%
    visGroups(groupname = "CDISCPilot", color = "#8080FF") %>%
    visGroups(groupname = "Literal", color = list(background="white", border="black"))



