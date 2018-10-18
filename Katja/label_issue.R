# Option 1 - similar to current processing
result  <- sasxport.get("data/source/DM.XPT")
result2 <- data.frame( do.call( 'cbind', unclass(result) ) )
result2 <- head(result2,3)
#everything is read in as factor, even usubjid is a factor
str(result2)
print(result2)
#actarmcd does not even contain the correct texts, it is character, not int as importet
print(result2$actarmcd)
print(result2$usubjid)


# Option 2 / same result
library(SASxport)
lookup.xport("data/source/DM.XPT")
result <- read.xport("data/source/DM.XPT")
result2 <- data.frame( do.call( 'cbind', unclass(result) ) )
result2 <- head(result2,3)
#everything is read in as factor, even usubjid is a factor
str(result2)
print(result2)
#actarmcd does not even contain the correct texts, it is character, not int as importet
print(result2$actarmcd)
print(result2$usubjid)



# Download package tarball from CRAN archive
url <- "https://cran.r-project.org/src/contrib/Archive/foreign/foreign_0.8-69.tar.gz"
pkgFile <- "foreign_0.8-69.tar.gz"
download.file(url = url, destfile = pkgFile)
# Install package
install.packages(pkgs=pkgFile, type="source", repos=NULL)
# Delete package tarball
unlink(pkgFile)



library(devtools)
#for MAKE, downloaded GNU Tool
setwd("C:/Users/sgqyq.AD-BAYER-CNB/Downloads/UnixTools")
load_all('C:/Users/sgqyq.AD-BAYER-CNB/Downloads/foreign')
install('C:/Users/sgqyq.AD-BAYER-CNB/Downloads/foreign')
library("foreign", lib.loc="C:/Users/sgqyq.AD-BAYER-CNB/Downloads/foreign_0.8-69.tar.gz")
#R CMD INSTALL -l "C:/Users/sgqyq.AD-BAYER-CNB/Downloads/foreign_0.8-69.tar.gz"
library(foreign)
install_version("foreign", version = "0.8.69", repos = "http://cran.us.r-project.org")


test <- system("make")
class(test)
test

#####################################################################

result  <- sasxport.get("data/source/DM.XPT", as.is=FALSE)
result2 <- data.frame( do.call( 'cbind', unclass(result) ) )
str(result2)

result  <- sasxport.get("data/source/DM.XPT", stringsAsFactors=FALSE)
result2 <- data.frame( do.call( 'cbind', unclass(result) ) )
str(result2)


library(SASxport)
lookup.xport("data/source/DM.XPT")
result <- read.xport("data/source/DM.XPT")
head (result)


dm  <- head(readXPT("dm"), dm_n)
result <- sasxport.get("data/source/DM.XPT")
result
str(result)
class(result)
head(result,3)

names(result)
dim(result)

result2 <- result

one_entry <- function(x) {
  for (i in length(x)) attr(x[[i]], "labels") <- NULL
  return(x)
}
result2 <- lapply(result, FUN=one_entry)
str(result2)


# labelDataset <- function(data) {
#   correctLabel <- function(x) {
#     print(typeof(x))
#     #print(attributes(x)$labels)
#     #if (!is.null(attributes(x)$labels)) {
#       #print("something to be done!")
#     class(attributes(x)$labels) <- typeof(x)
#     #}
#     return(x)
#   }
#   for (i in colnames(data)) {
#     data[, i] <- correctLabel(data[, i])
#   }
#   return(data)
# }
# result2 <- labelDataset(result)
# str(result2)
