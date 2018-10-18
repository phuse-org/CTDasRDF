
library(Hmisc)
library(car)   # recode
library(dplyr)  # mutate with pipe in Functions.R

result  <- Hmisc::sasxport.get("data/source/DM.XPT")
head(result)



#unloadNamespace("car")
#unloadNamespace("carData")

# detach_package <- function(pkg, character.only = FALSE)
# {
#   if(!character.only)
#   {
#     pkg <- deparse(substitute(pkg))
#   }
#   search_item <- paste("package", pkg, sep = ":")
#   while(search_item %in% search())
#   {
#     detach(search_item, unload = TRUE, character.only = TRUE)
#   }
# }
# detach_package(car)
# detach_package(carData)

# Option 1 - similar to current processing
result  <- Hmisc::sasxport.get("data/source/DM.XPT")
head(result)

# result2 <- data.frame( do.call( 'cbind', unclass(result) ) )
# result2 <- head(result2,3)
# #everything is read in as factor, even usubjid is a factor
# str(result2)
# print(result2)
# #actarmcd does not even contain the correct texts, it is character, not int as importet
# print(result2$actarmcd)
# print(result2$usubjid)