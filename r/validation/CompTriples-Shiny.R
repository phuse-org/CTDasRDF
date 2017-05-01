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

server <- function(input, output) {
    output$contents <- renderTable({ 
    inFile1 <<- input$file1
    inFile2 <<- input$file2
    # Do not do anything until both File1 and File2 have been specified.
    if(is.null(inFile1) | is.null(inFile2) )
      return(NULL)

    #TODO Confirm these two steps
    file.rename(inFile1$datapath,
               paste(inFile1$datapath, ".ttl", sep=""))
    file.rename(inFile2$datapath,
               paste(inFile2$datapath, ".ttl", sep=""))
    
   query = 'PREFIX cdiscpilot01: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/cdiscpilot01#>
PREFIX custom: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/custom#>
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX study:  <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/study#>

SELECT ?s ?p ?o
WHERE { cdiscpilot01:Person_1 ?p ?o . 
  BIND("cdiscpilot01:Person_1" as ?s)
}'
   sourceA = load.rdf(paste(inFile1$datapath,".ttl",sep=""), format="N3")
   # Global assign for trouble shooting
   triplesA <<- as.data.frame(sparql.rdf(sourceA, query))
   
   sourceB = load.rdf(paste(inFile2$datapath,".ttl",sep=""), format="N3")
   triplesB <<- as.data.frame(sparql.rdf(sourceB, query))

   inANotB<<-anti_join(triplesA, triplesB)
   inBNotA<<-anti_join(triplesB, triplesA)
   
   # output$inANotB <- renderTable({inANotB})
   inANotB
   # TO ADD
   # output$inBNotA <- renderTable({inBNotA})
    })
}

ui <- fluidPage(
  fileInput('file1', 'Choose TTL File A'),
  fileInput('file2', 'File B'),
  # visNetworkOutput("network",height = "500px"),
  # textOutput('text1'),
  tableOutput('contents')
)
shinyApp(ui = ui, server = server)

