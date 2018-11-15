#______________________________________________________________________________
# FILE: nonInstance.R
# DESC: 1. Build prefix referenc values 
#          and 
#       2. Other non-instance data like external ontologies using 
#          owl:import statements
# IN  :  prefixes.csv - prefixes and their namespaces
#        imports.csv  - statements for OWL imports
# OUT :
# NOTE: Creates the uppercase prefix names for use in addStatements.
#       The actual prefix values are inserted in the file in the serialize
#       statements in the main driver program.
# TODO: 
#______________________________________________________________________________


# Create Prefix references ----------------------------------------------------
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
#   Create the owl:import statements only if flag in buildRDF-Driver is TRUE. 
if (importsEnabled==TRUE){
  owlImports <- "data/config/imports.csv"  # List of prefixes
  imports <- as.data.frame( read.csv(owlImports,
    header=T,
    sep=',' ,
    strip.white=TRUE))
  
  addStatement(cdiscpilot01,
    new("Statement", world=world,
      subject   = paste0("<https://w3id.org/phuse/cdiscpilot01#>"),
      predicate = paste0(RDF,"type" ),
      object    = paste0(OWL, "Ontology")))
  ddply(imports, .(o), function(imports)
  {
    addStatement(cdiscpilot01,
      new("Statement", world=world,
        subject   = paste0(imports$s),
        predicate = paste0(OWL,"imports"),
        object    = paste0(imports$o)))
  })
}