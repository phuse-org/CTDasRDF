#______________________________________________________________________________
# FILE: DM_imputeCSV.R
# DESC: Creates data values required for prototyping and ontology develeopment
# REQ : Prior import of the DM domain by driver script XPTtoCSV.R
# SRC : N/A
# IN  : dm dataframe 
# OUT : modified dm dataframe 
#       dmDrugInt  dataframe for use in EX mapping.
# NOTE: Column names with _im, _im_en, _en are imputed, encoded from orig vals. 
# TODO:   See TODO markers within the script.
#______________________________________________________________________________

# Imputations ----
dm[dm$actarmcd == "Pbo", "actarmcd_im"] <- "Pbo"
dm[dm$actarmcd == "Xan_Hi", "actarmcd_im"] <- "XanomelineHigh"

#-- Birthdate -----
# Absent in source data
# NOTE: Date calculations based on SECONDS so you must convert the age in Years to seconds
#      Change to character to avoid later ddply problem
#      Dates reflect their original mixed format of DATE or DATETIME in same col.
dm$brthdate <- as.character(strptime(strptime(dm$rfstdtc, "%Y-%m-%d") - (strtoi(dm$age) * 365.25 * 24 * 60 * 60), "%Y-%m-%d"))

#Informed Consent  (column present with missing values in DM source).  
dm$rficdtc <- dm$dmdtc   # Confirm this is not in the new Test Data factory version. 

#-- Death Date and Flag ----
# Set for Person 1 for testing purposes & will not match original data.
# Unfactorize the dthdtc column to allow entry of a bogus date
dm$dthdtc <- as.character(dm$dthdtc)
dm$dthdtc[dm$usubjid == '01-701-1015' ] <- "2013-12-26"  # Death Date
dm$dthfl[dm$usubjid == '01-701-1015' ]  <- "Y" # Set a Death flag  for Person_1


#-- Intervals
dm$cumuDrugAdmin_im  <- paste0(dm$rfxstdtc, "_", dm$rfxendtc)
dm$lifeSpan_im       <- paste0(dm$brthdate, "_", dm$dthdtc)
dm$lifeSpan_label_im <- paste0(dm$brthdate, " to ", dm$dthdtc)
dm$refInt_im         <- paste0(dm$rfstdtc,  "_", dm$rfendtc) 
dm$refInt_label_im   <- paste0(dm$rfstdtc,  " to ", dm$rfendtc)

# No end date to informed consent interval so end in _
# infConsInt_im later deleted after being used to create other fields
dm$infConsInt_im       <- paste0(dm$rficdtc,  "_")   # No end for inf. con.
dm$infConsInt_label_im <- paste0(dm$rficdtc,  " to ")# No end for inf. con.
dm$cumuDrugAdmin_label_im <- paste0(dm$rfxstdtc, " to ", dm$rfxendtc) 
dm$studyPartInt_label_im <- paste0(dm$dmdtc,  " to ", dm$rfpendtc)  

#-- URL encoding ----
#  Encode fields  that may potentially have values that violate valid IRI format
dm <- encodeCol(data=dm, col="age")
dm <- encodeCol(data=dm, col="brthdate")
dm <- encodeCol(data=dm, col="cumuDrugAdmin_im")
dm <- encodeCol(data=dm, col="dmdtc")
dm <- encodeCol(data=dm, col="dthdtc")
dm <- encodeCol(data=dm, col="ethnic")
dm <- encodeCol(data=dm, col="infConsInt_im", removeCol=TRUE)
dm <- encodeCol(data=dm, col="lifeSpan_im", removeCol=TRUE)
dm <- encodeCol(data=dm, col="race")

dm <- encodeCol(data=dm, col="rfpendtc") # remove timestamp colon present in some data
dm <- encodeCol(data=dm, col="rficdtc")
dm <- encodeCol(data=dm, col="rfstdtc")
dm <- encodeCol(data=dm, col="rfxstdtc")
dm <- encodeCol(data=dm, col="rfxendtc")
dm <- encodeCol(data=dm, col="refInt_im", removeCol=TRUE)

#  Dependencies between rfpendtc_en, studyPartInt_im to create studyPartInt_im_en
dm <- encodeCol(data=dm, col="rfendtc")
dm$studyPartInt_im       <- paste0(dm$dmdtc,  "_", dm$rfpendtc_en)  
dm <- encodeCol(data=dm, col="studyPartInt_im", removeCol=TRUE)

# Sort column names ease of refernece 
dm <- dm %>% select(noquote(order(colnames(dm))))

#-- dmDrugInt df for use by EX coding ----
# Drug admin interval to be used for each usubjid in EX  
#   rfxstdtc, rfxendtc needed for label in EX
dmDrugInt <- dm[,c("usubjid", "cumuDrugAdmin_im", "rfxstdtc", "rfxendtc")]
