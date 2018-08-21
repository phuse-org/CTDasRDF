#______________________________________________________________________________
# FILE: EX_imputeCSV.R
# DESC: Creates data values required for prototyping and ontology develeopment
# REQ : Prior import of the EX domain by driver script XPTtoCSV.R
# SRC : N/A
# IN  : ex dataframe 
# OUT : modified ex dataframe 
# NOTE:  Column names with _im, _im_en, _en are imputed, encoded from orig vals. 
# TODO: visit recode move to function, share with VS,EX and other domains...
#______________________________________________________________________________

# Imputations ----
ex$fixDoseInt_im        <- paste0(ex$exstdtc,  "_", ex$exendtc)    # Interval
ex$fixDoseInt_label_im  <- paste0(ex$exstdtc,  " to ", ex$exendtc) # Interval Label


# visit to Camel Case Short form for linking  IRIs to ont.
ex <- ex %>%
  mutate(visit_im_titleCSh = recode(visit,
   'SCREENING 1'          =  'Screening1' ,
    'SCREENING 2'         =  'Screening2' ,
    'BASELINE'            =  'Baseline' ,
    'AMBUL ECG PLACEMENT' =  'AmbulECGPlacement' ,
    'AMBUL ECG REMOVAL'   =  'AmbulECGRemoval' ,
    'WEEK 2'              =  'Wk2' ,
    'WEEK 4'              =  'Wk4' ,
    'WEEK 6'              =  'Wk6' ,
    'WEEK 8'              =  'Wk8' ,
    'WEEK 12'             =  'Wk12' ,
    'WEEK 16'             =  'Wk16' ,
    'WEEK 20'             =  'Wk20' ,
    'WEEK 24'             =  'Wk24' ,
    'WEEK 26'             =  'Wk26' ,
    'RETRIEVAL'           =  'Retrieval' ,
    'UNSCHEDULED 3.1'     =  'Unscheduled31' 
  ))


# visit as Title case for use in skos:prefLabel
ex <- ex %>%
  mutate(visit_im_titleC = recode(visit,
    'SCREENING 1'          =  'Screening 1' ,
    'SCREENING 2'          =  'Screening 2' ,
    'BASELINE'             =  'Baseline' ,
    'AMBUL ECG PLACEMENT'  =  'Ambul ECG Placement' ,
    'AMBUL ECG REMOVAL'    =  'Ambul ECG Removal' ,
    'WEEK 2'               =  'Week 2' ,
    'WEEK 4'               =  'Week 4' ,
    'WEEK 6'               =  'Week 6' ,
    'WEEK 8'               =  'Week 8' ,
    'WEEK 12'              =  'Week 12' ,
    'WEEK 16'              =  'Week 16' ,
    'WEEK 20'              =  'Week 20' ,
    'WEEK 24'              =  'Week 24' ,
    'WEEK 26'              =  'Week 26' ,
    'RETRIEVAL'            =  'Retrieval' ,
    'UNSCHEDULED 3.1'      =  'Unscheduled 3.1' 
))

#------------------------------------------------------------------------------
# URL encoding
#   Encode fields  that may potentially have values that violate valid IRI format
#
ex <- encodeCol(data=ex, col="exstdtc")
ex <- encodeCol(data=ex, col="exendtc")
ex <- encodeCol(data=ex, col="exroute")
ex <- encodeCol(data=ex, col="fixDoseInt_im", removeCol=TRUE)

# Low/High dose assigned to Product_1/_2 as per AO 21JUN18
ex[ex$extrt == "PLACEBO", "extrt_exdose_im"]                      <- "PlaceboDrug"
ex[ex$extrt == "XANOMELINE" & ex$exdose == 54, "extrt_exdose_im"]  <- "Product_1"
ex[ex$extrt == "XANOMELINE" & ex$exdose == 81, "extrt_exdose_im"]  <- "Product_2"

# Sort column names in the df for quicker referencing
ex <- ex %>% select(noquote(order(colnames(ex))))