###############################################################################
# FILE: CollapsibleTree-Shiny.R
# DESC: Collapsible node tree to compare ontology and derived nodes
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: Early dev with bogus data
#       Notes on Shiny bindings
#       https://www.rdocumentation.org/packages/collapsibleTree/versions/0.1.5/topics/collapsibleTree-shiny
# TODO: 
###############################################################################
library(SPARQL)
library(shiny)
library(collapsibleTree)
library(DT)

# Endpoints
epDer = "http://localhost:5820/CTDasRDF/query"
epOnt = "http://localhost:5820/CTDasRDFOnt/query"

# Define the namespaces
namespaces <- c('cd01p', '<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01-protocol.ttl#>',
'cdiscpilot01', '<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#>',
'code', '<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/code.ttl#>',
'custom', '<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/custom#>',
'sdtmterm', '<http://rdf.cdisc.org/sdtmterm#>',
'skos', '<http://www.w3.org/2004/02/skos/core#>',
'study', '<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#>',  
'time', '<http://www.w3.org/2006/time#>',  
'rdf', '<http://www.w3.org/1999/02/22-rdf-syntax-ns#>',
'xsd', '<http://www.w3.org/2001/XMLSchema#>'
)

#rootNodeDer <- "cdiscpilot01:AgeOutcome_k5ql986im5d6cj0eee80312k9scue0h7"
#rootNodeOnt <- "cdiscpilot01:AgeOutcome_1"

#---- UI ----------------------------------------------------------------------
ui <- fluidPage(
  # Selection
  fluidRow(
    column(12, 
      h4("Ontology"),
      textInput('rootNodeOnt', "Subject QName", value = "cdiscpilot01:Person_01-701-1015")
    )
  ),
  # Diagram
  fluidRow(
    column(12, 
      wellPanel(
        collapsibleTreeOutput("tree1", width="100%", height="900px")
      )
    )
  ),
  fluidRow(
    column(6, 
      h4("Derive"),
           textInput('rootNodeDer', "Subject QName", value = "cdiscpilot01:Person_01-701-1015")
    )
  ),
  fluidRow(
    column(12, 
      wellPanel(
        collapsibleTreeOutput("tree2" , width="100%", height="900px")
      )
    )
  ),
  # Data tables
  fluidRow(
    column(6, 
      div(DT::dataTableOutput("ontData"), style = "font-size:50%")
    ),
    column(6, 
      div(DT::dataTableOutput("derData"), style = "font-size:50%")
    )
  )
)

#---- Server ------------------------------------------------------------------

