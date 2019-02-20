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
'MEDDRA'  'https://w3id.org/phuse/MEDDRA21_1/'
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

#------------------------------------------------------------------------------
#--- llt ---
lltData <- read_excel("data/source/meddra/meddra.xlsx", 
                          sheet="llt")
# DEV Subset for testing
lltData <- subset(lltData, code==10003058)
lltData$rowID <- 1:nrow(lltData) # row index
# Replace column name spaces with _ 
names(lltData) <- gsub(" ", "_", names(lltData))

#------------------------------------------------------------------------------
#--- PT ---
ptData <- read_excel("data/source/meddra/meddra.xlsx", 
                     sheet="pt")
# DEV Subset for testing (match to ptcode in llt sheet)
ptData <- subset(ptData, code==10003041)

# Replace column name spaces with _ 
names(ptData) <- gsub(" ", "_", names(ptData))

# hlt_pt key table to obtain HLT code
hlt_ptKey <- read_excel("data/source/meddra/meddra.xlsx", 
                     sheet="hlt-pt")
names(hlt_ptKey) <- gsub(" ", "_", names(hlt_ptKey))

# DEV Subset for testing (match to ptcode in llt sheet)
hlt_ptKey <- subset(hlt_ptKey, PT_code==10003041)

# Merge in the HLT code to the PT dataframe
ptData <- merge(ptData, hlt_ptKey, by.x="code", by.y="PT_code", all=FALSE)
ptData$rowID <- 1:nrow(ptData) # row index


#------------------------------------------------------------------------------
#--- hlt ---
hltData <- read_excel("data/source/meddra/meddra.xlsx", 
                   sheet="hlt")
# DEV Subset for testing (match to ptcode in llt sheet)
#   Two codes matching from ptcode to hltcode!
hltData <- subset(hltData, code %in% c('10003057', '10015151'))
# hlgt_hlt key table to obtain HLT code
hlgt_hltKey <- read_excel("data/source/meddra/meddra.xlsx", 
                      sheet="hlgt-hlt")
names(hlgt_hltKey) <- gsub(" ", "_", names(hlgt_hltKey))
# DEV Subset for testing (match to ptcode in llt sheet)
hlgt_hltKey <- subset(hlgt_hltKey, HLT_code %in% c('10003057', '10015151'))
# Merge in the HLGT code to the htl dataframe
hltData <- merge(hltData, hlgt_hltKey, by.x="code", by.y="HLT_code", all=FALSE)
hltData$rowID <- 1:nrow(hltData) # row index

#--- hlgt ---
hlgtData <- read_excel("data/source/meddra/meddra.xlsx", 
                      sheet="hlgt")
# DEV Subset for testing (match to ptcode in llt sheet)
#   Two codes matching from ptcode to hltcode!
hlgtData <- subset(hlgtData, code %in% c('10001316', '10014982'))

# soc_hglt key table to obtain HLT code
soc_hlgtKey <- read_excel("data/source/meddra/meddra.xlsx", 
                          sheet="soc-hlgt")
names(soc_hlgtKey) <- gsub(" ", "_", names(soc_hlgtKey))
# DEV Subset for testing (match to ptcode in llt sheet)
soc_hlgtKey <- subset(soc_hlgtKey, HGLT_code %in% c('10001316', '10014982'))

# Merge in the HLGT code to the htl dataframe
hlgtData <- merge(hlgtData, soc_hlgtKey, by.x="code", by.y="HGLT_code", all=FALSE)
hlgtData$rowID <- 1:nrow(hlgtData) # row index


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#TW DEV BELOW HERE
#--- soc ---
socData <- read_excel("data/source/meddra/meddra.xlsx", 
                       sheet="soc")
# DEV Subset for testing (match to ptcode in llt sheet)
#   Two codes matching from ptcode to hltcode!
socData <- subset(socData, code %in% c('10018065', '10022117', '10040785'))
socData$rowID <- 1:nrow(socData) # row index

#------------------------------------------------------------------------------
#--- RDF Creation Statements --------------------------------------------------
#--- LLT Creation ---
ddply(lltData, .(rowID), function(lltData)
{
  
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", lltData$code)), 
      predicate = paste0(RDF,  "type"), 
      object    = paste0(MEDDRA, "LowLevelConcept")
  ))
  
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject      = paste0(MEDDRA, paste0("m", lltData$code)), 
      predicate    = paste0(SKOS,  "prefLabel"), 
      object       = paste0(lltData$label),
      objectType   = "literal", 
      datatype_uri = paste0(XSD,"string")
  ))
  # Identifier as a string xsd:string 
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject      = paste0(MEDDRA, paste0("m", lltData$code)), 
      predicate    = paste0(MEDDRA,  "hasIdentifier"), 
      object       = paste0(lltData$code),
      objectType   = "literal", 
      datatype_uri = paste0(XSD,"string")
  ))
  
  # pt Code witin llt sheet
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject      = paste0(MEDDRA, paste0("m", lltData$code)), 
      predicate    = paste0(MEDDRA,  "hasPT"), 
      object       = paste0(MEDDRA, "m", lltData$PT_code)
  ))

})  #--- End llt triples


