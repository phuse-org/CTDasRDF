###############################################################################
# FILE: compTriples-Shiny.R
# DESC: Create a table of triples that differ from an Object node to compare 
#         one TTL file with aonther.
#       Eg Usage: Compare TTL file generated from TopBraid with one created using R
# SRC : Based on VisClasses-Shiny.R and CompareTTL.R
# IN  : Browse to two .TTL files for comparison
# OUT : ShinyApp window
# REQ : rrdf
# NOTE: Includes display of the triples available from Ont,R, not just the ones
#         that do not match.
# TODO: 
#       
# 
###############################################################################
library(plyr)    #  rename
library(dplyr)   # anti_join. MUst load dplyr AFTER plyr!!
library(reshape) #  melt
library(rrdf)
library(shiny)
setwd("C:/_gitHub/SDTMasRDF/data/rdf")
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

        query = paste0("PREFIX cdiscpilot01: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/cdiscpilot01#>
PREFIX custom: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/custom#>
PREFIX code:  <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/code#>
prefix owl:   <http://www.w3.org/2002/07/owl#>
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX study:  <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/study#>
prefix time:  <http://www.w3.org/2006/time#>
SELECT ?s ?p ?o
WHERE {", input$qnam, " ?p ?o . 
  BIND(\"", input$qnam, "\" as ?s) } ")

       sourceR = load.rdf(paste(inFileR$datapath,".ttl",sep=""), format="N3")
       # Global assign for trouble shooting
       triplesR <<- as.data.frame(sparql.rdf(sourceR, query))
       
       sourceOnt = load.rdf(paste(inFileOnt$datapath,".ttl",sep=""), format="N3")
       triplesOnt <- as.data.frame(sparql.rdf(sourceOnt, query))
    
       # Remove cases where O is missing in the Ontology source(atrifact from TopBraid)
       triplesOnt <-triplesOnt[!(triplesOnt$o==""),]
       triplesOnt <<- triplesOnt[complete.cases(triplesOnt), ]
       if (input$comp=='inRNotOnt') {
           compResult <<-anti_join(triplesR, triplesOnt)
       }
       else if (input$comp=='inOntNotR') {
           compResult <- anti_join(triplesOnt, triplesR)
       }
       compResult
    })
    # sort for visual compare in the interface
    triplesOnt <- triplesOnt[with(triplesOnt, order(s,p,o)), ]
    triplesR <- triplesR[with(triplesR, order(s,p,o)), ]
    
    output$triplesOnt <-renderTable({triplesOnt})    
    output$triplesR <-renderTable({triplesR})    
}

ui <- fluidPage(
  titlePanel("Compare TTLs from R and Ontology "),
  fluidRow (
      column(4, fileInput('fileOnt', 'TTL from Ont <filename>.TTL')),
      column(4, fileInput('fileR',   'TTL from R   <filename>-R.TTL')
      ),
      column(3, textInput('qnam', "Subject QName", value = "cdiscpilot01:Person_1"))
  ),
  radioButtons("comp", "Compare:",
                c("In R, not in Ontology" = "inRNotOnt",
                  "In Ontology, not in R" = "inOntNotR")),    
  h4("Comparison Result:"),
  hr(),    
  tableOutput('contents'), 
  h4("Ontology Triples"),
  tableOutput('triplesOnt'),
  h4("R Triples"),
  tableOutput('triplesR')
    
)
shinyApp(ui = ui, server = server)

