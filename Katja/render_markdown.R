#install.packages("shiny")
#install.packages("rmarkdown")
#install.packages("knitr")
#install.packages("rmarkdown", lib="H:/Personal Data/R/win-library/3.5")

.libPaths("H:/Personal Data/R/win-library/3.5")
library(rmarkdown)
library(knitr)
setwd("C:/Temp/git/CTDasRDF")
#knit('Katja/ProcessFlow.rmd', encoding = 'UTF-8')

rmarkdown::render('Katja/HandsOnCTDasRDF.rmd')
rmarkdown::render('doc/HandsOnCTDasRDF.rmd')
rmarkdown::render('CTDasRDF.rmd')

#library('readr')
.libPaths()
