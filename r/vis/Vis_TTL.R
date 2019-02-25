###############################################################################
# FILE: /scripts/r/TTLValidation.R
# DESC: LDWorkshop: Select, query, validate, and visuzalize a TTL file.
# IN  : 
# OUT : N/A
# REQ : 
# NOTE: Visualize requires query to return s,p,o. 
# TODO: 1. Reload of TTL does not reset QC Check data. Need to reset dataframes
#       
###############################################################################
library(plyr)     #  rename
library(reshape)  #  melt
library(shiny)
library(redland)
library(visNetwork)

#---- Values to check ---------------------------------------------------------
#    Nodes that should be present in all graphs
standardNodes <- c("eg:ActiveArm", "eg:Drug1", "eg:PlaceboArm", "eg:Serum114", "ncit:Female", "ncit:Male")

#    Relations that should be present in all graphs
standardRelations <- c("eg:age", "eg:LDExpert", "eg:participatesIn", "eg:randomizedTo",
  "eg:trtArm", "eg:trtArmType", "eg:drugname", "ncit:gender", "ncit:phase", "ncit:study",
  "schema:givenName")

#------------------------------------------------------------------------------
# UI 
#------------------------------------------------------------------------------
ui <- navbarPage("TTL File Query",
    theme = "spacelab.css",
    tabPanel("Query",
        wellPanel(
            column(6, fileInput('fileTTL', '.TTL File', accept=c('.ttl'))),
            column(6, fileInput('fileRQ',   'OPTIONAL: .RQ Query File')),
            fluidRow(
                textAreaInput(inputId="query", "SPARQL Query", rows=10, width='90%', 
"# To Visualize, results must be ?s ?p ?o
SELECT ?s ?p ?o 
WHERE{
    ?s ?p ?o
}"),
            actionButton(inputId = "runQuery", label="Run query")
        )
    ),
    fluidRow(
        HTML('<br><label for="endpoint">Query Result:</label>'),
        dataTableOutput("queryresult")
    )
    ),
    tabPanel("Visualize",
        visNetworkOutput("network",height = '900px')
    )
)

#------------------------------------------------------------------------------
# SERVER 
#------------------------------------------------------------------------------
server <- function(input, output, session) {

    queryText <- observeEvent(input$fileRQ, {
        filePath <- input$fileRQ$datapath
        queryText <- paste(readLines(filePath), collapse = "\n")
        # Update text area with file content
        updateTextAreaInput(session, "query", value = queryText)
        # return the text to be displayed in text Outputs
        return(queryText)
    })
    output$query <- renderPrint({ queryText() })    

    data <- eventReactive(input$runQuery, {

        # Setup the file read for redland
        world   <- new("World")
        storage <- new("Storage", world, "hashes", name="", options="hash-type='memory'")
        model   <- new("Model", world=world, storage, options="")
        parser  <- new("Parser", world, name = 'turtle', mimeType = 'text/turtle')

        inFileTTL <- input$fileTTL
            redland::parseFileIntoModel(parser, world, inFileTTL$datapath, model)
       
            queryResults = c(); 
            query <- new("Query", world, input$query, base_uri=NULL, query_language="sparql", query_uri=NULL)
            queryResult <- executeQuery(query, model)
            
            # getNextResult in a loop until NULL is returned.
            repeat{
                nextResult <- getNextResult(queryResult)
                queryResults <- rbind(queryResults, data.frame(nextResult))
                if(is.null(nextResult)){ break }
            }
        triples<-queryResults
    })

    # Query Result
    output$queryresult= renderDataTable({ data() });

    #---- Data Massage --------------------------------------------------------
    #   Massage data for both QC Check and Visualization
    #   prefData = prefixes instead of IRIs
    prefData = reactive ({
        # Replace IRI with prefixes for both plotting and data QC
        toPref <- as.data.frame(data())
        
        # Convert IRI to use prefixes
        iriToPref <- function(elem)
        {
            # meddra:
            elem <- gsub('<https://w3id.org/phuse/MEDDRA/', "meddra:", elem)
            
            # skos:
            elem <- gsub("<http://www.w3.org/2004/02/skos/core#", "skos:",elem)
            # Remove the trailing >
            elem <- gsub(">", "", elem)
            
            # Object literals require removal of quotes and type to get value only
            elem <- gsub("^\"", "", elem)  # quote at start of value
            elem <- gsub("\"\\S+", "", elem)  # quote value end and type
        }  
        toPref$s <- iriToPref(toPref$s) # Subjects
        toPref$p <- iriToPref(toPref$p) # Predicates
        toPref$o <- iriToPref(toPref$o) # Objects
        toPref  # return the dataframe
    })
  
    output$ui = renderUI({ 
      qcReport <- qcData();
      qcReport <- qcReport[!(qcReport$item==""),]  # Remove the default row for no items
      
      if (nrow(qcReport) < 1)
          return("All QC Checks Passed") # Message if no findings
          tableOutput("table") # Otherwise, return the data as a table         
    })
    # Table must be defined separately
    output$table <- renderTable({
      qcReport <-qcData();
      qcReport <-qcReport[!(qcReport$item==""),]  # Remove the default row for no items
      qcReport
    })
  
    #--------------------------------------------------------------------------
    #-- Visualize -------------------------------------------------------------
    output$network <- renderVisNetwork({
        RDFTriples <<- as.data.frame(prefData())
        
        RDFTriples<-RDFTriples[!(RDFTriples$o==""),]
        
        # Remove duplicates from the query
        RDFTriples <- RDFTriples[!duplicated(RDFTriples),]

        #---- Nodes Construction
        # Get the unique list of nodes by combine Subject and Object into 
        # single column.
        # "id.vars" = list of columns to keep untouched whil the unamed (s,o) are 
        # melted into the "value" column.
        nodeList <- melt(RDFTriples, id.vars=c("p" ))

        # A node can be both a Subject and a Predicate so ensure a unique list of node names
        #  by dropping duplicate values.
        nodeList <- nodeList[!duplicated(nodeList$value),]

        # Rename to ID for use in visNetwork and keep only that column
        nodeList <- rename(nodeList, c("value" = "id" ))
        nodes<- as.data.frame(nodeList[c("id")])

        # Assign node color based on content (int, string) then based on prefixes
        nodes$group <- 'iri'
        nodes$group[grepl("^\\w+", nodes$id, perl=TRUE)] <- "string"
        nodes$group[grepl("^\\d+", nodes$id, perl=TRUE)] <- "int"
        nodes$group[grepl("meddra:", nodes$id, perl=TRUE)] <- "meddraIRI"
        nodes$group[grepl("eg:", nodes$id, perl=TRUE)] <- "iri"
        
        nodes$shape <- "box"
        nodes$title <-  nodes$id  # mouseover. 
        nodes$label <- nodes$title # label on node (always displayed)

        
        #---- Edges
        # Create list of edges with from, to for visNetwork 
        edges<-as.data.frame(rename(RDFTriples, c("s" = "from", "o" = "to")))
        
        # Edge values
        #   edges$label : always displayed, so not set in current vis.
        #   edges$title : only displayed on mouseover. Used in current vis.
        edges$title <- edges$p

        visNetwork(nodes, edges, height = "100px", width = "100%") %>%
          visIgraphLayout(layout = "layout_nicely",
                          physics = FALSE) %>%
          visIgraphLayout(avoidOverlap = 1) %>%
          visOptions(manipulation = TRUE) %>%
        
            visOptions( highlightNearest = TRUE, 
                nodesIdSelection = TRUE) %>%
            visEdges(arrows = list(to = list(enabled = TRUE, scaleFactor = 0.5)),
                     color  = "gray",
                     smooth = list(enabled = FALSE, type = "cubicBezier", roundness=.8)) %>%
          visGroups(groupname = "meddraIRI",    color = list(background = "#BCF5BC", 
                                                border     = "#CCCCCC",
                                                highlight  = "#FFFF33")) %>%
          visGroups(groupname = "string", color = list(background = "#E4E4E4", 
                                                       border     = "#CCCCCC", 
                                                       highlight  = "#FFFF33")) %>%
          visGroups(groupname = "int",    color = list(background = "#C1E1EC", 
                                                       border     = "#CCCCCC",
                                                       highlight  = "#FFFF33" ))
          
          
    })
}
shinyApp(ui = ui, server = server)