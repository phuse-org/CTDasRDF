###############################################################################
# FILE: compTriples-Shiny.R
# DESC: Create a table of triples that differ from an Object node to compare 
#         one TTL file with aonther.
#       Eg Usage: Compare TTL file generated from TopBraid with one created using R
# SRC : Based on VisClasses-Shiny.R and CompareTTL.R
# IN  : Browse to two .TTL files for comparison
# OUT : ShinyApp window
# REQ : rrdf
# NOTE: 
# TODO: **** Add display of second dataframe: InBNotA
#       * Add label above dataframe display
#       * Position A/B file section side-by-side
#       ***** Add intial selection of the parent Object & consturct that query
#         on the fly. paste0 of the parameter. do not execute until that param
#         is present (add to the null determination?) and refire every time
#         that value changes.    
#       * add code from Compare.TTL to remove definition, skos:note, etc. from comparison
# 
###############################################################################
library(plyr)    #  rename
library(reshape) #  melt
library(rrdf)
library(shiny)


# Load both source files 
#    inFile1 <<- input$file1
#    inFile2 <<- input$file2
    #TODO Confirm these two steps
#    file.rename(inFile1$datapath,
#               paste(inFile1$datapath, ".ttl", sep=""))
#    file.rename(inFile2$datapath,
#               paste(inFile2$datapath, ".ttl", sep=""))
#   sourceA = load.rdf(paste(inFile1$datapath,".ttl",sep=""), format="N3")
#   sourceB = load.rdf(paste(inFile2$datapath,".ttl",sep=""), format="N3")



server <- function(input, output) {
 
    query <- reactive({


        qPt1 <- 'PREFIX cdiscpilot01: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/cdiscpilot01#>
PREFIX custom: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/custom#>
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX stuy:  <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/study#>
SELECT ?s ?p ?o '
   
    qPt2 <- paste0("WHERE { ", input$startTriple, " ?p ?o ." ,
       "BIND('", input$startTriple, "' as ?s  }")  

    query <- paste0(qPt1, qPt2)   
    })
    
   # Global assign for trouble shooting
   # triplesTW <<- as.data.frame(sparql.rdf(sourceA, query))
   
#   triplesAO <<- as.data.frame(sparql.rdf(sourceB, query))

#   inANotB<<-anti_join(triplesTW, triplesAO)
#   inBNotA<<-anti_join(triplesAO, triplesTW)
   
   # output$inANotB <- renderTable({inANotB})
#   inANotB
   # TO ADD
   # output$inBNotA <- renderTable({inBNotA})
#    })
# query <-input$startTriple
# output$query <- renderText(paste0(input$startTriple))    

    # Note use of query(), not query.
    output$query <- renderText(query())    
}

#------------------------------------------------------------------------------
# UI 
#------------------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("SPARQL query"),
  fluidRow(
      textInput("startTriple", label = h4("Parent Triple"), value="cdiscpilot01:Person_1")
  ),
  fluidRow(
      h3(textOutput('query', container = span))    
  )
  
  # textOutput('query'),
  # tableOutput('contents')
)


shinyApp(ui = ui, server = server)

