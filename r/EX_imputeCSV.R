#______________________________________________________________________________
# FILE: EX_imputeCSV.R
# DESC: Creates data values required for prototyping and ontology develeopment
# REQ : Prior import of the EX domain by driver script XPTtoCSV.R
# SRC : N/A
# IN  : dm dataframe 
# OUT : modified dm dataframe 
# NOTE: Columns that created that are not usually in SDTM are prefixed with im_
#       Eg: im_lifespan  - for lifespan IRI creation
#           im_sdtmterm  - to link to SDTM terminlology
#           brthdate  - no im_ prefix because this is often collected in SDTM.
# TODO: 
#______________________________________________________________________________

# Imputations ----
ex$fixDoseInt_im        <- paste0(ex$exstdtc,  "_", ex$exendtc)    # Interval
ex$fixDoseInt_label_im  <- paste0(ex$exstdtc,  " to ", ex$exendtc) # Interval Label

ex$visit_im_comp <- gsub(" ", "", ex$visit )

# Change following to function. Used in other domains!
# visit in Camel Case Short form for linking  IRIs to ont. Ont uses camel case
ex$visit_im_titleCSh <- car::recode(ex$visit,
  " 'SCREENING 1'          =  'Screening1' ;
    'SCREENING 2'          =  'Screening2' ;
    'BASELINE'             =  'Baseline' ;
    'AMBUL ECG PLACEMENT'  =  'AmbulECGPlacement' ;
    'AMBUL ECG REMOVAL'    =  'AmbulECGRemoval' ;
    'WEEK 2'               =  'Wk2' ;
    'WEEK 4'               =  'Wk4' ;
    'WEEK 6'               =  'Wk6' ;
    'WEEK 8'               =  'Wk8' ;
    'WEEK 12'              =  'Wk12' ;
    'WEEK 16'              =  'Wk16' ;
    'WEEK 20'              =  'Wk20' ;
    'WEEK 24'              =  'Wk24' ;
    'WEEK 26'              =  'Wk26' ;
    'RETRIEVAL'            =  'Retrieval' ;
    'UNSCHEDULED 3.1'      =  'Unscheduled31' "
)

# following used in prefLabel. 
# TODO: Change to casing function on vs$visit.
ex$visit_im_titleC  <- car::recode (ex$visit,
  " 'SCREENING 1'          =  'Screening 1' ;
    'SCREENING 2'          =  'Screening 2' ;
    'BASELINE'             =  'Baseline' ;
    'AMBUL ECG PLACEMENT'  =  'Ambul ECG Placement' ;
    'AMBUL ECG REMOVAL'    =  'Ambul ECG Removal' ;
    'WEEK 2'               =  'Week 2' ;
    'WEEK 4'               =  'Week 4' ;
    'WEEK 6'               =  'Week 6' ;
    'WEEK 8'               =  'Week 8' ;
    'WEEK 12'              =  'Week 12' ;
    'WEEK 16'              =  'Week 16' ;
    'WEEK 20'              =  'Week 20' ;
    'WEEK 24'              =  'Week 24' ;
    'WEEK 26'              =  'Week 26' ;
    'RETRIEVAL'            =  'Retrieval' ;
    'UNSCHEDULED 3.1'      =  'Unscheduled 3.1' "
)



#------------------------------------------------------------------------------
# URL encoding
#   Encode fields  that may potentially have values that violate valid IRI format
#   Function is in Functions.R
# TODO: Change function to loop over a list of variables instead of 1 call per each 
#
# ex <- encodeCol(data=ex, col="visit")  # CHANGE TO USE COMPRESSED VALUES INSTEAD OF ENCODE: 12APR18
ex <- encodeCol(data=ex, col="exstdtc")
ex <- encodeCol(data=ex, col="exendtc")
ex <- encodeCol(data=ex, col="exroute")

ex <- encodeCol(data=ex, col="fixDoseInt_im")


# Title case. For labels.
# NOT USED AS OF 21JUN18
#ex$extrt_im_titleC  <- gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", ex$extrt, perl=TRUE)
#ex$visit_im_titleC  <- gsub("([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", ex$visit, perl=TRUE)

# Low/High dose assigned to Product_1/_2 as per AO 21JUN18
ex[ex$extrt == "PLACEBO", "extrt_exdose_im"]                      <- "Placebo"
ex[ex$extrt == "XANOMELINE" & ex$exdose == 54, "extrt_exdose_im"]  <- "Product_1"
ex[ex$extrt == "XANOMELINE" & ex$exdose == 81, "extrt_exdose_im"]  <- "Product_2"

# Sort column names in the df for quicker referencing
ex <- ex %>% select(noquote(order(colnames(ex))))
