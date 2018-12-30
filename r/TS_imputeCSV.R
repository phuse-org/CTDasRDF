#______________________________________________________________________________
# FILE: TS_imputeCSV.R
# DESC: Cast the long TS domain to wide for use with SMS. Lowercased values in 
#       TSPARMCD become the column names 
# REQ : Prior import of the VS XPT file  by driver script.
# SRC : N/A
# IN  : ts dataframe 
# OUT : modified vs dataframe 
# NOTE: 
# REF :  Datatable reshape: 
#          https://cran.r-project.org/web/packages/data.table/vignettes/datatable-reshape.html
# TODO: visit recode move to function, share with VS,EX and other domains...
#______________________________________________________________________________

library(data.table)  # dcast

tswide <- dcast(setDT(ts), studyid + tsseq ~ tsparmcd, 
  value.var = "tsval")

tswide <- tswide %>% setNames(tolower(names(.))) %>% head  # all column names to lowercase

# Move this code to the driver script.
write.csv(tswide, file="data/source/ts_wide.csv", 
  row.names = F,
  na = "")
