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
#'  as.character conversion needed for URLencode that was not needed for
#'   curlEscape.
#'  Leaving in the FOR loop example in case need use of is.na
#' @return Encoded column in a new column with _en suffix
#'
#' @examples
#' encodeCol(data=dm, col=ethnic)
#' encodeCol(data=dm, col=refInt_im)

#' Previous encoding was: 
#' # mutate( !!encoded := curlEscape(data[,col]))
#' # mutate( !!encoded := URLencode(data[,col])) 
encodeCol<-function(data, col)
{
  encoded <- paste0(col, "_en")
  for (i in 1:nrow(data))
  {
    if (!is.na(data[i,col])){
      # data[i,encoded] <- URLencode(paste(data[i,col])) # Percent encoded
      # data[i,encoded] <- gsub(" ", "&#x20;", data[i,col]) # HTML hex encoded
      #TW: Was ". |:   
      data[i,encoded] <- gsub(" |:", "_", data[i,col]) # replace with underbar
    }
  }
  data  
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
