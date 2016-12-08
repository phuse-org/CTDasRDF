###############################################################################
# FILE : 
# DESCR: 
# SRC  : 
# KEYS : 
# NOTES: 
#        
# INPUT: 
#      : 
# OUT  : 
# REQ  : 
# TODO : 
###############################################################################
library(rrdf)
library(plyr)  # for rename
library(visNetwork)

endpoint = "http://localhost:8890/sparql"
# Select all the information associated with Obs113
query = 'PREFIX p: <http://www.example.org/PharmaCo/cdiscpilot01/> 
    PREFIX x: <example.org/foo/>
    SELECT ?s ?p ?o 
FROM <http://localhost:8890/SDTMTORDF>
    where { p:Person_1 (x:foo|!x:bar)* ?s . 
        ?s ?p ?o . 
}'

DMTriples = as.data.frame(sparql.remote(endpoint, query))
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

#---- Edges
# Create list of edges by keeping the Subject and Predicate from query result.
edges<-rename(DMTriples, c("s" = "from", "o" = "to"))


visNetwork(nodes, edges, width= "100%")
