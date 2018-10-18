filesAndFolders <- list.files(path = "H:/My Documents/#RProgramming/CTDasRDF-master", recursive = TRUE)
print(filesAndFolders)


# save_file = function(n){
#   df = data.frame(Var1 = rnorm(n, 100, 3),
#                   Var2 = rpois(n, 100),
#                   Var3 = rcauchy(n, 100),
#                   Var4 = rweibull(n, 3.5, 111.1))
#   write.csv(df, file = paste0("Raw_Data (", n, " rows).csv"), row.names = FALSE)
# }


print(mtcars)

df[nrow(df) + 1,] = list("v1","v2")

library(stringr)
str_split_fixed(before$type, "/", 2)

left_right <- str_split_fixed("Wiki/Images/ProjectLogo.png",'/',5)
print(left_right)

df <- str_split_fixed(filesAndFolders,'/',5)
print(df)

test <- ifelse(str_count(filesAndFolders,'.')>0,0,1)

library(psych)
describe(filesAndFolders)



library(data.tree); 
library(plyr)
filesAndFolders <- list.files(path = "H:/My Documents/#RProgramming/CTDasRDF-master", recursive = TRUE)
x <- lapply(strsplit(filesAndFolders, "/"), function(z) as.data.frame(t(z)))
x <- rbind.fill(x)
x$pathString <- apply(x, 1, function(x) paste(trimws(na.omit(x)), collapse="/"))
(mytree <- data.tree::as.Node(x))


#(mytree <- data.tree::as.Node(data.frame(pathString = "H:/My Documents/#RProgramming/CTDasRDF-master")))




