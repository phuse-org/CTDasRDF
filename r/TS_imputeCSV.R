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
# NOTE: Unlike other conversions, this code does not produce _im variables, 
#         due to complications in the post processing of the CAST
#       Source variables (prior to CASTing) must not have '_' in column names.
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


# CAST from long to wide to get TSPARMCD values as column names, combining with other value.var 
# fields as in xxxx_tsval, xxx_tsparm, etc. 
# TODO: Add additional value.var as needed
# NOTE: data.table:dcast used for its ability to use mutliple value.var columns.

tswide <- data.table::dcast( setDT(tsAll),
  studyid + tsseq ~ tsparmcd,
  value.var = c("tsval", "tsvalcd", "tsparm", "tsvcdref", "type", "type2" )
  )

# dplyr approach to removing columns filled with NA (no values in entire column)
not_all_na <- function(x) any(!is.na(x))
tswide <- tswide %>% select_if(not_all_na)

# CAST results in tsval_xxx, tsparm_xxx,  we need xxx_tsval, xxx_tsparm, so reverse
#  the text on either side of '_' created during the CAST. 
names(tswide) <- gsub('(.*)_(.*)', '\\2_\\1', names(tswide))

# Sort column names ease of reference 
tswide <- tswide %>% select(noquote(order(colnames(tswide))))

names(tswide) <- tolower(names(tswide))

#---- Imputation  (recoding)
tswide$tblind_tsval_iri     <- gsub(" ", "_", tswide$tblind_tsval )    # Blinding schema
tswide$agespan_tsval_iri    <- gsub( " .*$", "", tswide$agespan_tsval) # ADULT, ELDERLY iri 
tswide$dcutdtc_tsvcdref_iri <- gsub( " ", "", tswide$dcutdtc_tsvcdref) 
tswide$epoch_tsvalcd_lc     <- tolower(tswide$epoch_tsvalcd) 


# Age max is recoded from NA to NULL.4 to represent a reason for the NULL (a Null Flavor):
#  age is missing due to null flavor reason #4.

tswide[1,"agemax_tsval"] <- "NULL.4"  # Recode existing NA to "NULL.4" for use in IRI

#---- Sequence Numbers
# Primary and Secondary Objective, Stop Rule sequence number for IRIs.
#   When xxx_tsval != NA, then the seq is the value of tsseq.
# Primary Objective sequence
tswide[ ! is.na(objprim_tsval) , "objprim_tsval_seq" ] <- tswide[ ! is.na(objprim_tsval), "tsseq" ]

# Secondary Objective sequence
tswide[ ! is.na(objsec_tsval) , "objsec_tsval_seq" ] <- tswide[ ! is.na(objsec_tsval), "tsseq" ]

# Stop rule sequence
tswide[ ! is.na(stoprule_tsval) , "stoprule_tsval_seq" ] <- tswide[ ! is.na(stoprule_tsval), "tsseq" ]

#---- OLDE BELOW HERE -----------------------------------------------------------------

# Sort column names ease of refernece 
tswide <- tswide %>% select(noquote(order(colnames(tswide))))
