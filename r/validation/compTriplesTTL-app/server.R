#______________________________________________________________________________
# FILE: r/validation/compTriplesTTL-appp/server.R
# DESC: Compare triples in two TTL files, starting at a named Subject.
#         Used to compare instance data created in the Ontology approach with
#         data converted using R
# SRC :
# IN  : TTL files in a local folder. Typically /data/rdf
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: Move R query sep as per Ont query. 
#       Move data table to be side-by-side for comparison
#
#______________________________________________________________________________

function(input, output, session) {

  ontTriples <- reactive({
    req(input$fileOnt)
    
    inFileOnt <- input$fileOnt
    
    file.rename(inFileOnt$datapath,
                paste(inFileOnt$datapath, ".ttl", sep=""))
    
    query = paste0(prefixes,"
         SELECT ?s ?p ?o
         WHERE {", input$qnam, " ?p ?o . 
         BIND(\"", input$qnam, "\" as ?s) } ")
    
    sourceOnt = load.rdf(paste(inFileOnt$datapath,".ttl",sep=""), format="N3")
    triplesOnt <- as.data.frame(sparql.rdf(sourceOnt, query))
    
    # Remove cases where O is missing in the Ontology source(atrifact from TopBraid)
    triplesOnt <-triplesOnt[!(triplesOnt$o==""),]
    triplesOnt <- triplesOnt[complete.cases(triplesOnt), ]
    triplesOnt <- triplesOnt[with(triplesOnt, order(s,p,o)), ]
    
  })
  
  # Ontology Triples Table, Predicate and Objects only
  output$ontSP <-renderTable({
    triplesSPO <- ontTriples()
    triplesSPO <- triplesSPO[, c("p","o"), ]
  })    
  
  
  output$unmatched <- renderTable({ 
    req(input$fileR)
    req(input$fileOnt)
        
    inFileR   <- input$fileR
    #inFileOnt <- input$fileOnt
    # Do not do anything until both FileR and FileOnt have been specified.
    #TODO Confirm these two steps
    file.rename(inFileR$datapath,
      paste(inFileR$datapath, ".ttl", sep=""))
    #DEL file.rename(inFileOnt$datapath,
    #DEL   paste(inFileOnt$datapath, ".ttl", sep=""))

    query = paste0(prefixes,"
      SELECT ?s ?p ?o
      WHERE {", input$qnam, " ?p ?o . 
      BIND(\"", input$qnam, "\" as ?s) } ")

    sourceR = load.rdf(paste(inFileR$datapath,".ttl",sep=""), format="N3")
    # Global assign for trouble shooting
    triplesR <<- as.data.frame(sparql.rdf(sourceR, query))
       
    #sourceOnt = load.rdf(paste(inFileOnt$datapath,".ttl",sep=""), format="N3")
    # triplesOnt <- as.data.frame(sparql.rdf(sourceOnt, query))
    
    triplesOnt <- ontTriples()
    triplesOnt <- triplesOnt[complete.cases(triplesOnt), ]
    if (input$comp=='inRNotOnt') {
       compResult <<-anti_join(triplesR, triplesOnt)
    }
    else if (input$comp=='inOntNotR') {
       compResult <- anti_join(triplesOnt, triplesR)
    }

    compResult
  })
    
    
    # R Triples Table
    output$triplesR <-renderTable({
      req(input$fileR)
      inFileR   <- input$fileR
      file.rename(inFileR$datapath,
                  paste(inFileR$datapath, ".ttl", sep=""))
      
      query = paste0(prefixes,"
        SELECT ?s ?p ?o
        WHERE {", input$qnam, " ?p ?o . 
        BIND(\"", input$qnam, "\" as ?s) } ")
      
      sourceR = load.rdf(paste(inFileR$datapath,".ttl",sep=""), format="N3")
      # Global assign for trouble shooting
      triplesR <- as.data.frame(sparql.rdf(sourceR, query))
      triplesR <- triplesR[with(triplesR, order(s,p,o)), ]
      triplesR <- triplesR[, c("p","o"), ]
      
    })    
}    