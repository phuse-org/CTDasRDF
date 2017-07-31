###############################################################################
# FILE: compTriples-Shiny.R
# DESC: Create a table of triples that differ for Pred,Obj to compare one 
#         TTL file with aonther.
#       Eg Usage: Compare TTL file generated from TopBraid with one created using R
# SRC : Based on VisClasses-Shiny.R and CompareTTL.R
# IN  : Hard coded input files to save time during QC
# OUT : ShinyApp window
# REQ : rrdf
# NOTE: Side by side display of the triples available from Ont,R, not just the ones
#         that do not match.
# TODO: 
###############################################################################
library(plyr)    #  rename
library(dplyr)   # anti_join. MUst load dplyr AFTER plyr!!
library(reshape) #  melt
library(rrdf)
library(shiny)

# setwd("C:/_gitHub/CTDasRDF/data/rdf")
setwd("C:/_github/CTDasRDF")
allPrefix <- "data/config/prefixes.csv"  # List of prefixes

# Prefixes from config file ----
prefixes <- as.data.frame( read.csv(allPrefix,
  header=T,
  sep=',' ,
  strip.white=TRUE))
# Create individual PREFIX statements
prefixes$prefixDef <- paste0("PREFIX ", prefixes$prefix, ": <", prefixes$namespace,">")
 
# S not needed, removed from query: BIND(\"", input$qnam, "\" as ?s) }
server <- function(input, output) {
  output$contents <- renderTable({ 
    query = paste0(paste(prefixes$prefixDef, collapse=""),
      "SELECT ?p ?o
        WHERE {", input$qnam, " ?p ?o .} 
        ORDER BY ?p ?o")

    # sourceR = load.rdf(paste(inFileR$datapath,".ttl",sep=""), format="N3")
    sourceR = load.rdf("data/rdf/cdiscpilot01-R.TTL", format="N3")
    triplesR <- as.data.frame(sparql.rdf(sourceR, query))
       
    # sourceOnt = load.rdf(paste(inFileOnt$datapath,".ttl",sep=""), format="N3")
    sourceOnt = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")
    triplesOnt <- as.data.frame(sparql.rdf(sourceOnt, query))
    
    # Remove cases where O is missing in the Ontology source(atrifact from TopBraid)
    triplesOnt <-triplesOnt[!(triplesOnt$o==""),]
    triplesOnt <<- triplesOnt[complete.cases(triplesOnt), ]

    if (input$comp=='inRNotOnt') {
      compResult <-anti_join(triplesR, triplesOnt)
      
      
    }else if (input$comp=='inOntNotR') {
      compResult <- anti_join(triplesOnt, triplesR)
      
    }
    triplesOnt <- triplesOnt[with(triplesOnt, order(p,o)), ]
    triplesR   <- triplesR[with(triplesR, order(p,o)), ]
       
    output$triplesOnt <-renderTable({triplesOnt})    
    output$triplesR <-renderTable({triplesR})    

    if(nrow(compResult) == 0){
    compResult <- "100% MATCH"
    }else{
      compResult[with(compResult, order(p,o)), ]
    }

  })
  # sort for visual compare in the interface
  output$triplesOnt <- renderTable({triplesOnt})    
  output$triplesR   <- renderTable({triplesR})    
}

ui <- fluidPage(
  titlePanel(HTML("<h3>Compare cdiscpilot01.TTL (Ont) with cdiscpilot01-R.TTL (from R)</h3>")),
  fluidRow (
    #column(4, fileInput('fileOnt', 'TTL from Ont <filename>.TTL')),
    #column(4, fileInput('fileR',   'TTL from R   <filename>-R.TTL')
    #),
    column(3, textInput('qnam', "Subject QName", value = "cdiscpilot01:Person_1"))
  ),
  radioButtons("comp", "Compare:",
    c( "In R, not in Ontology" = "inRNotOnt",
       "In Ontology, not in R" = "inOntNotR")),    
  h4("Comparison Result:",
    style= "color:#e60000"),
  hr(),  
    tableOutput('contents'), 
  fluidRow(
    column(6,
      h4("Ont Pred,Obj",
        style= "color:#000099"),
        # tableOutput('triplesOnt')),
        div(tableOutput("triplesOnt"), style = "font-size:80%")),
    column(6,
      h4("R Pred,Obj",
      style= "color:#00802b"),
      div(tableOutput("triplesR"), style = "font-size:80%"))
      #tableOutput('triplesR'))
  )
)
shinyApp(ui = ui, server = server)