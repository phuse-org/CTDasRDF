###############################################################################
# FILE: VisClasses-Shiny.R
# DESC: Visualize Class>-Subsclass relations in any .TTL file. 
# REQ : 
# SRC : 
# IN  : Any .TTL file that contains rdfs:subClassOf relations
# OUT : 
# NOTE: Authored by Yiqing Tian and Tim Williams
# TODO: 
###############################################################################
library(plyr)  #  rename
library(reshape)  #  melt
library(rrdf)
library(visNetwork)
library(shiny)


server <- function(input, output) {
  
  output$contents <- renderTable({
    inFile <- input$file1
    
    if(is.null(inFile))
      return(NULL)
   file.rename(inFile$datapath,
               paste(inFile$datapath, ".ttl", sep=""))
   query = 'PREFIX study: <http://example.org/study#>
   PREFIX owl:   <http://www.w3.org/2002/07/owl#>
   PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
   PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
   PREFIX time:  <http://www.w3.org/2006/time>
   SELECT ?parent ?relation ?child
   WHERE{
   ?child rdfs:subClassOf ?parent .
   BIND ("hasSubClass" AS ?relation)
   FILTER (?parent != rdfs:Resource)
   FILTER (?parent != ?child)
   }'
   rdfSource = load.rdf(paste(inFile$datapath,".ttl",sep=""), format="N3")
   OntTriples = as.data.frame(sparql.rdf(rdfSource, query))
   
   nodeList <- melt(OntTriples, id.vars=c("relation" ))
   nodeList <- nodeList[!duplicated(nodeList$value),]
   nodeList <- rename(nodeList, c("value" = "id"))
   nodes<- as.data.frame(nodeList[c("id")])
   
   
   # Assign labels used for mouseover and for label
   nodes$title <- nodes$id
   nodes$label <- nodes$id
   head(nodes)
  })
  
  output$network <- renderVisNetwork({
    inFile <- input$file1
    
    if(is.null(inFile))
      return(NULL)
    file.rename(inFile$datapath,
                paste(inFile$datapath, ".ttl", sep=""))
    query = 'PREFIX study: <http://example.org/study#>
    PREFIX owl:   <http://www.w3.org/2002/07/owl#>
    PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX time:  <http://www.w3.org/2006/time>
    SELECT ?parent ?relation ?child
    WHERE{
    ?child rdfs:subClassOf ?parent .
    BIND ("hasChild" AS ?relation)
    FILTER (?parent != rdfs:Resource)
    FILTER (?parent != ?child)
    }'
    rdfSource = load.rdf(paste(inFile$datapath,".ttl",sep=""), format="N3")
    OntTriples = as.data.frame(sparql.rdf(rdfSource, query))
    nodeList <- melt(OntTriples, id.vars=c("relation" ))
    nodeList <- nodeList[!duplicated(nodeList$value),]
    
    # Rename to ID for use in visNetwork and keep only that column
    nodeList <- rename(nodeList, c("value" = "id" ))
    nodes<- as.data.frame(nodeList[c("id")])
    
    
    # Assign labels used for mouseover and for label
    nodes$title <- nodes$id
    nodes$label <- nodes$id
    # nodes$size <- 30
    
    #---- Edges
    # Create list of edges by keeping the Subject and Predicate from query result.
    edges<-rename(OntTriples, c("parent" = "from", "child" = "to"))
    edges$title <- edges$relation  # title: present when mouseover edge.

    visNetwork(nodes, edges) %>%
      visEdges(arrows = 'to') %>%
      visHierarchicalLayout() %>%
      visNodes(shape= "box") %>%
      visPhysics(hierarchicalRepulsion = list(nodeDistance =250),minVelocity = 0.3)
  })
  output$text1<- renderText({
    inFile <- input$file1
    paste("path",inFile$datapath)
    
  })
  
}

ui <- fluidPage(
  fileInput('file1', 'Choose TTL File'),
  visNetworkOutput("network",height = "500px"),
  textOutput('text1'),
  tableOutput('contents')
)
shinyApp(ui = ui, server = server)

