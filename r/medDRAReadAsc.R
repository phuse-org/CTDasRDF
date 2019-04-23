#______________________________________________________________________________
# FILE: medDRAReadAsc.R
# DESC:  Read the original .asc files from MedDRA into R dataframes for 
#        processing into RDF. Create TTL file using Redland.
# SRC :
# IN  : 
# OUT :  data/rdf/MedDRA211.TTL
# REQ : 
# SRC : 
# NOTE: addStatements are ordered alphabetically by predicate QNAM for ease of 
#         comparison during QA.
#       Construction: for subsetting values, see: /r/MedDRA_Subsetting_To_OntInstanceDatak.xlsx
# TESTING:  LLT: meddra:m10003851
# TODO:  Should MedDRA be : https://w3id.org/phuse/MEDDRA21_1/  or 
#        as is now: https://w3id.org/phuse/meddra#
#______________________________________________________________________________
library(redland)
library(plyr)

setwd("C:/_github/CTDasRDF")



#--- Subsetting ---------------------------------------------------------------
# If Y, subset the data to only the data present in the ontology instance data.
#  Subsetting is currently a MANUAL process, entering the code values into the 
#  script.
subsetFlag = "Y"

# Subsetting values for each files. This could later move to a configuration file
#  created as a result of a query against the ontology instance data. For now, 
#  enjoy this nasty manualkludge for values indentified in the Ontology
#  instance data.

# Note that 10003041 and 10003053 each map to TWO HLT codes.
#  pt        hlt
# 10003041	10003057
#           10015151
# 10003053	10049293
#           10003057

ptOntSubset <- c('10003041', 
                 '10003053',
                 '10003677',
                 '10012735',
                 '10015150'
                  )
# llt 
ltOntSubset <- c('10003047',
                 '10003058',
                 '10003851',
                 '10012727',
                 '10024781')
#  hlt
hltOntSubset <- c( '10000032',
                   '10003057',
                   '10012736',
                   '10015151',
                   '10049293')
# hlgt
hlgtOntSubset <- c( '10001316',
                    '10007521',
                    '10014982',
                    '10017977')
# soc
socOntSubset <- c('10007541',
                  '10017947',
                  '10018065',
                  '10022117',
                  '10040785')

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
#'  readAscFile(ascFile="HLGT-pt",  colNames=c("HLGT_code", "HLT_code"))
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
model <- new("Model", world = world, storage, options="")

# Dataframe of prefix assignments . Dataframe used for ease of data entry. 
#   May later change to external file?
prefixList <-read.table(header = TRUE, text = "
  prefixUC  url
  'MEDDRA'  'https://w3id.org/phuse/meddra#'
  'RDF'     'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
  'RDFS'    'http://www.w3.org/2000/01/rdf-schema#'
  'SKOS'    'http://www.w3.org/2004/02/skos/core#'
  'XSD'     'http://www.w3.org/2001/XMLSchema#'  "
)                         

# Transform the df of prefixes and values into variable names and their values
#   for use within the redland statements.
prefixUC        <- as.list(prefixList$url)
names(prefixUC) <- as.list(prefixList$prefixUC)
list2env(prefixUC , envir = .GlobalEnv)

#--- Read (and subset Source Data ---------------------------------------------

#------------------------------------------------------------------------------
#--- llt ---
lltData <- readAscFile(ascFile="llt", colNames=c("code", "label", "PT_code"))

# Subset
if(subsetFlag == "Y"){ lltData <- subset(lltData, code  %in% ltOntSubset) }
  
lltData$rowID <- 1:nrow(lltData) # row index

#--- pt ---
ptData <- readAscFile(ascFile="pt", colNames=c("code", "label", "SOC_code"))

# Subset
if(subsetFlag == "Y"){ ptData <- subset(ptData, code %in% ptOntSubset )}

ptData$rowID <- 1:nrow(ptData) # row index  

#--- hlt ---
hltData <- readAscFile(ascFile="hlt", colNames=c("code", "label"))

# Subset
if(subsetFlag == "Y"){hltData <- subset(hltData, code %in% hltOntSubset)}

hltData$rowID <- 1:nrow(hltData) # row index  

#--- hlt_pt ---
hlt_ptKey <- readAscFile(ascFile="hlt_pt", colNames=c("HLT_code", "PT_code"))

#DEV  Subset for testing
# Uses same subset as the subsetting of pt earlier
hlt_ptKey <- subset(hlt_ptKey, PT_code %in% ptOntSubset)
hlt_ptKey$rowID <- 1:nrow(hlt_ptKey) # row index  

