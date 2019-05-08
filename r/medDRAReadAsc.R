#______________________________________________________________________________
# FILE: medDRAReadAsc.R
# DESC: Read the source .asc files from MedDRA into R dataframes for 
#         processing into RDF. 
#       Create TTL file.
# SRC : 
# IN  : *.asc MedDRA files from MSSO
# OUT : data/rdf/MedDRA211-R.TTL
# REQ : 
# SRC : 
# NOTE: rdf_add statements ordered alphabetically by predicate QNAM for ease of 
#         comparison with ordered QA query results.
#       Use of for loop instead of ddply. Looping with ddply may be incompatible
#         with rdflib?
# TESTING:  LLT: meddra:m10003851
#
#
# TODO:  Should MedDRA be : https://w3id.org/phuse/MEDDRA21_1/  or 
#        as is now: https://w3id.org/phuse/meddra#
#
# BY: TW
# MOD: KG - update subsetFlag usage at some points, include altLabel definition, 
#           direct prefix definitions
#______________________________________________________________________________
library(rdflib)
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
#   for use within the rdf_add statements.
prefixUC        <- as.list(prefixList$url)
names(prefixUC) <- as.list(prefixList$prefixUC)
list2env(prefixUC , envir = .GlobalEnv)

#--- Read (and optionally subset) Source Data ---------------------------------
#------------------------------------------------------------------------------
#--- llt ---
lltData <- readAscFile(ascFile="llt", colNames=c("code", "label", "PT_code"))

# Subset
if(subsetFlag == "Y"){ lltData <- subset(lltData, code  %in% ltOntSubset) }

lltData$rowID <- 1:nrow(lltData) # row index
lltData$ulabel <- toupper(lltData$label) # upcase label

#--- pt ---
ptData <- readAscFile(ascFile="pt", colNames=c("code", "label", "SOC_code"))

# Subset
if(subsetFlag == "Y"){ ptData <- subset(ptData, code %in% ptOntSubset )}

ptData$rowID <- 1:nrow(ptData) # row index  
ptData$ulabel <- toupper(ptData$label) # upcase label

#--- hlt ---
hltData <- readAscFile(ascFile="hlt", colNames=c("code", "label"))

# Subset
if(subsetFlag == "Y"){hltData <- subset(hltData, code %in% hltOntSubset)}

hltData$rowID <- 1:nrow(hltData) # row index  
hltData$ulabel <- toupper(hltData$label) # upcase label

#--- hlt_pt ---
hlt_ptKey <- readAscFile(ascFile="hlt_pt", colNames=c("HLT_code", "PT_code"))

#DEV  Subset for testing
# Uses same subset as the subsetting of pt earlier
if(subsetFlag == "Y"){hlt_ptKey <- subset(hlt_ptKey, PT_code %in% ptOntSubset)}
hlt_ptKey$rowID <- 1:nrow(hlt_ptKey) # row index  

# Merge in the HLT code to the PT dataframe
ptData <- merge(ptData, hlt_ptKey, by.x="code", by.y="PT_code", all=FALSE)
ptData$rowID <- 1:nrow(ptData) # row index

# hlgt_hlt 
#   key table to obtain HLT code
hlgt_hltKey <- readAscFile(ascFile="hlgt_hlt", colNames=c("HLGT_code", "HLT_code"))

# DEV Subset for testing (match to ptcode in llt sheet)
# Uses same subset as the subsetting of pt earlier
if(subsetFlag == "Y"){hlgt_hltKey <- subset(hlgt_hltKey, HLT_code %in% hltOntSubset)}

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
if(subsetFlag == "Y"){soc_hlgtKey <- subset(soc_hlgtKey, HLGT_code %in% hlgtOntSubset)}

# Merge in the HLGT code to the hlt dataframe
hlgtData <- merge(hlgtData, soc_hlgtKey, by.x="code", by.y="HLGT_code", all=FALSE)
hlgtData$rowID <- 1:nrow(hlgtData) # row index
hlgtData$ulabel <- toupper(hlgtData$label) # upcase label

#--- soc ---
socData <- readAscFile(ascFile="soc", colNames=c("code", "label", "short"))

# Subset
if(subsetFlag == "Y"){ socData <- subset(socData, code %in% socOntSubset) }
socData$rowID <- 1:nrow(socData) # row index
socData$ulabel <- toupper(socData$label) # upcase label

