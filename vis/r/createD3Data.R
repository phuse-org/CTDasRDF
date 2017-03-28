###############################################################################
# -----------------------------------------------------------------------------
# FILE : PhUSE/Annual/2016/Paper/code/createD3Data.R
# DESCR: Create intermediate data files for use in D3js graphs
# SRC  : Eg: JSON for Attendees-FNGraph.HTML, .csv for 
# REF  : http://nicolewhite.github.io/2015/06/18/visualize-your-graph-with-rneo4j-and-visNetwork.html
# KEYS : 
# NOTES: visNetwork docs and examples:
#        http://dataknowledge.github.io/visNetwork/
#        For D3js, node ID must start at 0 and progress from there.
#            use the original NEO4j IDs to merge the generated ID in the NODES dataset into the 
#            EDGES dataframe, then use the generated ID's  for the from and to in the JSON.\
#            Change node creation to use NEo4j node ID instead of generating them in this code.
#            Create the Edges dataframe from the GRAPH dataframe, after IDs are available.
#    
# INPUT: Neo4j running at database location:
#           C:/_gitWorkArea/PhUSE/Annual/2016/Paper/data/neo4j
#        
# OUT  : Attendees-FNGraph-R.JSON  
#        AttendeeSankey.csv
#        Attendee-World.JSON   - to AttendeesByCountry-WorldMap.html
# REQ  : 1. Neo4j Running at database: C:/_gitWorkArea/PhUSE/Annual/2016/Paper/data/neo4j
#        
#        
# TODO :   1. Update node_query to include OPtional presentations for each person. Similar to 
#           the person-presentation query
#
#
#!!!!! PROBLEM: people  with more than one pres are counted for each pres in 
#                     the number of people from each country!!
#        Eg: people  from UK: 149 ,  R shows 154 due to mult publications from same auths
#        Consider two separate queries: 1 for the people,Org,Country. Another for the
#            pres and stream. then join based on person->contrib to?
#
###############################################################################
library(RNeo4j)
library(visNetwork)
library(plyr)
library(jsonlite)
# Neo4j running.
graph = startGraph("http://localhost:7474/db/data/")

#---- NODES -------------------------------------------------------------------
# CHANGE THE Query to get the NEO4j ID value for each node in the query:
# ID(org) as orgID
# ID(Person) as personID
# ID(Country) as countryID
# ID(Presentaton) as presentationID
# ID(Stream) as streamID
#  - THEN USE THESE AS THE NODE ID VALUES TO CONSTRUCT the TO:, FROM: JSON sections.
#   ALSO use this id instead of generating one here in the R Code.
# !!!! NEED OPTIONAL MATCH. THIS IS ONLY PULLING PRESENTERS
# COUNTRY  FN GRAPH         NEO4j Count:
# United Kingdom   46   149
# Germany          12   79

# Create neo4j query
#     NOTE: duplicates person nodes for multiple pubications!

#---- Node Counts
#  Get a frequency of node codes used to size the nodes in display:
#  Person       : number of person nodes
#  Organization : number of Person from that Org.
#  Country      : number of Person from that Country
#  Presentation : number of Person contrib to that Pres
#  Stream       : number of Persentations in that Stream
#     - later merge these counts back into the data frame using the Neo4j node id
node_query = "
MATCH (p:Person)-[:FROM]->(c:Country) 
RETURN ID(c) AS neoID, 'Country' AS type, c.name AS label, count(*) AS freq
UNION ALL
// Persons from Organization
MATCH (p:Person)-[:WORKS_AT]->(o:Organization) 
RETURN ID(o) AS neoID, 'Organization' AS type, o.name AS label, count(*) AS freq
UNION ALL
// Persons in Presentation
MATCH (p:Person)-[:CONTRIB_TO]->(pres:Presentation) 
RETURN ID(pres) AS neoID, 'Presentation' AS type, pres.title AS label, count(*) AS freq
UNION ALL
// Presentations in Stream
MATCH (p:Presentation)-[:IN_STREAM]->(s:Stream) 
RETURN ID(s) AS neoID, 'Stream' AS type, s.name AS label, count(*) AS freq
UNION ALL
// NEW section for person to workshop.  
MATCH (p:Person)-[:ATTENDS]->(opt:Option) 
RETURN ID(opt) AS neoID, 'Option' AS type, opt.title AS label, count(*) AS freq
UNION ALL
// Persons
//     QC that all have a freq = 1
MATCH (p:Person)
RETURN ID(p) as neoID, 'Person' AS type, p.firstName + ' ' + p.lastName AS label, count(*) as freq
"
nodes = cypher(graph, node_query)


# Create the node ID values starting at 0 as req. by D3JS
nodes$nodeID<-0:(nrow(nodes)-1)   # Generate a list of ID numbers

# Dataframe for laterhttp://www.mgexp.com/phorum/read.php?1,865405coding the EDGES neoID to the d3js node value
nodesDecode<-nodes[, c('nodeID', 'neoID')]

