#______________________________________________________________________________
# FILE: nonInstance.R
# DESC: Build prefixes and non-instance data like owl:import statements.
# REQ : 
#       
# SRC : N/A
# IN  :  prefixes.csv - prefixes and their namespaces
#        imports.csv  - statements for OWL imports
# OUT :
# NOTE:
# TODO: 
#______________________________________________________________________________

# Build Prefixes --------------------------------------------------------------
#   Add prefixes to files cdiscpilot01-R.TTL, and later to other namespace TTL
#     files if/when implemented, allowing one source of prefix definitions for
#     both building the TTL file and for later query and vis. R scripts.
#------------------------------------------------------------------------------
allPrefix <- "data/config/prefixes.csv"  # List of prefixes

prefixes <- as.data.frame( read.csv(allPrefix,
  header=T,
  sep=',' ,
  strip.white=TRUE))

ddply(prefixes, .(prefix), function(prefixes)
{

  # BUild these statements: 
  # status <- setNameSpace(serializer, world, namespace="http://purl.org/dc/elements/1.1/", prefix="dc")  
  # status <- setNameSpace(serializer, world, namespace="http://foo.bar/", prefix="foo")  
# status <- setNameSpace(serializer, world, namespace="https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#", prefix="cdiscpilot01")

  #TW this takes place in DRIVER.R now
  #status <- setNameSpace(serializer, world, 
  #  namespace=as.character(prefixes$namespace), prefix=as.character(prefixes$prefix))  
    
  
#DEL Redland adds perfixes automagically
#TW   add.prefix(cdiscpilot01,
#TW     prefix=as.character(prefixes$prefix),
#TW     namespace=as.character(prefixes$namespace)
#TW   )
  
  
  # Create uppercase prefix names for use in add() statements in the 
  #   xx_process.R scripts. 
  assign(paste0(toupper(prefixes$prefix)), prefixes$namespace, envir=globalenv())
  # assign(paste0("prefix.",toupper(prefixes[i, "prefix"])), prefixes[i, "namespace"], envir=globalenv()))
})


# Build Imports --------------------------------------------------------------
#   Create the owl:import statements 
#   only if flag in buildRDF-Driver is TRUE
#------------------------------------------------------------------------------
#TW if (importsEnabled==TRUE){
#TW   owlImports <- "data/config/imports.csv"  # List of prefixes
#TW   imports <- as.data.frame( read.csv(owlImports,
#TW     header=T,
#TW     sep=',' ,
#TW     strip.white=TRUE))
#TW 
#TW   add.triple(cdiscpilot01,
#TW     paste0("https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl"),
#TW     paste0(prefix.RDF,"type" ),
#TW     paste0(prefix.OWL, "Ontology")
#TW   )
#TW   ddply(imports, .(o), function(imports)
#TW   {
#TW     add.triple(cdiscpilot01,
#TW       paste0(imports$s),
#TW       paste0(prefix.OWL,"imports"),
#TW       paste0(imports$o)
#TW     )
#TW   })
#TW }