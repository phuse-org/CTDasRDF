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
# TODO: Move prefixes specification to an external file.
#    ERROR: Display of triplesOnt, triplesR is NOT reactive     
# 
###############################################################################
library(plyr)    #  rename
library(dplyr)   # anti_join. MUst load dplyr AFTER plyr!!
library(reshape) #  melt
library(rrdf)
library(shiny)

# setwd("C:/_gitHub/CTDasRDF/data/rdf")
setwd("C:/_github/CTDasRDF")
allPrefix <- "data/config/prefixes.csv"  # List of prefixes

# Read list of prefixes from the config file ----
prefixes <- as.data.frame( read.csv(allPrefix,
  header=T,
  sep=',' ,
  strip.white=TRUE))
# Create individual PREFIX statements
prefixes$prefixDef <- paste0("PREFIX ", prefixes$prefix, ": <", prefixes$namespace,">")
 
server <- function(input, output) {
  output$contents <- renderTable({ 
    query = paste0(paste(prefixes$prefixDef, collapse=""),
      "SELECT ?s ?p ?o
        WHERE {", input$qnam, " ?p ?o . 
        BIND(\"", input$qnam, "\" as ?s) }
        ORDER BY ?p ?o")

    # sourceR = load.rdf(paste(inFileR$datapath,".ttl",sep=""), format="N3")
    sourceR = load.rdf("data/rdf/cdiscpilot01-R.TTL", format="N3")
    # Global assign for trouble shooting
    triplesR <<- as.data.frame(sparql.rdf(sourceR, query))
       
    # sourceOnt = load.rdf(paste(inFileOnt$datapath,".ttl",sep=""), format="N3")
    sourceOnt = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")
    triplesOnt <- as.data.frame(sparql.rdf(sourceOnt, query))
    
    # Remove cases where O is missing in the Ontology source(atrifact from TopBraid)
    triplesOnt <-triplesOnt[!(triplesOnt$o==""),]
    triplesOnt <<- triplesOnt[complete.cases(triplesOnt), ]
    if (input$comp=='inRNotOnt') {
      compResult <<-anti_join(triplesR, triplesOnt)
    }else if (input$comp=='inOntNotR') {
      compResult <- anti_join(triplesOnt, triplesR)
    }
  
    triplesOnt <- triplesOnt[with(triplesOnt, order(s,p,o)), ]
    triplesR   <- triplesR[with(triplesR, order(s,p,o)), ]
       
    output$triplesOnt <-renderTable({triplesOnt})    
    output$triplesR <-renderTable({triplesR})    

    compResult
  })
  # sort for visual compare in the interface
  output$triplesOnt <- renderTable({triplesOnt})    
  output$triplesR   <- renderTable({triplesR})    
}

ui <- fluidPage(
  titlePanel(HTML("<h3>Compare cdiscpilot01.TTL (ont) with cdiscpilot01-R.TTL (from R)</h3>")),
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
  h4("Ontology Triples",
    style= "color:#000099"),
  tableOutput('triplesOnt'),
  h4("R Triples",
    style= "color:#00802b"),
  tableOutput('triplesR')
)
shinyApp(ui = ui, server = server)