#---- EDGES -------------------------------------------------------------------
edge_query = "
MATCH (f)-[r]->(t)
RETURN ID(f) as neoSource,
ID(t) as neoTarget,
TYPE(r) AS type 
//LIMIT 20
"

edges = cypher(graph, edge_query)


# Recode  source ID
edges <- merge (edges, nodesDecode, by.x='neoSource', by.y='neoID')
edges <- rename(edges, c('nodeID' = 'source'))


# Recode  target ID
edges <- merge (edges, nodesDecode, by.x='neoTarget', by.y='neoID')
edges <- rename(edges, c('nodeID' = 'target'))

# Tidy by remove neo node identifiers

edges <-edges[, c('source', 'target', 'type')]

all <- list(nodes=nodes,
            edges=edges)

fileConn<-file("C:/_gitWorkArea/d3/PhUSE/Annual/2016/data/Attendees-FNGraph-R.JSON")
# Write out to JSON
writeLines(toJSON(all, pretty=TRUE), fileConn)
close(fileConn)

#------------------------------------------------------------------------------
#    PART 2
#    Create JSON file for Attendees world map
#    Originally from AttendeesAndPapers.R
#------------------------------------------------------------------------------
country_query = "
MATCH (p:Person)-[:FROM]->(c:Country) 
RETURN c.code as ISO, count(*) AS Freq
"

countryFreq = cypher(graph, country_query)

fileConn<-file("C:/_gitWorkArea/d3/PhUSE/Annual/2016/data/Attendee-World.JSON")
# Write out to JSON
writeLines(toJSON(countryFreq, pretty=TRUE), fileConn)
close(fileConn)


#------------------------------------------------------------------------------
#    PART 3
#    Create .CSV file for Sankey Graph
#    Originally from AttendeeSankey-CSVCreate.R
#------------------------------------------------------------------------------
graph = startGraph("http://localhost:7474/db/data/")

graph_query = "
MATCH  (org)-[:WORKS_AT]-(Person)-[:FROM]-(Country)
RETURN Person.firstName AS firstName,
    Person.lastName AS lastName,
    org.name as company,
    Country.name as Country
"
attendees = cypher(graph, graph_query)

# source, target, value, url
#--COUNTRY --> PHUSE conference
country <-count(attendees, c("Country"))
country <- rename(country, c('Country' = 'source',
                             'freq' = 'value'))
country$target <- 'PhUSE2016'  # Target for all countries is PhUSE216 node

#--COMPANY --> COUNTRY
# If a COMPANY has fewer than 3 attendees total (across all countries)
# then recode that company name to "Other"
# 5. re-count so "Other" is collapsed into a single count category

# 1. Calculate total attendess for that company across all the companies countries.
company <-count(attendees, c("company"))

# 2. Flag if the country has < 3 attendees total. 
#    These companies will be recoded to company name 'Other'
#    Note use of as.character in the comparison, else get level sets error.
company$LTCountFlag <- ifelse(company$freq < 5, '1', '0') 
# keep only the company name and flag for merging back into the original data
companyFlag <- company[c("company", "LTCountFlag")]
#TW NO!  MERGE BACK INTO ATTENDEES SO NO RENAME!! companyFlag <- rename(companyFlag, c("company" = "source"))

# 3. Merge the flag back nto the  source data using plyr's JOIN
companyCountry <- join(attendees, companyFlag, by="company")


# 4. Change name to 'Other' where flagged 
companyCountry$company[companyCountry$LTCountFlag == "1"] <- "Other"

# Addtional recoding: Shorten the remaining names for the display
companyCountry$company[companyCountry$company == "Mundipharma"] <- "Mundi"
companyCountry$company[companyCountry$company == "Boehringer Ingelheim"] <- "B.I."
companyCountry$company[companyCountry$company == "Business & Decision Life Sciences"] <- "B&D"
companyCountry$company[companyCountry$company == "Chrestos Concept GmbH & Co. KG"] <- "Chrestos"
companyCountry$company[companyCountry$company == "GCE Solutions"] <- "GCE"
companyCountry$company[companyCountry$company == "inVentiv Health"] <- "inVentiv"
companyCountry$company[companyCountry$company == "Larix A/S"] <- "Larix"
companyCountry$company[companyCountry$company == "OCS Consulting"] <- "OCS"
companyCountry$company[companyCountry$company == "SAS Institute"] <- "SAS"
companyCountry$company[companyCountry$company == "SGS Life Sciences"] <- "SGS"
companyCountry$company[companyCountry$company == "UCB Biosciences"] <- "UCB"
companyCountry$company[companyCountry$company == "Novo Nordisk"] <- "N.Nordisk"
companyCountry$company[companyCountry$company == "PRA Health Sciences"] <- "PRA HS"

companyCountry <- count(companyCountry, c("Country", "company"))


companyCountry <- rename(companyCountry, 
                         c('company' = 'source',
                           'Country' = 'target',
                           'freq' = 'value'))

forSankey <- rbind(companyCountry,country)
forsankey <- forSankey[c("source", "target", "value")]


write.csv(forSankey, file="C:/_gitWorkArea/d3/PhUSE/Annual/2016/data/AttendeeSankey.csv")
