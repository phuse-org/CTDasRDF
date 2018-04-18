###############################################################################
# FILE: compTriples-Stardog-Shiny.R
# DESC: Create a table of triples that differ from the Sujbect node to all 
#         attached predicates,objects (1 level only) 
# SRC : 
# IN  : prefixList.csv, Stardog Graphs
# OUT : ShinyApp window
# REQ : data uploaded to graphs Stardog: CTDasRDF,  CTDasRDFOnt
#       Prefixs file, IRI parsing function in Functions.R
# NOTE: Includes display of the triples available from both graphs
#         that do not match.
#   Full IRIs returned even if you specified PREFIX statements the query, so why 
#     note remove them from the query? They are needed to allow specification 
#     of different Subject nodes using their qnam and not full IRI  when 
#     validating different parts of the graph.
# TODO: 
#    Implement identifcation of "in one graph and not in the other "
# ERROR:
#  This query works fine in Stardog but not from the RShiny with this Subject node:
#  prefix cdiscpilot01: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#>
#  SELECT *
#  WHERE{
#    cdiscpilot01:StudyParticipationInterval_2013-12-26_2014-07-02T11%3A45  ?p ?o
#  } 
###############################################################################
library(plyr)    #  rename
library(dplyr)   # anti_join. MUst load dplyr AFTER plyr!!
library(reshape) #  melt
library(SPARQL)
library(shiny)

setwd("C:/_gitHub/CTDasRDF/r")
source("validation/Functions.R")

# Endpoints
epOnt = "http://localhost:5820/CTDasRDFOnt/query"
epDer = "http://localhost:5820/CTDasRDF/query"

# Read in the prefixes
prefixList <- read.csv(file="prefixList.csv", header=TRUE, sep=",")

# Create a combined prefix IRI column.
prefixList$prefix_ <- paste0("PREFIX ",prefixList$prefix, " ", prefixList$iri)

# Collapse into a single string
prefixBlock <- paste(prefixList$prefix_, collapse = "\n")

queryStart <- "SELECT ?p ?o "

ui <- fluidPage(
  titlePanel("Instance Data: Ontology vs SMS Derived"),
  fluidRow (
    column(6, textInput('rootNodeOnt', "Ontology Subject", value = "cdiscpilot01:Person_01-701-1015")),
    column(6, textInput('rootNodeDer', "Derived Subject",  value = "cdiscpilot01:Person_01-701-1015"))
  ),
  fluidRow(
    column(dataTableOutput('triplesTableOnt'), width=6)
    ,
    column(dataTableOutput('triplesTableDer'), width=6)
  ),
  # Section for identifying triples in one graph and not the other.   
  fluidRow(
    column(radioButtons("comp", "Compare:",
                c("In Ont, not in Der" = "inOntNotDer",
                  "In Der, not in Ont" = "inDerNotOnt")), width=4)
  ),
  fluidRow(
    column(h4("Comparison Result:",
    style= "color:#e60000"), width=5)
  ),
  fluidRow(
    column(dataTableOutput('triplesMiss'), width=6)
  )  
)

server <- function(input, output) {

  # Ontology Triples ----------------------------------------------------------   
      # QC of the query as a text render
        #output$queryCheckOnt <- renderText({
        #  paste0(prefixBlock, queryStart, "
        # WHERE {", input$rootNodeOnt," ?p ?o . } ORDER BY ?p ?o "
        # )      
        # })
    
  triplesOnt <- reactive({ 
    queryOnt = paste0(prefixBlock, queryStart, "
      WHERE {", input$rootNodeOnt," ?p ?o . } ORDER BY ?p ?o "
    )

    # Query results dfs ----  
    qrOnt <- SPARQL(url=epOnt, query=queryOnt)
    #--------------------
    triplesOnt <- qrOnt$results
    # shorten from IRI to qnam
    triplesOnt <- IRItoPrefix(sourceDF=triplesOnt, colsToParse=c("p", "o"))
    # Sort the dataframe values for display
    triplesOnt<-triplesOnt[with(triplesOnt, order(p, o)), ]
  })
  
  output$triplesTableOnt <-renderDataTable({triplesOnt()}, 
    options = list(paging=FALSE, scrollX = TRUE, searching=FALSE))    
  
  # Derived Triples -----------------------------------------------------------
  triplesDer <- reactive({ 
    # print(input$rootNodeDer)
    queryDer = paste0(prefixBlock, queryStart, "
      WHERE {", input$rootNodeDer," ?p ?o . } ORDER BY ?p ?o "
    )

    # Query results dfs ----  
    qrDer <- SPARQL(url=epDer, query=queryDer)
    #--------------------
    triplesDer <- qrDer$results
    # shorten from IRI to qnam
    triplesDer <- IRItoPrefix(sourceDF=triplesDer, colsToParse=c("p", "o"))
    # Sort the dataframe values for display
    triplesDer<-triplesDer[with(triplesDer, order(p, o)), ]
  })
  
  output$triplesTableDer <-renderDataTable({triplesDer()}, 
    options = list(paging=FALSE, scrollX = TRUE, searching=FALSE))    

 # Comparsion to find in one graph and not in the other
  compResult <- reactive({
    if (input$comp=='inDerNotOnt') {
      compResult <-anti_join(triplesDer(), triplesOnt())
    }
    else if (input$comp=='inOntNotDer') {
        compResult <- anti_join(triplesOnt(), triplesDer())
    }
  })
  
  output$triplesMiss <- renderDataTable({compResult()},
    options = list(paging=FALSE, scrollX = TRUE, searching=FALSE))    

  
} # End of server portion

shinyApp(ui = ui, server = server)