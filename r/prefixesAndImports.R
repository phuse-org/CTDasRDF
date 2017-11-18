#______________________________________________________________________________
# FILE: nonInstance.R
# DESC: Build prefix referenc values and non-instance data like 
#       owl:import statements.
# REQ : 
# SRC : N/A
# IN  :  prefixes.csv - prefixes and their namespaces
#        imports.csv  - statements for OWL imports
# OUT :
# NOTE: Creates the uppercase prefix names for use in addStatements.
#       The actual prefix values are inserted in the file in the serialize
#       statements in the main driver program.
#       Build Imports currently NOT implemented.
# TODO: 
#______________________________________________________________________________

allPrefix <- "data/config/prefixes.csv"  # List of prefixes
prefixes <- as.data.frame( read.csv(allPrefix,
  header=T,
  sep=',' ,
  strip.white=TRUE))

ddply(prefixes, .(prefix), function(prefixes)
{
  assign(paste0(toupper(prefixes$prefix)), prefixes$namespace, envir=globalenv())
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
#TW   addStatement(cdiscpilot01,
#TW     new("Statement", world=world,
#TW     subject   = paste0("https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl"),
#TW     predicate = paste0(RDF,"type" ),
#TW     object    = paste0(OWL, "Ontology")))
#TW   ddply(imports, .(o), function(imports)
#TW   {
#TW    addStatement(cdiscpilot01,
#TW     new("Statement", world=world,
#TW       subject   = paste0(imports$s),
#TW       predicate = paste0(OWL,"imports"),
#TW       object    = paste0(imports$o)))
#TW   })
#TW }