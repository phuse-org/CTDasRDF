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
ts <- ts[!(ts$tsparmcd =="OUTMSPRI"), ]
ts <- ts[, !(names(ts) %in% c('domain'))] # Drop the notes column (explation of data)

# Data not in original TS. 
# Includes replacement of what was OUTMSPRI and is now a primary objective.
tsAdditions <- read_excel("data/source/TS_supplemental.xlsx", col_names=TRUE)
tsAdditions <- tsAdditions[, !(names(tsAdditions) == 'NOTES')] # Drop the notes column (explation of data)


# Kludge: All to char prior to bind
ts <- data.frame(lapply(ts, as.character), stringsAsFactors=FALSE)
tsAdditions <- data.frame(lapply(tsAdditions, as.character), stringsAsFactors=FALSE)

tsAll<-dplyr::bind_rows(ts, tsAdditions)

tsAll$rowID <- seq.int(nrow(tsAll))

# WIP HERE ----------------------------------------------------------------------------
#TW APPROACH
#  Get the tsparmcd values as variables across the top, the values as tsparm 
# do again for tsval? or multiple value.var?

# Do also for the new label values, etc?  
# Merge back in based on rowID?

# Look at this result and see how to use it.  Unlike the other domains, TS will be VERY WIDE instead of long
#   Because of the many uniqe types of things being recorded. At the same time, some values must be 
#    kept together on the same line, like sstdtc}_to_{sendtc} in order to be used in the map.
# Make some trickery to rename columns from 1_2  to 2_1 in order to sort by names. switch order of text
#  with some regex wizardy

foo <- data.table::dcast( setDT(ts),
  tsseq ~ tsparmcd,
  value.var = c("tsval", "tsparm"  )
  )


tswide <- data.table::dcast( setDT(tsAll),
  ... ~tsparmcd,
  value.var = "tsval"
  )

# tswide <- dcast(setDT(tsAll), studyid + tsseq +tsvcdref ~ tsparmcd, 
# value.var = "tsval")

#TW 2018-01-02 tswide <- dcast(setDT(tsAll), ... ~ tsparmcd, 
#TW 2018-01-02   value.var = "tsval")

names(tswide) <- tolower(names(tswide))

#---- Imputation  (recoding)
tswide$tblind_im       <- gsub(" ", "_", tswide$tblind )    # Blinding schema
tswide$agespan_iri_im  <- gsub( " .*$", "", tswide$agespan) # ADULT, ELDERLY iri 
tswide$tsvcdref_iri_im <- gsub( " ", "", tswide$tsvcdref) 
tswide[1,"agemax"] <- "NULL"  # Recode existing NA to "NULL" for use in IRI




# Primary and Secondary Objective sequence number for IRIs. Value needed for comp
#   with source XPT.
#   When objprim != NA, then the seq_im is the value of tsseq.
#   See here : https://stackoverflow.com/questions/22814515/replace-value-in-column-with-corresponding-value-from-another-column-in-same-dat
#   df[ df$X1 == "a" , "X1" ] <- df[ df$X1 == "a", "X2" ]

# Primary Objective sequence
tswide[ ! is.na(objprim) , "objprim_seq_im" ] <- tswide[ ! is.na(objprim), "tsseq" ]

# Secondary Objective sequence
tswide[ ! is.na(objsec) , "objsec_seq_im" ] <- tswide[ ! is.na(objsec), "tsseq" ]


#---- OLDE BELOW HERE -----------------------------------------------------------------


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

# Sort column names ease of refernece 
tswide <- tswide %>% select(noquote(order(colnames(tswide))))



# Move this code to the driver script.
write.csv(tswide, file="data/source/ts_wide.csv", 
  row.names = F,
  na = "")

