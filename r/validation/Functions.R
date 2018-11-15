###############################################################################
# FILE: validation/Functions.R
# DESC: Functions used in the various validation programs
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: Convert to use tidyverse approach
###############################################################################

#' Short IRIs to use prefixes
#' Shorten full IRIs to their prefixed values. 
#'
#' @param sourceDF     Dataframe to process 
#' @param colsToParse  List of column name to be parsed
#'
#' @return DF with prefix-only columns as <origname>_prefix
#'
#' @examples
#' encodeCol(sourceDf=dmValus, colsToParse=c("s", "p", "o"))
IRItoPrefix <- function(sourceDF, colsToParse)
{  

  # Use to build prefix list and to regex-out results to use prefixed value.
  prefixes <- read.table(header=T, text='
    prefix iri
    cd01p:        <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01-protocol.ttl#> 
    cdiscpilot01: <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/cdiscpilot01.ttl#>    
    code:         <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/code.ttl#> 
    custom:       <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/custom#>
    owl:          <http://www.w3.org/2002/07/owl#> 
    rdf:          <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
    rdfs:         <http://www.w3.org/2000/01/rdf-schema#> 
    sdtmterm:     <http://rdf.cdisc.org/sdtmterm#> 
    skos:         <http://www.w3.org/2004/02/skos/core#> 
    sp:           <http://spinrdf.org/sp#> 
    spin:         <http://spinrdf.org/spin#> 
    study:        <https://raw.githubusercontent.com/phuse-org/CTDasRDF/master/data/rdf/study.ttl#> 
    time:         <http://www.w3.org/2006/time#> 
    xsd:          <http://www.w3.org/2001/XMLSchema#> 
  ')

  # Each row in the dataframe
  for (i in 1:nrow(sourceDF))
  {
    # each column to process
    lapply(colsToParse, function(currCol){
      # Loop through each prefix value and test it against the current data value
      #  current value is: sourceDF[i, currCol]
      for (j in 1:nrow(prefixes))
      {
        # The IRI is present in the current field, proceed to replace it.
        if (grepl(prefixes[j,2], sourceDF[i,currCol] ))
        {  
          # prefixes[j,2]  : IRI to be searched and replaced
          # prefixes[j,1]  : Prefix value to use in place of IRI
          parseStart <- gsub(prefixes[j,2], prefixes[j,1], sourceDF[i,currCol])
          parseStart <- gsub("#", "", parseStart)
          parseEnd   <- gsub(">", "", parseStart)
          # Use this code to crate a new column name, leavint the orig intact.
          # newCol <- paste0(currCol,"_pref")
          # sourceDF[i, newCol] <<- parseEnd
          sourceDF[i, currCol] <<- parseEnd
        }
      }
    })  # of of lapply over each col to be evaluated
  }
  sourceDF  # Return the modified dataframe
} # end of Function
