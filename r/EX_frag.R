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


#  Notes for frag construction
# Drug administration fragment. Each row in the data gets a unique ID.
#   Each product admin. activity status (prodAdminActStat_Frag) has a value
#   of 1 (complete) by virtue of it being listed in EX. There are no 
#   unsuccess. admins in EX for this study.
ex <- mutate(ex,
   DrugAdminID_Frag    = paste0("DrugAdministration_",rowID),
   DrugAdminType_Frag  = "FixedDoseDrugAdministration", 
   product_Frag        = paste0(extrt, exdose), 
   productAdmin_Frag   = paste0("ProductAdministration_",personNum),
   productAdminActStat_Frag = "ActivityStatus_1"
  
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
# FixedDoseInterval ----
# Create a unique ID for the dose interval
ex$FixedDoseInterval <- paste0(ex$exstdtc, "-TO-", ex$exendtc)

# sort by rowID to match original order from AO prior to callign createFragOneDomain
ex <- ex[order(ex$rowID),] 

# Fragments will be created in the order in which they occured in the dataset, 
#   dupes removed, unsorted.
ex<- createFragOneDomain(domainName=ex, processColumns="FixedDoseInterval",
     fragPrefix="FixedDoseInterval", sortMe=FALSE, numSort=FALSE)

# Drop temp columns ----
ex<-ex[, !(names(ex) %in% c("FixedDoseInterval"))]

# Sort by Col names ----
ex <- ex %>% select(noquote(order(colnames(ex))))

# Create visit_Frag and visitPerson_Frag triples
ex<-createFragVisit(ex)