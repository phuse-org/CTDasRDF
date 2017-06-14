###############################################################################
# FILE: Person-MultLevel-VisNetwork-ForceNetwork.R
# DESC: Visualization of the nodes connected to Person_1 as a FN graph
# SRC : 
# DOCS:  https://cran.r-project.org/web/packages/visNetwork/visNetwork.pdf 
#
# IN  : cdiscpilot01.TTL  (OR) local endpoint graph
# OUT : 
# REQ :
# SRC :
# NOTE: 
# TODO: 
#        
###############################################################################
library(plyr)     #  rename
library(reshape)  #  melt
library(rrdf)
library(visNetwork)

# Select all the information associated with Person_1
#   Note the use of prefix x: to traverse the graph out from Person_1 node
query = 'PREFIX CDISCPILOT01: <https://github.com/phuse-org/CTDasRDF/blob/master/data/rdf/cdiscpilot01#> 
PREFIX study: <https://github.com/phuse-org/CTDasRDF/blob/master/data/rdf/study#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sdtm-terminology: <https://github.com/phuse-org/CTDasRDF/blob/master/data/rdf/sdtm-terminology#>
PREFIX code:  <https://github.com/phuse-org/CTDasRDF/blob/master/data/rdf/code#>
PREFIX custom: <https://github.com/phuse-org/CTDasRDF/blob/master/data/rdf/custom#>
prefix time:  <http://www.w3.org/2006/time#>
prefix country: <http://psi.oasis-open.org/iso/3166#>
prefix x: <http://example.org/bogus>

SELECT ?s ?p ?o 
FROM <http://localhost:8890/SDTMTORDF>
where { CDISCPILOT01:Person_1 (x:foo|!x:bar)* ?s . 
?s ?p ?o . 
}'

# Two options: Can use either a SPARQL endpoint (Triplestore) or TTL file.
#-- A. Endpoint 
#rdfSource = "http://localhost:8890/sparql"  # local EP
#DMTriples = as.data.frame(sparql.remote(rdfSource, query))  # for local EP

#-- B. TTL file
setwd("C:/_gitHub/CTDasRDF")
rdfSource = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")

DMTriples = as.data.frame(sparql.rdf(rdfSource, query))

# Remove any rows that have a blank Object. 
DMTriples<-DMTriples[!(DMTriples$o==""),]

# Remove duplicates from the query
DMTriples <- DMTriples[!duplicated(DMTriples),]

#---- Nodes Construction
# Unique list of nodes by combine Subject and Object into a single column
#   "id.vars" is the list of columns to keep untouched. The unamed ones (s,o) are 
#   melt into the "value" column.
nodeList <- melt(DMTriples, id.vars=c("p" ))

# A node can be both Subject and Object. Ensure a unique list of node names
#   by dropping duplicate values.
nodeList <- nodeList[!duplicated(nodeList$value),]

# Rename to ID for use in visNetwork and keep only that column
nodeList <- rename(nodeList, c("value" = "id" ))
nodes<- as.data.frame(nodeList[c("id")])

# Assign groups used for icon types and colours
# Order is important.
nodes$group[grepl("sdtm-terminology", nodes$id, perl=TRUE)] <- "SDTMTerm"  
nodes$group[grepl("study", nodes$id, perl=TRUE)] <- "Study"  
nodes$group[grepl("code", nodes$id, perl=TRUE)] <- "Code"  
nodes$group[grepl("custom", nodes$id, perl=TRUE)] <- "Custom"  
nodes$group[grepl("CDISCPILOT01", nodes$id, perl=TRUE)] <- "CDISCPilot"  
nodes$group[grepl("Person_", nodes$id, perl=TRUE)] <- "Person"  
nodes$group[! grepl(":", nodes$id, perl=TRUE)] <- "Literal"
nodes$group[ grepl("T\\d+:\\d+", nodes$id, perl=TRUE)] <- "Literal"# Time values
nodes$group[ grepl("rdfs:", nodes$id, perl=TRUE)] <- "Rdf"
# temporary kludge that fails if a literal has a colon. Close enough for development.
nodes$shape <- ifelse(grepl(":", nodes$id), "ellipse", "box")

# Assign labels used for mouseover and for label
nodes$title <- nodes$id
nodes$label <- gsub("\\S+:", "", nodes$id)

#---- Edges
# Create list of edges by keeping the Subject and Predicate from query result.
edges<-rename(DMTriples, c("s" = "from", "o" = "to"))

# Edge values
#   use edges$label for values always present
#   use edges$title for values only present on mouseover
edges$title <-gsub("\\S+:", "", edges$p)   # label : text always present

# Graph selectible by ID or Group. 
visNetwork(nodes, edges, height = "500px", width = "100%") %>%
  visOptions(selectedBy = "group", 
             highlightNearest = TRUE, 
             nodesIdSelection = TRUE) %>%
    visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 0.5)),
             smooth = list(enabled = FALSE, type = "cubicBezier", roundness=.8)) %>%
    visGroups(groupname = "Person",    color = "#ffff33") %>%
    visGroups(groupname = "SDTMTerm",  color = "#99FF99") %>%
    visGroups(groupname = "Study",     color = "#A3A3C2") %>%
    visGroups(groupname = "Code",      color = "#99C2C2") %>%
    visGroups(groupname = "Custom",    color = "#FFB280") %>%
    visGroups(groupname = "CDISCPilot",color = "#8080FF") %>%
    visGroups(groupname = "Rdf",       color = "#c68c53") %>%
    visGroups(groupname = "Literal",   color = list(background="white", border="black")) %>%
    #  Higher damping = less motion between interations
    visPhysics(stabilization=FALSE, barnesHut = list(
                                       avoidOverlap=1,
                                       gravitationalConstant = -3000,
                                       springConstant = 0.0004,
                                       damping = 0.9,
                                       springLength = 40
                                       ))  