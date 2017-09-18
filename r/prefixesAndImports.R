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
  add.prefix(cdiscpilot01,
    prefix=as.character(prefixes$prefix),
    namespace=as.character(prefixes$namespace)
  )
  # Create uppercase prefix names for use in add() statements in the 
  #   xx_process.R scripts. 
  assign(paste0("prefix.",toupper(prefixes$prefix)), prefixes$namespace, envir=globalenv())
  # assign(paste0("prefix.",toupper(prefixes[i, "prefix"])), prefixes[i, "namespace"], envir=globalenv()))
})


# Build Imports --------------------------------------------------------------
#   Create the owl:import statements 
#   only if flag in buildRDF-Driver is TRUE
#------------------------------------------------------------------------------
if (importsEnabled==TRUE){
  owlImports <- "data/config/imports.csv"  # List of prefixes
  imports <- as.data.frame( read.csv(owlImports,
    header=T,
    sep=',' ,
    strip.white=TRUE))

  add.triple(cdiscpilot01,
    paste0("https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl"),
    paste0(prefix.RDF,"type" ),
    paste0(prefix.OWL, "Ontology")
  )
  ddply(imports, .(o), function(imports)
  {
    add.triple(cdiscpilot01,
      paste0(imports$s),
      paste0(prefix.OWL,"imports"),
      paste0(imports$o)
    )
  })
}