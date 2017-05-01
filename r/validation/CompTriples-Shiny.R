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
library(dplyr)   # anti_join. MUst load dplyr AFTER plyr!!
library(reshape) #  melt
library(rrdf)
library(shiny)

server <- function(input, output) {
    output$contents <- renderTable({ 
    inFileR <<- input$fileR
    inFileOnt <<- input$fileOnt
    # Do not do anything until both FileR and FileOnt have been specified.
    if(is.null(inFileR) | is.null(inFileOnt) )
      return(NULL)

    #TODO Confirm these two steps
    file.rename(inFileR$datapath,
               paste(inFileR$datapath, ".ttl", sep=""))
    file.rename(inFileOnt$datapath,
               paste(inFileOnt$datapath, ".ttl", sep=""))
    
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
   sourceR = load.rdf(paste(inFileR$datapath,".ttl",sep=""), format="N3")
   # Global assign for trouble shooting
   triplesR <<- as.data.frame(sparql.rdf(sourceR, query))
   
   sourceOnt = load.rdf(paste(inFileOnt$datapath,".ttl",sep=""), format="N3")
   triplesOnt <<- as.data.frame(sparql.rdf(sourceOnt, query))

   if (input$comp=='inRNotOnt') {

       compResult <<-anti_join(triplesR, triplesOnt)
   }
   else if (input$comp=='inOntNotR') {
       compResult <<- anti_join(triplesOnt, triplesR)
   }
   compResult
    })
    
#TESTING    
   
    
}

ui <- fluidPage(
  titlePanel("Compare TTLs from R and Ontology "),
  fluidRow (
      column(4, fileInput('fileR', 'TTL from R')),
      column(4, fileInput('fileOnt', 'TTL from Ont')
      ),
      column(3, textInput('qnam', "Subject QName"))
  ),
  radioButtons("comp", "Compare:",
                c("In R, not in Ontology" = "inRNotOnt",
                  "In Ontology, not in R" = "inOntNotR")),    
  tableOutput('contents')
)
shinyApp(ui = ui, server = server)

