#______________________________________________________________________________
# FILE: medDRAReadAsc.R
# DESC:  Read the original .asc files from MedDRA into R dataframes for 
#        processing into RDF.
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
#______________________________________________________________________________
library(redland)
library(plyr)

setwd("C:/_github/CTDasRDF")

#--- FUNCTIONS ----------------------------------------------------------------

#' Read MedDRA asc files.
#' 
#'
#' @param ascFile  File name, no extension
#' @param colNames Column names in the order they appear in the source file
#'                 These names are created by the team and may not be the 
#'                 official MSSO names! Named using underbar instead of spaces.
#' @return R dataframe with only the column names listed in the function call.
#'
#' @examples
#'  readAscFile(ascFile="soc",      colNames=c("code", "label", "short"))
#'  readAscFile(ascFile="hlgt",     colNames=c("code", "label"))
#'  readAscFile(ascFile="hlt",      colNames=c("code", "label"))
#'  readAscFile(ascFile="pt",       colNames=c("code", "label", "SOC_code"))
#'  readAscFile(ascFile="llt",      colNames=c("code", "label", "PT_code"))
#'  readAscFile(ascFile="soc_hlgt", colNames=c("SOC_code", "HLGT_code"))
#'  readAscFile(ascFile="HLGT-pt",   colNames=c("HLGT_code", "HLT_code"))
#'  readAscFile(ascFile="hlt_pt",   colNames=c("HLT_code", "PT_code"))
#' 
readAscFile <- function(ascFile, colNames)
{
  sourceFile <- paste0("data/medDRA/meddra_21_1_english/MedAscii/", ascFile, ".asc")

  result <- read.delim2(sourceFile, 
              header = FALSE, 
              sep = "$", 
              quote = "\"")
  
  names(result) <- colNames
  #cols <- colnames(result)
  # Remove "missing" columns (.. in name) and the PREREQUISITE column that is only
  #    present in SDTM and ADAM.
  result <- result[,colNames]  
  
} 

# Scope the model for Redland
world <- new("World")
# In-memory hashes as mechanism to store models. (convenient for small models, may not scale)
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
lltData <- readAscFile(ascFile="llt", colNames=c("code", "label", "PT_code"))
#DEV  Subset for testing
lltData <- subset(lltData, code==10003058)
lltData$rowID <- 1:nrow(lltData) # row index

#--- pt ---
ptData <- readAscFile(ascFile="pt", colNames=c("code", "label", "SOC_code"))
#DEV  Subset for testing
ptData <- subset(ptData, code==10003041)
ptData$rowID <- 1:nrow(ptData) # row index  

#--- hlt ---
hltData <- readAscFile(ascFile="hlt", colNames=c("code", "label"))
# Two codes matching from ptcode to hltcode!
hltData <- subset(hltData, code %in% c('10003057', '10015151'))
hltData$rowID <- 1:nrow(hltData) # row index  

#--- hlt_pt ---
hlt_ptKey <- readAscFile(ascFile="hlt_pt", colNames=c("HLT_code", "PT_code"))
#DEV  Subset for testing
hlt_ptKey <- subset(hlt_ptKey, PT_code==10003041)
hlt_ptKey$rowID <- 1:nrow(hlt_ptKey) # row index  

# Merge in the HLT code to the PT dataframe
ptData <- merge(ptData, hlt_ptKey, by.x="code", by.y="PT_code", all=FALSE)
ptData$rowID <- 1:nrow(ptData) # row index

# hlgt_hlt key table to obtain HLT code
hlgt_hltKey <- readAscFile(ascFile="hlgt_hlt", colNames=c("HLGT_code", "HLT_code"))

# DEV Subset for testing (match to ptcode in llt sheet)
hlgt_hltKey <- subset(hlgt_hltKey, HLT_code %in% c('10003057', '10015151'))

# Merge in the HLGT code to the htl dataframe
hltData <- merge(hltData, hlgt_hltKey, by.x="code", by.y="HLT_code", all=FALSE)
hltData$rowID <- 1:nrow(hltData) # row index

# NEW DEV BELOW HERE
#--- hlgt ---
hlgtData <- readAscFile(ascFile="hlgt", colNames=c("code", "label"))
# Two codes matching from ptcode to hltcode
hlgtData <- subset(hlgtData, code %in% c('10001316', '10014982'))

# soc_HLGT key table to obtain HLT code
soc_hlgtKey <- readAscFile(ascFile="soc_hlgt", colNames=c("SOC_code", "HLGT_code")) 
# DEV Subset for testing (match to ptcode in llt sheet)
soc_hlgtKey <- subset(soc_hlgtKey, HLGT_code %in% c('10001316', '10014982'))

# Merge in the HLGT code to the htl dataframe
hlgtData <- merge(hlgtData, soc_hlgtKey, by.x="code", by.y="HLGT_code", all=FALSE)
hlgtData$rowID <- 1:nrow(hlgtData) # row index

#--- soc ---
socData <- readAscFile(ascFile="soc", colNames=c("code", "label", "short"))
#DEV   Two codes matching from ptcode to hltcode!
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
  #TW POSSIBLE TYPO IN SOURCE XLS? HLGT_CODE should be HLGT? 
  addStatement(model, 
               new("Statement", world=world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", hltData$code)), 
                   predicate = paste0(MEDDRA,  "hasHLGT"), 
                   object    = paste0(MEDDRA, "m", hltData$HLGT_code)
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