server <- function(input, output, session) {

  triplesOnt <- reactive({
  
    # Errors if PREFIX not included here for the Ont query. Is ok without it in the Der query. WHY?
    #   See if the prefixes assigned differently WITHIN Stardog DB.

    queryOnt = paste0("
    PREFIX cdiscpilot01: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#> 
    PATHS ALL
    START ?s = ", input$rootNodeOnt," 
    END ?o
    VIA ?p
    ")

    # Query results dfs ----  
    qrOnt <- SPARQL(url=epOnt, query=queryOnt)
    #--------------------
    triplesOnt <- qrOnt$results

    # Post query processing
    triplesOnt <- triplesOnt[complete.cases(triplesOnt), ]  # remove blank rows. 
    triplesOnt <- triplesOnt[, c("s", "p", "o")]   # remove o.l, s.l
    triplesOnt <- unique(triplesOnt)  # Remove dupes
    
    
    # Create a function for this:
    # Subjects
    triplesOnt$s <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#", 
      "cdiscpilot01:", triplesOnt$s)
    triplesOnt$s <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01-protocol.ttl", 
      "cd01p:", triplesOnt$s)
    
    
    # Predicates 
    triplesOnt$p <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#", 
      "cdiscpilot01:", triplesOnt$p)
    triplesOnt$p <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/code.ttl#", 
      "code:", triplesOnt$p)
    triplesOnt$p <- gsub("<http://www.w3.org/1999/02/22-rdf-syntax-ns#", 
      "rdf:", triplesOnt$p)
    triplesOnt$p <- gsub("<http://www.w3.org/2000/01/rdf-schema#", 
      "rdfs:", triplesOnt$p)
    triplesOnt$p <- gsub("<http://www.w3.org/2004/02/skos/core#", 
      "skos:", triplesOnt$p)
    triplesOnt$p <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#", 
      "study:", triplesOnt$p)
    triplesOnt$p <- gsub("<http://www.w3.org/2006/time#", 
      "time:", triplesOnt$p)
    
    # Objects
    triplesOnt$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#", 
      "cdiscpilot01:", triplesOnt$o)
    triplesOnt$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/code.ttl#", 
      "code:", triplesOnt$o)
    triplesOnt$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01-protocol.ttl", 
      "cd01p:", triplesOnt$o)
    triplesOnt$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/custom#", 
      "custom:", triplesOnt$o)
    triplesOnt$o <- gsub("<http://www.w3.org/2002/07/owl#", 
      "owl:", triplesOnt$o)
    triplesOnt$o <- gsub("<http://www.w3.org/1999/02/22-rdf-syntax-ns#", 
      "rdf:", triplesOnt$o)
    triplesOnt$o <- gsub("<http://www.w3.org/2000/01/rdf-schema#", 
      "rdfs:", triplesOnt$o)
    triplesOnt$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/sdtm-terminology.rdf#", 
      "sdtmterm:", triplesOnt$o)
    
    # recoding needed in AO source!  Update URI!
    triplesOnt$o <- gsub("<http://rdf.cdisc.org/sdtmterm#", 
      "sdtmterm:", triplesOnt$o)
    
    
    triplesOnt$o <- gsub("<http://www.w3.org/2004/02/skos/core#", 
      "skos:", triplesOnt$o)
    triplesOnt$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#", 
      "study:", triplesOnt$o)
    triplesOnt$o <- gsub("<http://www.w3.org/2006/time#", 
      "time:", triplesOnt$o)
    # Remove the trailing >
    triplesOnt$s <- gsub(">", "", triplesOnt$s)
    triplesOnt$p <- gsub(">", "", triplesOnt$p)
    triplesOnt$o <- gsub(">", "", triplesOnt$o)
    
    
    rootNodeDF <- data.frame(s=NA,p="Person 1", o=input$rootNodeOnt,
      stringsAsFactors=FALSE)
    triplesOnt <- rbind(rootNodeDF, triplesOnt)
    
    # Code for plotting as collapsible nodes
    # Re-order as needed by collapsibleNodes pkg.
    triplesOnt$Title <- triplesOnt$o
    triplesOnt[1,"Title"] <- paste(input$rootNodeOnt) # THis will come from the drop down selector
    # Re-order columns. The s,o must be the first two columns.
    triplesOnt<-triplesOnt[c("s", "o", "p", "Title")]
    
    # Sort the dataframe values
    triplesOnt<-triplesOnt[with(triplesOnt, order(s, p, o)), ]

  })
  
  triplesDer <- reactive({

    queryDer = paste0("
    PREFIX cdiscpilot01: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#> 
    PATHS ALL
    START ?s = ", input$rootNodeDer," 
    END ?o
    VIA ?p
    ")

    qrDer <- SPARQL(url=epDer, query=queryDer)

    triplesDer <- qrDer$results

    #---------------
    # Post query processing
    triplesDer <- triplesDer[complete.cases(triplesDer), ]  # remove blank rows. 
    triplesDer <- triplesDer[, c("s", "p", "o")]   # remove o.l, s.l
    triplesDer <- unique(triplesDer)  # Remove dupes
    
    # Create a function for this:
    # Subjects
    triplesDer$s <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#", 
      "cdiscpilot01:", triplesDer$s)
    triplesDer$s <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01-protocol.ttl", 
      "cd01p:", triplesDer$s)
    
    # Predicates 
    triplesDer$p <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#", 
      "cdiscpilot01:", triplesDer$p)
    triplesDer$p <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/code.ttl#", 
      "code:", triplesDer$p)
    triplesDer$o <- gsub("<http://www.w3.org/2002/07/owl#", 
      "owl:", triplesDer$o)
    triplesDer$p <- gsub("<http://www.w3.org/1999/02/22-rdf-syntax-ns#", 
      "rdf:", triplesDer$p)
    triplesDer$p <- gsub("<http://www.w3.org/2000/01/rdf-schema#", 
      "rdfs:", triplesDer$p)
    triplesDer$p <- gsub("<http://www.w3.org/2004/02/skos/core#", 
      "skos:", triplesDer$p)
    triplesDer$p <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#", 
      "study:", triplesDer$p)
    triplesDer$p <- gsub("<http://www.w3.org/2006/time#", 
      "time:", triplesDer$p)
    
    # Objects
    triplesDer$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#", 
      "cdiscpilot01:", triplesDer$o)
    triplesDer$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/code.ttl#", 
      "code:", triplesDer$o)
    triplesDer$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01-protocol.ttl", 
      "cd01p:", triplesDer$o)
    triplesDer$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/custom#", 
      "custom:", triplesDer$o)
    triplesDer$o <- gsub("<http://www.w3.org/1999/02/22-rdf-syntax-ns#", 
      "rdf:", triplesDer$o)
    triplesDer$o <- gsub("<http://www.w3.org/2000/01/rdf-schema#", 
      "rdfs:", triplesDer$o)
    triplesDer$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/sdtm-terminology.rdf#", 
      "sdtmterm:", triplesDer$o)
    triplesDer$o <- gsub("<http://www.w3.org/2004/02/skos/core#", 
      "skos:", triplesDer$o)
    triplesDer$o <- gsub("<https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#", 
      "study:", triplesDer$o)
    triplesDer$o <- gsub("<http://www.w3.org/2006/time#", 
      "time:", triplesDer$o)
    
    # Remove the trailing >
    triplesDer$s <- gsub(">", "", triplesDer$s)
    triplesDer$p <- gsub(">", "", triplesDer$p)
    triplesDer$o <- gsub(">", "", triplesDer$o)
    
    rootNodeDF <- data.frame(s=NA,p="Person 1", o=input$rootNodeDer,
      stringsAsFactors=FALSE)
    triplesDer <- rbind(rootNodeDF, triplesDer)
    
    # Code for plotting as collapsible nodes
    # Re-order as needed by collapsibleNodes pkg.
    triplesDer$Title <- triplesDer$o
    triplesDer[1,"Title"] <- paste(input$rootNodeDer) # THis will come from the drop down selector
    # Dataframe column order. The s,o must be the first two columns.
    triplesDer<-triplesDer[c("s", "o", "p", "Title")]
    
    # Sort the dataframe
    triplesDer[with(triplesDer, order(s, p, o)), ]

  })  

  # Ontology Paths
  output$tree1 <- renderCollapsibleTree({
    collapsibleTreeNetwork(
      triplesOnt(),
      c("s", "o"),
      tooltipHtml="p",
      width = "100%"
    )
  })
  # Dervied Paths
  output$tree2 <- renderCollapsibleTree({
    collapsibleTreeNetwork(
      triplesDer(),
      c("s", "o"),
      tooltipHtml="p",
      width = "100%"
    )
  })
  output$ontData = DT::renderDataTable({triplesOnt()[, c("s", "p","o")]})
  
  output$derData = DT::renderDataTable({triplesDer()[, c("s", "p","o")]})

}

shinyApp(ui = ui, server = server)