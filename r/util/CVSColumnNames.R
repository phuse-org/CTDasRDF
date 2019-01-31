###############################################################################
# FILE: 
# DESC: 
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
###############################################################################
library(xlsx)
setwd("C:/_gitHub/CTDasRDF")

df <- read.csv("data/source/VS_subset.csv", header=TRUE)
columns <- names(df)

write.xlsx(columns, "data/columnsCheck.xlsx")
