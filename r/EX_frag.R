#______________________________________________________________________________
# FILE: EX_frag.R
# DESC: 1) Data recoding 
#       2) URI fragment creation from existing domain values
# 
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: No value creation, only recoding. Original values retained in DF
#       Coded values cannot have spaces or special characters.
#       SDTM numeric codes and others set MANUALLY
# TODO: 
#
#______________________________________________________________________________

# Drug administration fragment. Each row in the data gets a unique ID.
ex <- mutate(ex,
   DrugAdminID_Frag   = paste0("DrugAdministration_",rowID),
   DrugAdminType_Frag = "FixedDoseDrugAdministration", 
   product_Frag        = paste0(extrt, exdose)  # Recoded, below
  ) 

# Recode product_Frag to the values required
ex$product_Frag <- sapply(ex$product_Frag,function(x) {
  switch(as.character(x),
    "PLACEBO0"     = "PlaceboProduct_1",
    "XANOMELINE54" = "Product_1",
    "XANOMELINE81" = "Product_2",
    as.character(x) )})

# Dates ----
ex <- addDateFrag(ex, "exstdtc")  
ex <- addDateFrag(ex, "exendtc")  


#  SDTM code values ----
# Translate values in the domain to their corresponding codelist code
# DosageFrequency ----
ex$exdosfrqSDTMCode <- recode(ex$exdosfrq, 
                         "'QD'         = 'C71113.C25473'" )  
# Route of Admin ----
ex$exrouteSDTMCode <- recode(ex$exroute, 
                           "'TRANSDERMAL' = 'C66729.C38305'" ) # only 1 route in study

# Sort column names in the df for quicker referencing
ex <- ex %>% select(noquote(order(colnames(ex))))
