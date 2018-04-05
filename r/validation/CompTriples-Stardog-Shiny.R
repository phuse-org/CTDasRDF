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
#   
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

ui <- fluidPage(
  titlePanel("Compare TTLs from R and Ontology "),
  fluidRow (
      column(5, textInput('rootNodeOnt', "Ontology Subject", value = "cdiscpilot01:Person_1")),
      column(5, textInput('rootNodeDer', "Derived Subject", value = "cdiscpilot01:Person_01-701-1015"))
  ),
#  fluidRow (
#      column(12, textInput('rootNodeDer', "Subject QName", value = "cdiscpilot01:Person_01-701-1015"))
#  ),
  
#  radioButtons("comp", "Compare:",
#                c("In Der, not in Ont" = "inDerNotOnt",
#                  "In Ont, not in Der" = "inOntNotDer")),    
#  h4("Comparison Result:",
#    style= "color:#e60000"),
#  hr(),    
#  tableOutput('contents')
#  , 
    # QC CHECK of the query
    #fluidRow (
    #  column(12, textOutput("queryCheckOnt"))
    #),
  
    fluidRow(
      column(dataTableOutput('triplesTable'), width=6)
      #,
      # column(textOutput("queryCheckOnt"), width=6)
      )
  

  #  ,
#  h4("R Triples",
#    style= "color:#00802b"),
#  tableOutput('triplesR')
    
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
  
  #  
  output$triplesTable <-renderDataTable({triplesOnt()}, 
    options = list(scrollX = TRUE))    
  
  # Derived Triples -----------------------------------------------------------
  triplesDer <- reactive({ 
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
  
  output$triplesTable <-renderDataTable({triplesDer()}, 
    options = list(scrollX = TRUE))    

} # End of server portion



shinyApp(ui = ui, server = server)