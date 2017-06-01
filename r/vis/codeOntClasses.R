###############################################################################
# FILE: codeOntClasses.R
# DESC: 
# SRC : code.ttl - file created by AO
# IN  : 
# OUT : 
# REQ : code.ttl, customterminology.TTL uploaded to local Virtuoso Endpoint graph 'CTDasRDF'
# SRC :  
# NOTE: THe first filter selects only direct subclasses as desdribed here:
#        https://stackoverflow.com/questions/23699246/how-to-query-for-all-direct-subclasses-in-sparql
#       ?Relation is needed for the Melt
# TODO: 
###############################################################################
library(rrdf)
library(plyr)
library(dplyr)
setwd("C:/_github/SDTMasRDF/data/rdf")
# codeData = load.rdf("code.TTL", format="N3")
endpoint = "http://localhost:8890/sparql"


query = 'PREFIX code: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/code#> 
PREFIX custom: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/custom#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX sdtm-terminology: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/sdtm-terminology#> 
PREFIX time: <http://www.w3.org/2006/time#> 
PREFIX time: <http://www.w3.org/2006/time#> 
SELECT ?Parent ?Child ?Relation
FROM <http://localhost:8890/CTDasRDF>
WHERE
 {
    ?Child rdfs:subClassOf ?Parent
   # FILTER(REGEX(STR(?Parent), "code"))  
   FILTER(!(REGEX(STR(?Parent), "spin")))
   BIND ("hasChild" AS ?Relation)
}
ORDER BY ?Parent
'
classes = data.frame(sparql.remote(endpoint, query))

tree <- FromDataFrameNetwork(classes)
df <- ToDataFrameTypeCol(tree)
df <- data.frame(df)

# need to now remove those unnecessary "."s
collapsibleTree(df, colnames(df)[2:5])



#DEL DELETE BELOW HERE
#---- Nodes Construction
# Unique list of nodes by combine Subject and Object into a single column
#   "id.vars" is the list of columns to keep untouched. The unamed ones (parent,child)  
#   melt into the "value" column.
nodeList <- melt(classes, id.vars=c("Relation" ))

# A node can be both Subject and Object. Ensure a unique list of node names
#   by dropping duplicate values.
nodeList <- nodeList[!duplicated(nodeList$value),]

# Rename to ID for use in visNetwork and keep only that column
nodeList <- rename(nodeList, c("value" = "id" ))
nodes<- as.data.frame(nodeList[c("id")])

#OPTIONAL
# Assign groups used for icon types and colours
# Order is important.
#nodes$group[grepl("sdtm-terminology", nodes$id, perl=TRUE)] <- "SDTMTerm"  
#nodes$group[grepl("study", nodes$id, perl=TRUE)] <- "Study"  

#---- Edges
# Create list of edges by keeping the Subject and Predicate from query result.
# edges<-rename(classes, c("parent" = "from", "child" = "to"))

# Not implemented....
# Edge values
#   use edges$label for values always present
#   use edges$title for values only present on mouseover
# edges$title <-gsub("\\S+:", "", edges$p)   # label : text always present





