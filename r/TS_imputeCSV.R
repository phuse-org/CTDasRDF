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


# 2. Create the correct Pimary Objective and Primary Outcome Measure data
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


# WIP HERE ----------------------------------------
# When objprim != NA, then the seq_im is the value of tsseq.
# See here : https://stackoverflow.com/questions/22814515/replace-value-in-column-with-corresponding-value-from-another-column-in-same-dat
# df[ df$X1 == "a" , "X1" ] <- df[ df$X1 == "a", "X2" ]
tswide$objprim_seq_im <-""

tswide[ ! is.na(objprim) , "tswide_foo" ] <- tswide[ ! is.na(objprim), "tsseq" ]
head(tswide)






# Move this code to the driver script.
write.csv(tswide, file="data/source/ts_wide.csv", 
  row.names = F,
  na = "")
