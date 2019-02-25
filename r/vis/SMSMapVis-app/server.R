#______________________________________________________________________________
# FILE: r/vis/SMSMapVis-app/server.R
# DESC: SMS Visualization App
# SRC :
# IN  : triples df, subset using the UI input$maps
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO:  Node Seletion: Widen selection drop down to show complete node value
#        Confirm :bolean and :float literals are represented
#______________________________________________________________________________

function(input, output, session) {

    triplesDisplay <- reactive({   
    
    # Create pipe-delmited conditions that either keep (mapFile) or delete (namespace)
    #   selections. Some selection from UI may already have a pipe.
    
    mapCond <- paste( unlist(input$maps), collapse='|')
    nsCond  <- paste( unlist(input$namespaces), collapse='|')

    # Keep the values of the selected maps
    #TODO: Keep ALL when nothing selected: If no selection, default to all maps
    #      and only filter when a filter value is selected.
    triplesMap <- triples %>% filter( grepl(mapCond, mapFile, perl=TRUE))

    if (nchar(nsCond)>2 ){
      # Remove Subject values that meet exclusion criteria
      triplesMap <- triplesMap %>% filter(!grepl(nsCond, o, perl=TRUE)) 
      
      # Remove remaining Object values that meet the exclusion criteria
      triplesMap <- triplesMap %>% filter(!grepl(nsCond, s, perl=TRUE)) 
    }    
    triplesDisplay <- triplesMap

  })

  #DEBUG:  Display the selection criteria for debugging purposes  
  #output$nsCond <- renderText({
    # Convert to pipe delmiited list for multiple conditions in later selection that 
    #  uses grepl
    #foo <- paste( unlist(input$namespaces), collapse='|')
    # foo <- gsub(" ", "|",input$namespaces) 
  #})
    
  # Triples data table  
  output$triplesTable <- DT::renderDataTable({
    datatable(
      triplesDisplay(),
      options  = list(width = 300, pageLength = 15),
      rownames = FALSE
    )  
  })
  
  # Nodes data table
  output$nodesTable <- DT::renderDataTable({
    datatable(
      nodes(),
      options  = list(width = 300, pageLength = 15),
      rownames = FALSE
    )  
  })
  
  # Edges data table
  output$edgesTable <- renderTable({
    datatable(
     edges(),
      options  = list(width = 300, pageLength = 15),
      rownames = FALSE
    )  
  })

  #-- Nodes Construction ------------------------------------------------------
  nodes <- reactive({

    # Get the unique list of nodes: Subject and Object into a single column.
    #   "id.vars" is the list of columns to keep untouched. The unamed ones 
    #   (s,o) are melted into the "value" column.
    nodeList <- reshape::melt(triplesDisplay(), id.vars=c("p", "mapFile"))
  
    # A node can be both a Subject and Object so remove duplicates
    nodeList <- nodeList[!duplicated(nodeList$value),]
  
    # Rename to ID for use in visNetwork and keep only that column
    nodeList <- reshape::rename(nodeList, c("value" = "id" ))
    nodes <- as.data.frame(nodeList[c("id", "mapFile")])
    #DEL nodes <- as.data.frame(nodes[!duplicated(nodes), ])
  
    #---- Labels for display and mouseover 
    # Title - Full value of text on mouseover. HTML is allowed
    #         Values within {} in red to show comes from data. 
    nodes$title <- gsub("\\{", "<font color='red'>\\{", nodes$id, perl=FALSE)
    nodes$title <- gsub("\\}", "\\}</font>", nodes$title)
      
    # Label - on node in graph. Shortened for display. HTML NOT allowed
    #   Truncate if value is string longer than maxLabelSize
    nodes$label=""; # Default to none
    nodes$label <- strtrim(nodes$id, maxLabelSize) 
    
    nodes$shape            <- "box"
    nodes$borderWidth      <- 2
    nodes$size             <- 30
    nodes$color.background <- "white"
    nodes$color.border     <- "black"
    
    # Nodes color based on prefix
    nodes$color.background[ grepl("cdiscpilot01:", nodes$id, perl=TRUE) ] <- "#2C52DA"
    nodes$color.background[ grepl("cd01p:",        nodes$id, perl=TRUE) ] <- '#008D00'   
    nodes$color.background[ grepl("code:",         nodes$id, perl=TRUE) ] <- '#1C5B64'
    nodes$color.background[ grepl("study:",        nodes$id, perl=TRUE) ] <- '#FFBD09'  
    nodes$color.background[ grepl("custom:",       nodes$id, perl=TRUE) ] <- '#C71B5F'
    nodes$color.background[ grepl("sdtmterm:",       nodes$id, perl=TRUE) ] <- '#6AA295'
    
    # Create "other" namespace group
    nodes$color.background[ grepl("time:|owl:",    nodes$id, perl=TRUE) ] <- '#FCFF98'  # Lt Yel
    
    nodes <- as.data.frame(nodes)  # Must return as dataframe 
  })
    
  #---- Edges construction
  edges <- reactive({

    # Create list of edges by keeping the Subject and Predicate from query result.
    edges<-reshape::rename(triplesDisplay(), c("s" = "from", "o" = "to"))
    edges$arrows <- "to"
    edges$title  <- edges$p  # title: present when mouseover edge.
    edges$label  <- edges$p  # Consider shortening as did for node label
    edges$length <- 500      # ? Make dynamic for lg vs small dataframe
    edges$color  <- "black"  # Default and literals

    # Assign colors based on the target node
    edges$color[ grepl("cdiscpilot01:", edges$to, perl=TRUE) ] <- "#2C52DA"
    edges$color[ grepl("cd01p:",        edges$to, perl=TRUE) ] <- '#008D00'   
    edges$color[ grepl("code:",         edges$to, perl=TRUE) ] <- '#1C5B64'
    edges$color[ grepl("study:",        edges$to, perl=TRUE) ] <- '#FFBD09'  
    edges$color[ grepl("custom:",       edges$to, perl=TRUE) ] <- '#C71B5F' 

    # "other" group for misc categories    
    edges$color[ grepl("time:|owl:",    edges$to, perl=TRUE) ] <- '#FCFF98'  # Lt Yel
    edges$font.color       <- "black"
    edges$font.strokeColor <- "#919191"  # Set to background grey

    edges <- as.data.frame(edges) # Must return as dataframe   
  })

  #---- Graph Render ----------------------------------------------------------  
  output$path_vis <- renderVisNetwork({
    visNetwork(nodes(), edges(), 
      width= "100%", 
      height=1100, 
      background = "#919191") %>%
 
    # Drop-down selection of node names. Could also select by type   
    visOptions(
      highlightNearest = TRUE, 
      nodesIdSelection = TRUE) %>%

    visIgraphLayout(layout  = "layout_nicely",
                    physics = FALSE) %>%  
    
    visIgraphLayout(avoidOverlap = 1) %>%

    visEdges(smooth=FALSE)  
  
  })
}