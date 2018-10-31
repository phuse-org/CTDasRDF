#______________________________________________________________________________
# FILE: server.R
# DESC: Server for SMS Map visualization
# SRC :
# IN  : triples df, subset using the UI input$maps
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO:  Add subsetting based on namespace selections
#        Add drop down list to allow node selection (is part of visNetwork built-in)
#______________________________________________________________________________

function(input, output, session) {
  #startNode <- "cdiscpilot01:Person_01-701-1015"
  # Note  input$startNode value is NOT enquoted!
  triplesDisplay <- reactive({   
    triplesDisplay <- dplyr::filter(triples, mapFile %in% input$maps)

  })

  output$selectedMaps <- renderText(input$maps)

  output$triplesTable <- renderTable({
    triplesDisplay()
  })
  
  
  
  #____________________________________________________________________________
  #  Vistnetwork render
  #____________________________________________________________________________
  output$path_vis <- renderVisNetwork({
  # -----------------------------------------------------------------------------
  # Nodes Construction ----
  # -- Nodes: Data ----
  # Get the unique list of nodes 
  #   Combine Subject and Object into a single column
  #   "id.vars" is the list of columns to keep untouched. The unamed ones (s,o) are 
  #   melted into the "value" column.
  #TODO switch to triples()
    
  nodeList <- melt(triplesDisplay(), id.vars=c("p", "mapFile"))

  # A node can be both a Subject and a Predicate so ensure a unique list of node names
  #  by dropping duplicate values.
  nodeList <- nodeList[!duplicated(nodeList$value),]

  # Rename to ID for use in visNetwork and keep only that column
  nodeList <- reshape::rename(nodeList, c("value" = "id" ))
  nodes <- as.data.frame(nodeList[c("id", "mapFile")])
  nodes <- as.data.frame(nodes[!duplicated(nodes), ])


  # Labels for mouseover
  #    nodes$title <- nodes$id
  #    nodes$label <- nodes$id
  # Label and Title ----
  nodes$title <- gsub("\\{", "<font color='red'>\\{", nodes$id, perl=FALSE)
  nodes$title <- gsub("\\}", "\\}</font>", nodes$title)
      
  #TW if the id value is longer than maxLabelSize and is a string. truncate using ...
  # id gets coerced to integer within ifelse, must use as.character to overcome!
  #nodes$label <-nodes$id  # label for the node. No HTMl allowed.
  nodes$label="";
  
  nodes$label <- strtrim(nodes$id, maxLabelSize) 
  
  # nodes$label <- paste0(strtrim(nodes$id, 20), "...")
  nodes$shape <- "box"
  nodes$borderWidth <- 2


  nodes$size <- 30
  nodes$color.background <- "white"
  nodes$color.border     <- "black"
    
  # Nodes color based on prefix
  nodes$color.background[ grepl("cdiscpilot01:", nodes$id, perl=TRUE) ] <- "#2C52DA"
  nodes$color.background[ grepl("cd01p:",        nodes$id, perl=TRUE) ] <- '#008D00'   
  nodes$color.background[ grepl("code:",         nodes$id, perl=TRUE) ] <- '#1C5B64'
  nodes$color.background[ grepl("study:",        nodes$id, perl=TRUE) ] <- '#FFBD09'  
  nodes$color.background[ grepl("custom:",        nodes$id, perl=TRUE) ] <- '#C71B5F'  

  #---- Edges
  # Create list of edges by keeping the Subject and Predicate from query result.
  edges<-reshape::rename(triplesDisplay(), c("s" = "from", "o" = "to"))
  edges$arrows <- "to"
  edges$title <- edges$p  # title: present when mouseover edge.
  edges$label <- edges$p  #TW  May need to shorten as did for node label
  edges$length <- 500  # Could make this dynamic for large vs small graphs based on dataframe size...
  
  edges$color <- "black"  # default and for literals
  edges$color[ grepl("cdiscpilot01:", edges$to, perl=TRUE) ] <- "#2C52DA"
  edges$color[ grepl("cd01p:",        edges$to, perl=TRUE) ] <- '#008D00'   
  edges$color[ grepl("code:",         edges$to, perl=TRUE) ] <- '#1C5B64'
  edges$color[ grepl("study:",        edges$to, perl=TRUE) ] <- '#FFBD09'  
  edges$color[ grepl("custom:",       edges$to, perl=TRUE) ] <- '#C71B5F'  

  edges$font.color <- "black"
  edges$font.strokeColor <- "#919191"  # Set to background grey
  
    
  visNetwork(nodes, edges, width= "100%", height=1100, background = "#919191") %>%
  
    visIgraphLayout(layout  = "layout_nicely",
                    physics = FALSE) %>%  
    
    visIgraphLayout(avoidOverlap = 1) %>%

    visEdges(smooth=FALSE)  
  
    # Legend not currently in play
    # %>%

      # Legend
      #   Examples at : https://datastorm-open.github.io/visNetwork/legend.html  
     # visLegend(addNodes  = lnodes, 
    #            useGroups = FALSE,
    #            width     =  .2,
    #            stepY     = 60)
  })
} # end of server.R