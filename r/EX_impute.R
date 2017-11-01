#______________________________________________________________________________
# FILE: EX_impute.R
# DESC: Impute data required for prototyping. Includes any data creation or deletion
#       necessary for the prototype or prototype development.
# 
# REQ : 
# SRC : 
# IN  : EX dataframe
# OUT : 
# NOTE: 
# TODO: 
#
#______________________________________________________________________________

# Subset to only the first 8 obs to match AO ontology work
exSubset <-c(1:8)
ex <- ex[exSubset, ]

# Add row number that will be used in fragment creation
ex <- ex %>%
  mutate(rowID = 1:n(),
         DrugAdminOutcome_ = "Complete"
    )