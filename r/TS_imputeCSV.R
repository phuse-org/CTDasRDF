#______________________________________________________________________________
# FILE: TS_imputeCSV.R
# DESC: Cast the long TS domain to wide for use with SMS. Lowercased values in 
#       TSPARMCD become the column names.  Impute values as needed to
#       consstruct graph.
# REQ : Prior import of the TS XPT file  by driver script.
# SRC : N/A
# IN  : ts dataframe 
# OUT : modified ts dataframe 
# NOTE: 
# REF :  Datatable reshape: 
#          https://cran.r-project.org/web/packages/data.table/vignettes/datatable-reshape.html
# TODO: visit recode move to function, share with VS,EX and other domains...
#______________________________________________________________________________

library(data.table)  # dcast


# Data Error Corrections 
# Primary Outcome is actually another Primary objective and Primary 
#    Objective is not in the original data
# 1. remove the original OUTMSPRI row. 
ts<-ts[!(ts$tsparmcd =="OUTMSPRI"), ]


# 2. Create the correct Primary Objective and Primary Outcome Measure data
tsAdditions <-read.table(header = TRUE, fill=TRUE, text = "
studyid       domain tsseq  tsparmcd  tsparm                     tsval                                                                                                                                             tsvalnf  tsvalcd  tsvcdref tsvcdver
CDISPILOT01   TS     3      OBJPRIM   'Trial Primary Objective'  'Evaluate the efficacy and safety of transdermal xanomeline, 50cm2 and 75cm2, and placebo in subjects with mild to moderate Alzheimers disease.'                                                                                                                                         
CDISPILOT01   TS     1      OUTMSPRI  'Primary Outcome Measure'  'ADAS-cog'                                                                                                                                                 C100762
")

ts<-rbind(ts, tsAdditions)


tswide <- dcast(setDT(ts), studyid + tsseq ~ tsparmcd, 
  value.var = "tsval")

tswide <- tswide %>% setNames(tolower(names(.))) %>% head  # all column names to lowercase

#---- Imputation
tswide$tblind_im <- gsub(" ", "_", tswide$tblind )

tswide[1,"dcut_iri_im"] <- "DataCutoff"  # to forum IRI for Data cutoff information

# Arm information
tsArms <-read.table(header = TRUE, fill=TRUE, text = "
arm_im           arm_type_im             arm_altlbl_im   arm_preflbl_im    
'Pbo'            'ControlArm'            'Pbo'           'Placebo'         
'Pbo'            'RandomizationOutcome'  'Pbo'           'Placebo'
'ScreenFailue'   'FalseArm'              'Scrnfail'      'Screen Failure'
'XanomelineHigh' 'InvestigationalArm'    'Xan_Hi'        'Xanomeline High'
'XanomelineHigh' 'RandomizationOutcome'  'Xan_Hi'        'Xanomeline High'
'XanomelineLow'  'InvestigationalArm'    'Xan_Lo'        'Xanomeline Low'
'XanomelineLow'  'RandomizationOutcome'  'Xan_Lo'        'Xanomeline Low'
")
tswide<-cbind(tswide,tsArms)


# Epoch Data
tsEpoch <- data.frame(
  epoch_im              = 'BlindedTreatment',
  epoch_type_imtime     = 'Epoch',
  epoch_preflbl         = 'Epoch Blinded treatment' ,
  epoch_int_im          = 'blindedtreatment',
  epoch_int_type_im     = 'EpochInterval',
  epoch_int_preflbl_im  = 'Epoch interval blindedtreatment'
)

tswide<-cbind(tswide,tsEpoch)


# WIP HERE ----------------------------------------
# When objprim != NA, then the seq_im is the value of tsseq.
# See here : https://stackoverflow.com/questions/22814515/replace-value-in-column-with-corresponding-value-from-another-column-in-same-dat
# df[ df$X1 == "a" , "X1" ] <- df[ df$X1 == "a", "X2" ]

# Sequence for primary objective, needed for comparision with XPT source
tswide[ ! is.na(objprim) , "objprim_seq" ] <- tswide[ ! is.na(objprim), "tsseq" ]

# Sequence for secondary objective, needed for comparision with XPT source
tswide[ ! is.na(objsec) , "objsec_seq" ] <- tswide[ ! is.na(objsec), "tsseq" ]


# Move this code to the driver script.
write.csv(tswide, file="data/source/ts_wide.csv", 
  row.names = F,
  na = "")
