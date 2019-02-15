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
library(redland)
# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

# World is the redland mechanism for scoping models
world <- new("World")
# Storage provides a mechanism to store models; in-memory hashes are convenient for small models
storage <- new("Storage", world, "hashes", name="", options="hash-type='memory'")
# A model is a set of Statements, and is associated with a particular Storage instance
model <- new("Model", world=world, storage, options="")

# Various prefixes for use in addStatement fnt
CODE <- "https://w3id.org/phuse/code#"
MDRA <- "http://foo.bar.org/ontology/MEDDRA/"
RDF  <- "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
RDFS <- "http://www.w3.org/2000/01/rdf-schema#"
SKOS <- "http://www.w3.org/2004/02/skos/core#"
XSD  <- "http://www.w3.org/2001/XMLSchema#"


addStatement(model, 
  new("Statement", world=world,                                                    
    subject   = paste0(MDRA, "LLT10003058_AppSiteRedness"), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(MDRA, "LowLevelConcept")
))

# identifier as a string xsd:string 
addStatement(model, 
  new("Statement", world=world,                                                    
    subject   = paste0(MDRA, "LLT10003058_AppSiteRedness"), 
    predicate = paste0(SKOS,  "prefLabel"), 
    object    = paste0("APPLICATION SITE ERYTHEMA"),
    objectType="literal", 
    datatype_uri=paste0(XSD,"string")
))

# identifier as a string xsd:string 
addStatement(model, 
  new("Statement", world=world,                                                    
    subject   = paste0(MDRA, "LLT10003058_AppSiteRedness"), 
    predicate = paste0(CODE,  "hasIdentifier"), 
    object    = paste0("10003508"),
    objectType="literal", 
    datatype_uri=paste0(XSD,"string")
))


#Serialize the model to a TTL file
serializer <- new("Serializer", world, name="turtle", mimeType="text/turtle")

status <- setNameSpace(serializer, world, namespace=CODE, prefix="code")  
status <- setNameSpace(serializer, world, namespace=MDRA, prefix="mdra")  
status <- setNameSpace(serializer, world, namespace=RDF, prefix="rdf")
status <- setNameSpace(serializer, world, namespace=RDFS, prefix="rdfs")  
status <- setNameSpace(serializer, world, namespace=SKOS, prefix="skos")  
status <- setNameSpace(serializer, world, namespace=XSD, prefix="xsd")  


filePath <- 'data/rdf/MedDRA211.TTL'
status <- serializeToFile(serializer, world, model, filePath)
