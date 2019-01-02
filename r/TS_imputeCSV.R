#______________________________________________________________________________
# FILE: TS_imputeCSV.R
# DESC: Cast the long TS domain to wide for use with SMS. Lowercased values in 
#       TSPARMCD become the column names.  Impute values as needed to
#       consstruct graph.
# REQ : Prior import of the TS XPT file  by driver script.
# SRC : N/A
# IN  : ts dataframe 
#       TS_supplemental.XLSX - supplemental data needed in the graph that is not
#         available in the original TS.XPT file.  NOTES column offers 
#         explanation of the values as needed.
# OUT : modified ts dataframe 
# NOTE: 
#       
#       
# REF :  Datatable reshape: 
#          https://cran.r-project.org/web/packages/data.table/vignettes/datatable-reshape.html
# TODO: visit recode move to function, share with VS,EX and other domains...
#       Site info to be read in from a a file: Site, site seq, country code
#______________________________________________________________________________

# Data Corrections 
# Primary Outcome in original data should bean additional Primary objective 
#    Objective is not in the original data.
# Remove the original OUTMSPRI row. 
ts<-ts[!(ts$tsparmcd =="OUTMSPRI"), ]

# Data not in original TS. 
# Includes replacement of what was OUTMSPRI and is now a primary objective.
tsAdditions <- read_excel("data/source/TS_supplemental.xlsx", col_names=TRUE)
tsAdditions <- tsAdditions[, !(names(tsAdditions) == 'NOTES')] # Drop the notes column (explation of data)

ts<-rbind(ts, tsAdditions)

tswide <- dcast(setDT(ts), studyid + tsseq ~ tsparmcd, 
  value.var = "tsval")

tswide <- tswide %>% setNames(tolower(names(.))) %>% head  # all column names to lowercase

#---- Imputation  (recoding)
tswide$tblind_im      <- gsub(" ", "_", tswide$tblind )    # Blinding schema
tswide$agespan_iri_im <- gsub( " .*$", "", tswide$agespan) # ADULT, ELDERLY iri 
tswide[1,"agemax"] <- "NULL"  # Recode existing NA to "NULL" for use in IRI

#TW tswide[1,"dcut_iri_im"] <- "DataCutoff"  # to forum IRI for Data cutoff information

# Arm information
#TW tsArms <-read.table(header = TRUE, fill=TRUE, text = "
#TW arm_im           arm_type_im             arm_altlbl_im   arm_preflbl_im    
#TW 'Pbo'            'ControlArm'            'Pbo'           'Placebo'         
#TW 'Pbo'            'RandomizationOutcome'  'Pbo'           'Placebo'
#TW 'ScreenFailue'   'FalseArm'              'Scrnfail'      'Screen Failure'
#TW 'XanomelineHigh' 'InvestigationalArm'    'Xan_Hi'        'Xanomeline High'
#TW 'XanomelineHigh' 'RandomizationOutcome'  'Xan_Hi'        'Xanomeline High'
#TW 'XanomelineLow'  'InvestigationalArm'    'Xan_Lo'        'Xanomeline Low'
#TW 'XanomelineLow'  'RandomizationOutcome'  'Xan_Lo'        'Xanomeline Low'
#TW ")
#TW tswide<-cbind(tswide,tsArms)


# Epoch Data
#TW tsEpoch <- data.frame(
#TW   epoch_im              = 'BlindedTreatment',
#TW   epoch_type_imtime     = 'Epoch',
#TW   epoch_preflbl         = 'Epoch Blinded treatment' ,
#TW   epoch_int_im          = 'blindedtreatment',
#TW   epoch_int_type_im     = 'EpochInterval',
#TW   epoch_int_preflbl_im  = 'Epoch interval blindedtreatment'
#TW )

#TW tswide<-cbind(tswide,tsEpoch)


# WIP HERE ----------------------------------------
# When objprim != NA, then the seq_im is the value of tsseq.
# See here : https://stackoverflow.com/questions/22814515/replace-value-in-column-with-corresponding-value-from-another-column-in-same-dat
# df[ df$X1 == "a" , "X1" ] <- df[ df$X1 == "a", "X2" ]

# Sequence for primary objective, needed for comparision with XPT source
#TW tswide[ ! is.na(objprim) , "objprim_seq" ] <- tswide[ ! is.na(objprim), "tsseq" ]

# Sequence for secondary objective, needed for comparision with XPT source
#TW tswide[ ! is.na(objsec) , "objsec_seq" ] <- tswide[ ! is.na(objsec), "tsseq" ]


# Move this code to the driver script.
write.csv(tswide, file="data/source/ts_wide.csv", 
  row.names = F,
  na = "")