###--- pt Creation ---
ddply(ptData, .(rowID), function(ptData)
{
  
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", ptData$code)), 
      predicate = paste0(RDF,  "type"), 
      object    = paste0(SKOS, "Concept")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", ptData$code)), 
      predicate = paste0(RDF,  "type"), 
      object    = paste0(MEDDRA, "PreferredConcept")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject         = paste0(MEDDRA, paste0("m", ptData$code)), 
        predicate     = paste0(SKOS,  "prefLabel"), 
        object        = ptData$label,
        objectType    = "literal", 
        datatype_uri  = paste0(XSD,"string")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", ptData$code)), 
      predicate = paste0(MEDDRA,  "hasIdentifier"), 
      object    = paste0(ptData$code),
      objectType="literal", 
      datatype_uri=paste0(XSD,"string")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", ptData$code)), 
      predicate = paste0(MEDDRA,  "hasHLT"), 
      object    = paste0(MEDDRA, "m", ptData$HLT_code)
  ))
}) #--- End of PT ---  
  
###--- hlt Creation ---
ddply(hltData, .(rowID), function(hltData)
{
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", hltData$code)), 
      predicate = paste0(RDF,  "type"), 
      object    = paste0(SKOS, "Concept")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", hltData$code)), 
      predicate = paste0(RDF,  "type"), 
      object    = paste0(MEDDRA, "HighLevelConcept")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", hltData$code)), 
      predicate     = paste0(SKOS,  "prefLabel"), 
      object        = hltData$label,
      objectType    = "literal", 
      datatype_uri  = paste0(XSD,"string")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", hltData$code)), 
      predicate = paste0(MEDDRA,  "hasIdentifier"), 
      object    = paste0(hltData$code),
      objectType="literal", 
      datatype_uri=paste0(XSD,"string")
  ))
  #TW POSSIBLE TYPO IN SOURCE XLS? HGLT_CODE should be HLGT? 
  addStatement(model, 
   new("Statement", world=world,                                                    
     subject   = paste0(MEDDRA, paste0("m", hltData$code)), 
     predicate = paste0(MEDDRA,  "hasHLGT"), 
     object    = paste0(MEDDRA, "m", hltData$HGLT_code)
  ))
}) #--- End of HLT ---  

###--- hlgt Creation ---
ddply(hlgtData, .(rowID), function(hlgtData)
{
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", hlgtData$code)), 
      predicate = paste0(RDF,  "type"), 
      object    = paste0(SKOS, "Concept")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", hlgtData$code)), 
      predicate = paste0(RDF,  "type"), 
      object    = paste0(MEDDRA, "HighLevelGroupConcept")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", hlgtData$code)), 
      predicate     = paste0(SKOS,  "prefLabel"), 
      object        = hlgtData$label,
      objectType    = "literal", 
      datatype_uri  = paste0(XSD,"string")
               ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", hlgtData$code)), 
      predicate = paste0(MEDDRA,  "hasIdentifier"), 
      object    = paste0(hlgtData$code),
      objectType="literal", 
      datatype_uri=paste0(XSD,"string")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", hlgtData$code)), 
      predicate = paste0(MEDDRA,  "hasSOC"), 
      object    = paste0(MEDDRA, "m", hlgtData$SOC_code)
               ))
}) #--- End of HLGT ---  


#--- soc Creation ---
ddply(socData, .(rowID), function(socData)
{
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", socData$code)), 
      predicate = paste0(RDF,  "type"), 
      object    = paste0(SKOS, "Concept")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", socData$code)), 
      predicate = paste0(RDF,  "type"), 
      object    = paste0(MEDDRA, "SystemOrganClassConcept")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject      = paste0(MEDDRA, paste0("m", socData$code)), 
      predicate    = paste0(SKOS,  "prefLabel"), 
      object       = socData$label,
      objectType   = "literal", 
      datatype_uri = paste0(XSD,"string")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject      = paste0(MEDDRA, paste0("m", socData$code)), 
      predicate    = paste0(SKOS,  "topConceptOf"), 
      object    = paste0(MEDDRA, "MedDRA")
  ))
  addStatement(model, 
    new("Statement", world=world,                                                    
      subject   = paste0(MEDDRA, paste0("m", socData$code)), 
      predicate = paste0(MEDDRA,  "hasIdentifier"), 
      object    = paste0(socData$code),
      objectType="literal", 
      datatype_uri=paste0(XSD,"string")
  ))
}) #--- End of SOC ---  



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