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
# TODO: 
#______________________________________________________________________________

function(input, output, session) {

      output$contents <- renderTable({ 
  
        req(input$fileR)
        req(input$fileOnt)
        
        inFileR   <- input$fileR
        inFileOnt <- input$fileOnt
        # Do not do anything until both FileR and FileOnt have been specified.
        #DEL if(is.null(inFileR) | is.null(inFileOnt) )
        #DEL     return(NULL)
    
        #TODO Confirm these two steps
        file.rename(inFileR$datapath,
            paste(inFileR$datapath, ".ttl", sep=""))
        file.rename(inFileOnt$datapath,
            paste(inFileOnt$datapath, ".ttl", sep=""))

        query = paste0("PREFIX cd01p: <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/cd01p#>
PREFIX cdiscpilot01: <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/cdiscpilot01#>
PREFIX code:  <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/code#>
PREFIX country: <http://psi.oasis-open.org/iso/3166/#>
PREFIX custom: <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/custom#>
PREFIX meddra: <https://w3id.org/phuse/meddra#>
prefix owl:   <http://www.w3.org/2002/07/owl#>
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX sdtm: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/sdtm#>
PREFIX sdtm-terminology: <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/sdtm-terminology#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX sp: <http://spinrdf.org/sp#> 
PREFIX spin: <http://spinrdf.org/spin#> 
PREFIX study:  <https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf/study#>
PREFIX time:  <http://www.w3.org/2006/time#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 
SELECT ?s ?p ?o
WHERE {", input$qnam, " ?p ?o . 
  BIND(\"", input$qnam, "\" as ?s) } ")

       sourceR = load.rdf(paste(inFileR$datapath,".ttl",sep=""), format="N3")
       # Global assign for trouble shooting
       triplesR <<- as.data.frame(sparql.rdf(sourceR, query))
       
       sourceOnt = load.rdf(paste(inFileOnt$datapath,".ttl",sep=""), format="N3")
       triplesOnt <- as.data.frame(sparql.rdf(sourceOnt, query))
    
       # Remove cases where O is missing in the Ontology source(atrifact from TopBraid)
       triplesOnt <-triplesOnt[!(triplesOnt$o==""),]
       triplesOnt <<- triplesOnt[complete.cases(triplesOnt), ]
       if (input$comp=='inRNotOnt') {
           compResult <<-anti_join(triplesR, triplesOnt)
       }
       else if (input$comp=='inOntNotR') {
           compResult <- anti_join(triplesOnt, triplesR)
       }
  
       triplesOnt <- triplesOnt[with(triplesOnt, order(s,p,o)), ]
       triplesR   <- triplesR[with(triplesR, order(s,p,o)), ]
       
       output$triplesOnt <-renderTable({triplesOnt})    
       output$triplesR <-renderTable({triplesR})    

       compResult
    })
    
    output$triplesOnt <-renderTable({
      req(input$fileOnt)
      triplesOnt
    })    
    output$triplesR <-renderTable({
      req(input$fileR)
      triplesR
    })    
}    