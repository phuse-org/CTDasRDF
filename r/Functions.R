###############################################################################
# FILE: Functions.R
# DESC: Functions called during the data conversion from XPT to CSV
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
###############################################################################

#' Encode Column
#' Create URL Encoded column for use in valid IRIs
#'
#' @param data Name of dataframe
#' @param col  Name of column to encode 
#'
#' @return Encoded column in a new column with _en suffix
#'
#' @examples
#' encodeCol(data=dm, col=ethnic)
#' encodeCol(data=dm, col=refInt_im)
encodeCol<-function(data, col)
{
  encoded <- paste0(col, "_en")
  data %>%  
    mutate( !!encoded := curlEscape(data[,col])) 
}

#' Read XPT to R dataframe
#' 
#'
#' @param domain SDTM domain name on XPT file 
#'
#' @return R dataframe with same name as SDTM domain
#'
#' @examples
#' readXPT("dm")
#' readXPT("suppdm")
readXPT<-function(domain)
{
  sourceFile <- paste0("data/source/", domain, ".XPT")
  result <- sasxport.get(sourceFile)
  result  # return the dataframe
}
