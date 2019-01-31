###############################################################################
# FILE:  testEncoding.R
# DESC:  Test URL Encoding
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE:   switched package httpuv for encodeURI
#       Docs: https://www.rdocumentation.org/packages/httpuv/versions/1.3.6.1/topics/encodeURI
#encodeURI(value)
#encodeURIComponent(value)
#decodeURI(value)
#decodeURIComponent(value)

# TODO: 
#
###############################################################################
library(httpuv)  # for encodeURI
library(data.table)  #

# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

testEncode <- read.table(header=T, sep=",",text='
rfpend,ethnic
2014-07-02T11:45,HISPANIC OR LATINO')

testEncode$rfpend_en <- paste(testEncode[,"rfpend"]))
testEncode$ethnic_en <- encodeURIComponent(paste(testEncode[,"ethnic"]))
encodeURIComponent(
write.csv(testEncode, file="data/source/testEncode.csv", 
row.names = F)

