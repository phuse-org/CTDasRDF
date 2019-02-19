###############################################################################
# FILE: CreateTTL-Redland-IntStringDateTime.R
# DESC: Create a TTL file using the redland package
#       Creates: xsd:string, xsd:int, xsd:dateTime 
# REQ : redland
# REF : https://cran.r-project.org/web/packages/redland/README.html
# SRC : 
# IN  : internal
# OUT : 
# NOTE: 
# TODO: 
###############################################################################
library(readxl)
library(redland)
library(plyr)
# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

# World is the redland mechanism for scoping models
world <- new("World")
# Storage provides a mechanism to store models; in-memory hashes are convenient for small models
storage <- new("Storage", world, "hashes", name="", options="hash-type='memory'")
# A model is a set of Statements, and is associated with a particular Storage instance
model <- new("Model", world=world, storage, options="")


# Dataframe of prefix assignments . Dataframe used for ease of data entry. 
#   May later change to external file?
prefixList <-read.table(header = TRUE, text = "
prefixUC  url
'CODE'    'https://w3id.org/phuse/code#'
'MDRA'    'http://foo.bar.org/ontology/MEDDRA/'
'RDF'     'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
'RDFS'    'http://www.w3.org/2000/01/rdf-schema#'
'SKOS'    'http://www.w3.org/2004/02/skos/core#'
'XSD'     'http://www.w3.org/2001/XMLSchema#'
"
)                         

# Transform the df of prefixes and values into variable names and their values
#   for use within the redland statements.
prefixUC        <- as.list(prefixList$url)
names(prefixUC) <- as.list(prefixList$prefixUC)
list2env(prefixUC , envir = .GlobalEnv)

#--- Read Source Data ---------------------------------------------------------

#--- llt ---
lltData <- read_excel("data/source/meddra/meddra.xlsx", 
                          sheet="llt")
# DEV Subset for testing
lltData <- subset(lltData, code==10003058)
lltData$rowID <- 1:nrow(lltData) # row index
# Replace column name spaces with _ 
names(lltData) <- gsub(" ", "_", names(lltData))

#--- PT ---
ptData <- read_excel("data/source/meddra/meddra.xlsx", 
                      sheet="pt")
# DEV Subset for testing (match to ptcode in llt sheet)
ptData <- subset(ptData, code==10003041)
ptData$rowID <- 1:nrow(ptData) # row index
# Replace column name spaces with _ 
names(ptData) <- gsub(" ", "_", names(ptData))

#--- RDF Creation Statements ---
#--- LLT Creation ---
ddply(lltData, .(rowID), function(lltData)
{
  
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MDRA, paste0("LLT", lltData$code)), 
      predicate = paste0(RDF,  "type"), 
      object    = paste0(MDRA, "LowLevelConcept")
  ))
  
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject      = paste0(MDRA, paste0("LLT", lltData$code)), 
      predicate    = paste0(SKOS,  "prefLabel"), 
      object       = paste0(lltData$label),
      objectType   = "literal", 
      datatype_uri = paste0(XSD,"string")
  ))
  # Identifier as a string xsd:string 
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject      = paste0(MDRA, paste0("LLT", lltData$code)), 
      predicate    = paste0(MDRA,  "hasIdentifier"), 
      object       = paste0(lltData$code),
      objectType   = "literal", 
      datatype_uri = paste0(XSD,"string")
  ))
  
  # pt Code witin llt sheet
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject      = paste0(MDRA, paste0("LLT", lltData$code)), 
      predicate    = paste0(MDRA,  "hasPT"), 
      object       = paste0(MDRA, "PT", lltData$PT_code)
  ))

})  #--- End llt triples


###--- pt Creation ---
##ddply(ptData, .(rowID), function(ptData)
##{
##  
##  addStatement(model, 
##    new("Statement", world=world,                                                    
##      subject   = paste0(MDRA, paste0("PT", ptData$code)), 
##      predicate = paste0(RDF,  "type"), 
##      object    = paste0(SKOS, "Concept")
##  ))
##  addStatement(model, 
##    new("Statement", world=world,                                                    
##      subject   = paste0(MDRA, paste0("PT", ptData$code)), 
##      predicate = paste0(RDF,  "type"), 
##      object    = paste0(MDRA, "PreferredConcept")
##  ))
##  addStatement(model, 
##    new("Statement", world=world,                                                    
##      subject         = paste0(MDRA, paste0("PT", ptData$code)), 
##        predicate     = paste0(SKOS,  "prefLabel"), 
##        object        = ptData$label,
##        objectType    = "literal", 
##        datatype_uri  = paste0(XSD,"string")
##  ))
##  addStatement(model, 
##    new("Statement", world=world,                                                    
##      subject   = paste0(MDRA, paste0("PT", ptData$code)), 
##      predicate = paste0(MDRA,  "hasIdentifier"), 
##      object    = ptData$code,
##      objectType="literal", 
##      datatype_uri=paste0(XSD,"string")
##  ))
##  
##  addStatement(model, 
##    new("Statement", world=world,                                                    
##      subject   = paste0(MDRA, paste0("PT", ptData$code)), 
##      predicate = paste0(MDRA,  "hasHLT"), 
##      object    = paste0(MDRA, "HLT", ptData$SOC_codexxxxx)
##  ))
##
##  addStatement(model, 
##    new("Statement", world=world,                                                    
##      subject   = paste0(MDRA, paste0("PT", ptData$code)), 
##      predicate = paste0(MDRA, "hasPT"), 
##      object    = paste0(MDRA, "PT", "xxxxxxx")
##  ))
##}) #--- End of PT ---  
  
    
#--- Triple build complete ---

#--- Serialize the model to a TTL file ----------------------------------------
serializer <- new("Serializer", world, name="turtle", mimeType="text/turtle")

# Create the prefix list for the top of the TTL file. 
#   Do not move code from this location. 
for (i in 1:nrow(prefixList))
{
  status <- setNameSpace(serializer, world, 
                         namespace=prefixList[i, "url"], 
                         prefix=tolower(prefixList[i, "prefixUC"]) ) 
}  

filePath <- 'data/rdf/MedDRA211.TTL'
status <- serializeToFile(serializer, world, model, filePath)