#------------------------------------------------------------------------------
#--- RDF Creation Statements --------------------------------------------------
some_rdf <- rdf()  # initialize 

MEDDRA <- "https://w3id.org/phuse/meddra#"
XSD <- "http://www.w3.org/2001/XMLSchema#"
RDF <- "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
SKOS <- "http://www.w3.org/2004/02/skos/core#"
RDFS <- "http://www.w3.org/2000/01/rdf-schema#"


#--- 1. LLT Creation ---
for(i in 1:nrow(lltData))
{
  # Identifier as a string xsd:string 
  rdf_add(some_rdf, 
    subject      = paste0(MEDDRA, paste0("m", lltData[i,"code"])), 
    predicate    = paste0(MEDDRA,  "hasIdentifier"), 
    object       = paste0(lltData[i,"code"]),
    objectType   = "literal", 
    datatype_uri = paste0(XSD,"string")
  )
  # pt Code witin llt sheet
  rdf_add(some_rdf, 
    subject      = paste0(MEDDRA, paste0("m", lltData[i,"code"])), 
    predicate    = paste0(MEDDRA,  "hasPT"), 
    object       = paste0(MEDDRA, "m", lltData[i,"PT_code"])
  )
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", lltData[i,"code"])), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(MEDDRA, "LowLevelConcept")
  )
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", lltData[i,"code"])), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(MEDDRA, "MeddraConcept")
  )
  
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", lltData[i,"code"])), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(RDFS, "Resource")
  )
  rdf_add(some_rdf, 
    subject      = paste0(MEDDRA, paste0("m", lltData[i,"code"])), 
    predicate    = paste0(RDF,  "type"), 
    object       = paste0(SKOS, "Concept")
  )
  rdf_add(some_rdf, 
    subject      = paste0(MEDDRA, paste0("m", lltData[i,"code"])), 
    predicate    = paste0(RDFS,  "label"), 
    object       = paste0(lltData[i,"label"]),
    objectType   = "literal", 
    datatype_uri = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
    subject      = paste0(MEDDRA, paste0("m", lltData[i,"code"])), 
    predicate    = paste0(SKOS,  "prefLabel"), 
    object       = paste0(lltData[i,"label"]),
    objectType   = "literal", 
    datatype_uri = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
          subject      = paste0(MEDDRA, paste0("m", lltData[i,"code"])), 
          predicate    = paste0(SKOS,  "altLabel"), 
          object       = paste0(lltData[i,"ulabel"]),
          objectType   = "literal", 
          datatype_uri = paste0(XSD,"string")
  )
}  #--- End llt triples


#--- 2. pt Creation ---
for(i in 1:nrow(ptData))
{
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", ptData[i,"code"])), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(SKOS, "Concept")
  )
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", ptData[i,"code"])), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(MEDDRA, "PreferredConcept")
  )
  rdf_add(some_rdf, 
    subject       = paste0(MEDDRA, paste0("m", ptData[i,"code"])), 
    predicate     = paste0(SKOS,  "prefLabel"), 
    object        = ptData[i,"label"],
    objectType    = "literal", 
    datatype_uri  = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
          subject       = paste0(MEDDRA, paste0("m", ptData[i,"code"])), 
          predicate     = paste0(SKOS,  "altLabel"), 
          object        = ptData[i,"ulabel"],
          objectType    = "literal", 
          datatype_uri  = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
    subject      = paste0(MEDDRA, paste0("m", ptData[i,"code"])), 
    predicate    = paste0(MEDDRA,  "hasIdentifier"), 
    object       = paste0(ptData[i,"code"]),
    objectType   ="literal", 
    datatype_uri = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", ptData[i,"code"])), 
    predicate = paste0(MEDDRA,  "hasHLT"), 
    object    = paste0(MEDDRA, "m", ptData[i,"HLT_code"])
  )
} #--- End of PT ---  

