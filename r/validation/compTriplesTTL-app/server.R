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
# NOTE: Currently used for MedDRA construction with default subject set in 
#       ui.R
# TODO: Convert from rrdf to rdflib for file read. See ReadTTL-rdflib.R for read
#       Add IRItoPrefix() function and function call.
#
#______________________________________________________________________________

function(input, output, session) {

  # Ontology triples
  ontTriples <- reactive({
    req(input$fileOnt)

    inFileOnt <- input$fileOnt
    
    file.rename(inFileOnt$datapath,
                paste(inFileOnt$datapath, ".ttl", sep=""))
    
    queryString = paste0(prefixes,"
         SELECT ?s ?p ?o
         WHERE {", input$qnam, " ?p ?o . 
         BIND(\"", input$qnam, "\" as ?s) } ")
    
    rdf <- rdf_parse(paste(inFileOnt$datapath,".ttl",sep=""), format = "turtle")
    triplesOnt <- rdf_query(rdf, queryString)

    # Remove cases where O is missing in the Ontology source(atrifact from TopBraid)
    triplesOnt <- triplesOnt[!(triplesOnt$o==""),]
    triplesOnt <- triplesOnt[complete.cases(triplesOnt), ]
    
    # Change URI to QNAM for display purposes
    triplesOnt <- shortenIRI(sourceDF   = triplesOnt, 
                            colsToParse = c("p", "o") ,
                            usePrefix   = TRUE)
    triplesOnt <- triplesOnt[with(triplesOnt, order(s,p,o)), ]
  })
  
  # Ontology triples table. Predicate and Objects only
  output$ontSP <-renderTable({
    triplesSPO <- ontTriples()
    triplesSPO <- triplesSPO[, c("p","o"), ]
  })    
  
  # R triples 
  rTriples <- reactive({
    req(input$fileR)
    inFileR <- input$fileR
        file.rename(inFileR$datapath,
      paste(inFileR$datapath, ".ttl", sep=""))

    queryString = paste0(prefixes,"
      SELECT ?s ?p ?o
      WHERE {", input$qnam, " ?p ?o . 
      BIND(\"", input$qnam, "\" as ?s) } ")

    rdf <- rdf_parse(paste(inFileR$datapath,".ttl",sep=""), format = "turtle")
    triplesR <- rdf_query(rdf, queryString)
    
    # Change URI to QNAM for display purposes
    triplesR <- shortenIRI(sourceDF      = triplesR, 
                             colsToParse = c("p", "o") ,
                             usePrefix   = TRUE)
    
    triplesR <- triplesR[with(triplesR, order(s,p,o)), ]
    
   }) 
    
  # R Triples Table. Predicate and Objects only
  output$rSP <-renderTable({
    triplesSPO <- rTriples()
    triplesSPO <- triplesSPO[, c("p","o"), ]
  })    
 
  #Triples that do not match between the two sources.
  output$unmatched <- renderTable({ 
    # Both input files are required for the comparison
    req(input$fileR, input$fileOnt) 
    
    # Mismatch detection
    if (input$comp=='inRNotOnt') {
       compResult <<-anti_join(rTriples(), ontTriples())
    }
    else if (input$comp=='inOntNotR') {
       compResult <- anti_join(ontTriples(), rTriples())
    }
    compResult
  })
}    