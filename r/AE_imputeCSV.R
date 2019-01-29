#______________________________________________________________________________
# FILE: AE_imputeCSV.R
# DESC: 
#       
#       
# REQ : Prior import of the AE XPT file by driver script.
# SRC : N/A
# IN  : ae dataframe 
#       AE_supplemental.XLSX - supplemental data needed in the graph that is not
#         available in the original AE.XPT file.  NOTES column offers 
#         explanation of the values as needed.
# OUT : modified ae dataframe 
# NOTE: 
#       
#       
# REF :  
#        
# TODO: 
#       
#______________________________________________________________________________

# Data Corrections 

# Data not in original domain 
# aeAdditions <- read_excel("data/source/AE_supplemental.xlsx", col_names=TRUE)
# aeAdditions <- aeAdditions[, !(names(aeAdditions) == 'NOTES')] # Drop the notes column (explation of data)


# Kludge: All to char prior to bind
ae <- data.frame(lapply(ae, as.character), stringsAsFactors=FALSE)

#aeAdditions <- data.frame(lapply(aeAdditions, as.character), stringsAsFactors=FALSE)

ae$aeseq_im <- seq.int(nrow(ae)) # sequence id used in creating AE URIs

ae$aedecod_en


# Many additional values needed for IRI creation. In future, could simply hash all the source values?
ae <- ae %>%    
  mutate(aedecod_im = recode(aedecod,
    'APPLICATION SITE ERYTHEMA'            =  'AppSiteErythema' ,
    'APPLICATION SITE PRURITUS'            =  'AppSitePruritus' ,
    'ATRIOVENTRICULAR BLOCK SECOND DEGREE' =  'AVBlock2ndDeg' ,
    'DIARRHOEA '                           =  'Diarrhoea' ,
    'ERYTHEMA'                             =  'Erythema' 
  ))


# impute meddra LLT number portion from aellt
ae <- ae %>%    
  mutate(aellt_meddraN_im = recode(aellt,
    'APPLICATION SITE ERYTHEMA' =  '10003041',
    'APPLICATION SITE REDNESS'  =  '10003058',
    'APPLICATION SITE ITCHING'  =  '10003047',
    'AV BLOCK SECOND DEGREE'    =  '10003851',
    'DIARRHEA'                  =  '10012727',
    'ERYTHEMA'                  =  '10015150',
    'LOCALIZED ERYTHEMA'        =  '10024781' 
  ))

# aegrpid
ae <- ae %>%    
  mutate(aegrpid_im = recode(usubjid,
    '01-701-1015' = 'GRP1',
    '01-701-1023' = 'GRP2',
    '01-701-1028' = 'GRP3'
  ))

# Category and subcategory
ae$aecat_im  <- "CAT1"
ae$aescat_im <- "SCAT1"


# impute aellt portion of meddra IRI
ae <- ae %>%    
  mutate(aellt_im = recode(aellt,
    'APPLICATION SITE ERYTHEMA' =  'AppSiteErythema',
    'APPLICATION SITE REDNESS'  =  'AppSiteRedness', 
    'APPLICATION SITE ITCHING'  =  'AppSiteItching',
    'AV BLOCK SECOND DEGREE'    =  'AVBlock',
    'DIARRHEA'                  =  'Diarrhea',
    'ERYTHEMA'                  =  'Erythema',
    'LOCALIZED ERYTHEMA'        =  'LocErythema' 
  ))


# title case imputations for use in IRIs
# Causality
ae$aerel_im_titleC <- gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", ae$aerel, perl=TRUE)  


# Recoding of select existing values to facilitate testing.
ae[ae$aeseq_im < 10, "aeacn"] <- "none"
ae[ae$aeseq_im == 6, "aeacn"] <- "dose reduced"

vs[vs$vsseq == 86  & vs$usubjid == "01-701-1015", "vsspid_im"]  <- "124"


#aeAll<-dplyr::bind_rows(ae, aeAdditions)

# Sort column names in the df for quicker referencing
ae <- ae %>% select(noquote(order(colnames(ae))))