# Merge in the HLT code to the PT dataframe
ptData <- merge(ptData, hlt_ptKey, by.x="code", by.y="PT_code", all=FALSE)
ptData$rowID <- 1:nrow(ptData) # row index

# hlgt_hlt 
#   key table to obtain HLT code
hlgt_hltKey <- readAscFile(ascFile="hlgt_hlt", colNames=c("HLGT_code", "HLT_code"))

# DEV Subset for testing (match to ptcode in llt sheet)
# Uses same subset as the subsetting of pt earlier
hlgt_hltKey <- subset(hlgt_hltKey, HLT_code %in% hltOntSubset)

# Merge in the HLGT code to the htl dataframe
hltData <- merge(hltData, hlgt_hltKey, by.x="code", by.y="HLT_code", all=FALSE)
hltData$rowID <- 1:nrow(hltData) # row index

#--- hlgt ---
hlgtData <- readAscFile(ascFile="hlgt", colNames=c("code", "label"))

# Subset
if(subsetFlag == "Y"){hlgtData <- subset(hlgtData, code %in% hlgtOntSubset)}

# soc_HLGT key table to obtain HLT code
soc_hlgtKey <- readAscFile(ascFile="soc_hlgt", colNames=c("SOC_code", "HLGT_code")) 

# DEV Subset for testing (match to ptcode in llt sheet)
# Uses same subset as the subsetting of hlgt earlier
soc_hlgtKey <- subset(soc_hlgtKey, HLGT_code %in% hlgtOntSubset)

# Merge in the HLGT code to the hlt dataframe
hlgtData <- merge(hlgtData, soc_hlgtKey, by.x="code", by.y="HLGT_code", all=FALSE)
hlgtData$rowID <- 1:nrow(hlgtData) # row index

#--- soc ---
socData <- readAscFile(ascFile="soc", colNames=c("code", "label", "short"))

# Subset
if(subsetFlag == "Y"){ socData <- subset(socData, code %in% socOntSubset) }
socData$rowID <- 1:nrow(socData) # row index

#------------------------------------------------------------------------------
#--- RDF Creation Statements --------------------------------------------------

#--- 1. LLT Creation ---
ddply(lltData, .(rowID), function(lltData)
{
  
  # Identifier as a string xsd:string 
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject      = paste0(MEDDRA, paste0("m", lltData$code)), 
                   predicate    = paste0(MEDDRA,  "hasIdentifier"), 
                   object       = paste0(lltData$code),
                   objectType   = "literal", 
                   datatype_uri = paste0(XSD,"string")
               ))
  # pt Code witin llt sheet
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject      = paste0(MEDDRA, paste0("m", lltData$code)), 
                   predicate    = paste0(MEDDRA,  "hasPT"), 
                   object       = paste0(MEDDRA, "m", lltData$PT_code)
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", lltData$code)), 
                   predicate = paste0(RDF,  "type"), 
                   object    = paste0(MEDDRA, "LowLevelConcept")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", lltData$code)), 
                   predicate = paste0(RDF,  "type"), 
                   object    = paste0(MEDDRA, "MeddraConcept")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", lltData$code)), 
                   predicate = paste0(RDF,  "type"), 
                   object    = paste0(RDFS, "Resource")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject      = paste0(MEDDRA, paste0("m", lltData$code)), 
                   predicate    = paste0(RDF,  "type"), 
                   object       = paste0(SKOS, "Concept")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject      = paste0(MEDDRA, paste0("m", lltData$code)), 
                   predicate    = paste0(RDFS,  "label"), 
                   object       = paste0(lltData$label),
                   objectType   = "literal", 
                   datatype_uri = paste0(XSD,"string")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject      = paste0(MEDDRA, paste0("m", lltData$code)), 
                   predicate    = paste0(SKOS,  "prefLabel"), 
                   object       = paste0(lltData$label),
                   objectType   = "literal", 
                   datatype_uri = paste0(XSD,"string")
               ))
})  #--- End llt triples