#--- 3. hlt Creation ---
for(i in 1:nrow(hltData))
{
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", hltData[i,"code"])), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(SKOS, "Concept")
  )
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", hltData[i,"code"])), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(MEDDRA, "HighLevelConcept")
  )
  rdf_add(some_rdf, 
    subject       = paste0(MEDDRA, paste0("m", hltData[i,"code"])), 
    predicate     = paste0(SKOS,  "prefLabel"), 
    object        = hltData[i,"label"],
    objectType    = "literal", 
    datatype_uri  = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
          subject       = paste0(MEDDRA, paste0("m", hltData[i,"code"])), 
          predicate     = paste0(SKOS,  "altLabel"), 
          object        = hltData[i,"ulabel"],
          objectType    = "literal", 
          datatype_uri  = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
    subject      = paste0(MEDDRA, paste0("m", hltData[i,"code"])), 
    predicate    = paste0(MEDDRA,  "hasIdentifier"), 
    object       = paste0(hltData[i,"code"]),
    objectType   ="literal", 
    datatype_uri = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", hltData[i,"code"])), 
    predicate = paste0(MEDDRA,  "hasHLGT"), 
    object    = paste0(MEDDRA, "m", hltData[i,"HLGT_code"])
  )
} #--- End of HLT ---  

#--- 4. hlgt Creation ---
for(i in 1:nrow(hlgtData))
{
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", hlgtData[i,"code"])), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(SKOS, "Concept")
  )
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", hlgtData[i,"code"])), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(MEDDRA, "HighLevelGroupConcept")
  )
  rdf_add(some_rdf, 
    subject      = paste0(MEDDRA, paste0("m", hlgtData[i,"code"])), 
    predicate    = paste0(SKOS,  "prefLabel"), 
    object       = hlgtData[i,"label"],
    objectType   = "literal", 
    datatype_uri = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
          subject      = paste0(MEDDRA, paste0("m", hlgtData[i,"code"])), 
          predicate    = paste0(SKOS,  "altLabel"), 
          object       = hlgtData[i,"ulabel"],
          objectType   = "literal", 
          datatype_uri = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
    subject      = paste0(MEDDRA, paste0("m", hlgtData[i,"code"])), 
    predicate    = paste0(MEDDRA,  "hasIdentifier"), 
    object       = paste0(hlgtData[i,"code"]),
    objectType   = "literal", 
    datatype_uri = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", hlgtData[i,"code"])), 
    predicate = paste0(MEDDRA,  "hasSOC"), 
    object    = paste0(MEDDRA, "m", hlgtData[i,"SOC_code"])
  )
} #--- End of HLGT ---  

#--- 5. soc Creation ---
for(i in 1:nrow(socData))
{
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", socData[i,"code"])), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(SKOS, "Concept")
  )
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", socData[i,"code"])), 
    predicate = paste0(RDF,  "type"), 
    object    = paste0(MEDDRA, "SystemOrganClassConcept")
  )
  rdf_add(some_rdf, 
    subject      = paste0(MEDDRA, paste0("m", socData[i,"code"])), 
    predicate    = paste0(SKOS,  "prefLabel"), 
    object       = socData[i,"label"],
    objectType   = "literal", 
    datatype_uri = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
          subject      = paste0(MEDDRA, paste0("m", socData[i,"code"])), 
          predicate    = paste0(SKOS,  "altLabel"), 
          object       = socData[i,"ulabel"],
          objectType   = "literal", 
          datatype_uri = paste0(XSD,"string")
  )
  rdf_add(some_rdf, 
    subject   = paste0(MEDDRA, paste0("m", socData[i,"code"])), 
    predicate = paste0(SKOS,  "topConceptOf"), 
    object    = paste0(MEDDRA, "MedDRA")
  )
  rdf_add(some_rdf, 
    subject      = paste0(MEDDRA, paste0("m", socData[i,"code"])), 
    predicate    = paste0(MEDDRA,  "hasIdentifier"), 
    object       = paste0(socData[i,"code"]),
    objectType   = "literal", 
    datatype_uri = paste0(XSD,"string")
  )
} #--- End of SOC ---  
#--- Triple build complete ---

#--- Serialize the some_rdf to a TTL file ----------------------------------------
outFile <- 'data/rdf/MedDRA211-R.TTL'

rdf_serialize(some_rdf,
              outFile,
              format = "turtle",
              namespace = c( meddra = "https://w3id.org/phuse/meddra#",
                             rdf    = "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                             rdfs   = "http://www.w3.org/2000/01/rdf-schema#",
                             skos   = "http://www.w3.org/2004/02/skos/core#",
                             xsd    = "http://www.w3.org/2001/XMLSchema#"
              ))