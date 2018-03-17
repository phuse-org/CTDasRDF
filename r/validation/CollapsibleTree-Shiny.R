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
'rdfs', '<http://www.w3.org/2000/01/rdf-schema#>',
'xsd', '<http://www.w3.org/2001/XMLSchema#>'
)

#TODO: These will be selected in the drop down
#rootNodeDer <- "cdiscpilot01:Person_v29eedorsh9a5vr65uc1iob3mvn9blbb"
#rootNodeOnt <- "cdiscpilot01:Person_1"

# rootNodeDer <-"cdiscpilot01:Lifespan_udj4rptja2ij6a5lmb3meemc3mca7ip3_n6l0u58r7lrhic8l4b1e4u7k8182j6fq"
# rootNodeOnt <- "cdiscpilot01:Lifespan_1"

#rootNodeDer <- "cdiscpilot01:DemographicDataCollection_v29eedorsh9a5vr65uc1iob3mvn9blbb"
#rootNodeOnt <- "cdiscpilot01:DemographicDataCollection_1"


#rootNodeDer <- "cdiscpilot01:VisitScreening1Activity_v29eedorsh9a5vr65uc1iob3mvn9blbb"
#rootNodeOnt <- "cdiscpilot01:VisitScreening1Activity_1"



rootNodeDer <- "cdiscpilot01:AgeOutcome_k5ql986im5d6cj0eee80312k9scue0h7"
rootNodeOnt <- "cdiscpilot01:AgeOutcome_1"

# Form the queries ---- 
# PREFIX cdiscpilot01: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#> 
queryDer = paste0("
SELECT ?s ?p ?o
WHERE{", rootNodeDer," ?p ?o
   BIND(\"",rootNodeDer,"\" AS ?s)
} ORDER BY ?p ?o")

queryDer

# errors if PREFIX not included here for the Ont query. Is ok without it in the Der query. WHY?
#  See if the prefixes assigned differently WITHIN Stardog DB.
queryOnt = paste0("
PREFIX cdiscpilot01: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#> 
SELECT ?s ?p ?o
WHERE{", rootNodeOnt," ?p ?o
   BIND(\"",rootNodeOnt,"\" AS ?s)
} ORDER BY ?p ?o")

  
# Query results dfs ----  
qrOnt <- SPARQL(url=epOnt, query=queryOnt, ns=namespaces)
triplesOnt <- as.data.frame(qrOnt$results, stringsAsFactors=FALSE)
  


qrDer <- SPARQL(url=epDer, query=queryDer, ns=namespaces)
triplesDer <- as.data.frame(qrDer$results, stringsAsFactors=FALSE)


# Create root nodes and append to start of dataframes
rootNodeOnt <- data.frame(s=NA,p="foo", o="cdiscpilot01:Person_1",
  stringsAsFactors=FALSE)
triplesOnt <- rbind(rootNodeOnt, triplesOnt)

rootNodeDer <- data.frame(s=NA,p="foo", o="cdiscpilot01:Person_v29eedorsh9a5vr65uc1iob3mvn9blbb",
  stringsAsFactors=FALSE)
triplesDer <- rbind(rootNodeDer, triplesDer)


# Assign titles ----
triplesOnt$Title <- triplesOnt$o
triplesOnt[1,"Title"] <- "Person_1" # THis will come from the drop down selector
# Re-order dataframe. The s,o must be the first two columns.
triplesOnt<-triplesOnt[c("s", "o", "p", "Title")]

triplesDer$Title <- triplesDer$o
triplesDer[1,"Title"] <- "Person_1" # THis will come from the drop down selector
# Re-order dataframe. The s,o must be the first two columns.
triplesDer<-triplesDer[c("s", "o", "p", "Title")]

ui <- fluidPage(
  # Select start node row
  fluidRow(
    column(6, 
      h4("Ontology"),
      selectInput("ontRoot", "RootNode:",
              c("Person_1" = "Person_datdasfasdfasdsd",
                "RefInterval" = "RefInterval_xxxxx_xxxx",
                "DemogColl" = "DemographicDataCollecion_Xxxxxxx"))
    ),
    column(6, 
      h4("Derive"),
      selectInput("ontRoot", "RootNode:",
              c("Person_1" = "Person_datdasfasdfasdsd",
                "RefInterval" = "RefInterval_xxxxx_xxxx",
                "DemogColl" = "DemographicDataCollecion_Xxxxxxx"))
    )
  ),
  # Diagram row
  fluidRow(
    column(6, 
      wellPanel(
        collapsibleTreeOutput("tree1", width="100%", height="500px")
      )
    ),
    column(6, 
      wellPanel(
        collapsibleTreeOutput("tree2" , width="100%", height="500px")
      )
    )
  ),

  # Data tables row
  fluidRow(
    column(6, 
      div(DT::dataTableOutput("ontData"), style = "font-size:50%")
    ),
    column(6, 
      div(DT::dataTableOutput("derData"), style = "font-size:50%")
    )
  )
)

server <- function(input, output, session) {

  output$tree1 <- renderCollapsibleTree({
    collapsibleTreeNetwork(
      triplesOnt,
      c("s", "o"),
      tooltipHtml="p",
      width = "100%"
    )
  })
  output$tree2 <- renderCollapsibleTree({
    collapsibleTreeNetwork(
      triplesDer,
      c("s", "o"),
      tooltipHtml="p",
      width = "100%"
    )
  })
  output$ontData = DT::renderDataTable({triplesOnt[, c("s", "p","o")]})
  
  output$derData = DT::renderDataTable({triplesDer[, c("s", "p","o")]})

  
  
}

shinyApp(ui = ui, server = server)