###--- 2. pt Creation ---
ddply(ptData, .(rowID), function(ptData)
{
  
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", ptData$code)), 
                   predicate = paste0(RDF,  "type"), 
                   object    = paste0(SKOS, "Concept")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", ptData$code)), 
                   predicate = paste0(RDF,  "type"), 
                   object    = paste0(MEDDRA, "PreferredConcept")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject         = paste0(MEDDRA, paste0("m", ptData$code)), 
                   predicate     = paste0(SKOS,  "prefLabel"), 
                   object        = ptData$label,
                   objectType    = "literal", 
                   datatype_uri  = paste0(XSD,"string")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject      = paste0(MEDDRA, paste0("m", ptData$code)), 
                   predicate    = paste0(MEDDRA,  "hasIdentifier"), 
                   object       = paste0(ptData$code),
                   objectType   ="literal", 
                   datatype_uri = paste0(XSD,"string")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", ptData$code)), 
                   predicate = paste0(MEDDRA,  "hasHLT"), 
                   object    = paste0(MEDDRA, "m", ptData$HLT_code)
               ))
}) #--- End of PT ---  

###--- 3. hlt Creation ---
ddply(hltData, .(rowID), function(hltData)
{
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", hltData$code)), 
                   predicate = paste0(RDF,  "type"), 
                   object    = paste0(SKOS, "Concept")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", hltData$code)), 
                   predicate = paste0(RDF,  "type"), 
                   object    = paste0(MEDDRA, "HighLevelConcept")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject       = paste0(MEDDRA, paste0("m", hltData$code)), 
                   predicate     = paste0(SKOS,  "prefLabel"), 
                   object        = hltData$label,
                   objectType    = "literal", 
                   datatype_uri  = paste0(XSD,"string")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject      = paste0(MEDDRA, paste0("m", hltData$code)), 
                   predicate    = paste0(MEDDRA,  "hasIdentifier"), 
                   object       = paste0(hltData$code),
                   objectType   ="literal", 
                   datatype_uri = paste0(XSD,"string")
               ))
  #TW POSSIBLE TYPO IN SOURCE XLS? HLGT_CODE should be HLGT? 
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", hltData$code)), 
                   predicate = paste0(MEDDRA,  "hasHLGT"), 
                   object    = paste0(MEDDRA, "m", hltData$HLGT_code)
               ))
}) #--- End of HLT ---  

###--- 4. hlgt Creation ---
ddply(hlgtData, .(rowID), function(hlgtData)
{
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", hlgtData$code)), 
                   predicate = paste0(RDF,  "type"), 
                   object    = paste0(SKOS, "Concept")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", hlgtData$code)), 
                   predicate = paste0(RDF,  "type"), 
                   object    = paste0(MEDDRA, "HighLevelGroupConcept")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject      = paste0(MEDDRA, paste0("m", hlgtData$code)), 
                   predicate    = paste0(SKOS,  "prefLabel"), 
                   object       = hlgtData$label,
                   objectType   = "literal", 
                   datatype_uri = paste0(XSD,"string")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject      = paste0(MEDDRA, paste0("m", hlgtData$code)), 
                   predicate    = paste0(MEDDRA,  "hasIdentifier"), 
                   object       = paste0(hlgtData$code),
                   objectType   = "literal", 
                   datatype_uri = paste0(XSD,"string")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", hlgtData$code)), 
                   predicate = paste0(MEDDRA,  "hasSOC"), 
                   object    = paste0(MEDDRA, "m", hlgtData$SOC_code)
               ))
}) #--- End of HLGT ---  


#--- 5. soc Creation ---
ddply(socData, .(rowID), function(socData)
{
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", socData$code)), 
                   predicate = paste0(RDF,  "type"), 
                   object    = paste0(SKOS, "Concept")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", socData$code)), 
                   predicate = paste0(RDF,  "type"), 
                   object    = paste0(MEDDRA, "SystemOrganClassConcept")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject      = paste0(MEDDRA, paste0("m", socData$code)), 
                   predicate    = paste0(SKOS,  "prefLabel"), 
                   object       = socData$label,
                   objectType   = "literal", 
                   datatype_uri = paste0(XSD,"string")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject   = paste0(MEDDRA, paste0("m", socData$code)), 
                   predicate = paste0(SKOS,  "topConceptOf"), 
                   object    = paste0(MEDDRA, "MedDRA")
               ))
  addStatement(model, 
               new("Statement", world = world,                                                    
                   subject      = paste0(MEDDRA, paste0("m", socData$code)), 
                   predicate    = paste0(MEDDRA,  "hasIdentifier"), 
                   object       = paste0(socData$code),
                   objectType   = "literal", 
                   datatype_uri = paste0(XSD,"string")
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
                         namespace = prefixList[i, "url"], 
                         prefix = tolower(prefixList[i, "prefixUC"]) ) 
}  

filePath <- 'data/rdf/MedDRA211-R.TTL'
status <- serializeToFile(serializer, world, model, filePath)