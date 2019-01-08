library(stringr)
library(visNetwork)
library(reshape)  #  melt
library(dplyr)

setwd("C:/Temp/git/CTDasRDF")

parseFile <- function(sourceFiles){
    
    triples <- data.frame(s               = character(),
                          p               = character(), 
                          o               = character(), 
                          mapFile         = character(), 
                          stringsAsFactors = FALSE) 
    
    # Process each source file in the list
    sourceContent <- lapply(sourceFiles, function(fileName) {
        
        fileNamePath <- paste0("data/rdf/",fileName)
        print(paste0("FILE: ", fileNamePath))
        conn <- file(fileNamePath,open="r")
        linn <-readLines(conn)
        #DEUBUG print(linn)
        for (i in 1:length(linn)){
            # SUBJECT : Starts Flush left, has prefix ':'
            #          Does not end with ; or .
            if(grepl("^\\S+:\\S+[^.;]", linn[i], perl=TRUE)){
                s <- linn[i]
                s <- gsub(" ", "", s)  # Remove all spaces from subjects
                p <- NULL
                o <- NULL
                #DEBUG print(paste("S LINE::", linn[i]))
            }
            else if(grepl("^\\s+\\S+:\\S+\\s+[\\S+\\s*]*;$", linn[i], perl=TRUE)){
                #DEBUG print(paste("P,O LINE::", linn[i]))
                p <- str_extract(linn[i], "^\\s+\\S+:\\S+")
                o <- gsub(p, "", linn[i]) # o is the line with p removed
                
                o <- sub("\\s*;\\s*$|\\s+$", "", o, perl = TRUE)  # remove ending ; and extra spaces
                
                # Remove any leading spaces
                s <- gsub("^\\s+", "", s) 
                o <- gsub("^\\s+", "", o) 
                
                mapFile <-fileName  # Name of file without sub path
                triples <<- rbind(triples, data.frame(s=s, p=p, o=o, mapFile=mapFile))
            }
            
        }  
        close(conn)
    })
    foo <- triples
}  

triples<-data.frame(parseFile(sourceFiles=list("code.ttl")), stringsAsFactors = FALSE)


print(triples[triples$s == "sdtmterm:TrialPhase_NA",])


startsWith(c("hallo","world"),"h")

typeof(c("blub", "lila"))
typeof(triples$s)

print(as.character(triples$s))

selection <- print(triples[startsWith(as.character(triples$s),"sdtmterm:TrialPhase"),])

print(triples[])

write.csv(triples, file = "C:/Temp/git/CTDasRDF/Katja/code_ttl.csv")



# test <- parseFile(sourceFiles=list("code.ttl"))
# 
# typeof(test)
# grepl("sdtmterm:TrialPhase.*", test[1])
# 
# print(test[test[1] == "sdtmterm:TrialPhase_NA",])
# 
# test[1] == "sdtmterm:TrialPhase_NA"
# startsWith(test[1],"sdtmterm")
# 
# 
# print(test[startsWith(test[1],"sdtmterm:TrialPhase_NA"),])
# print(test[1])
# 
# 
# print(startsWith(test[1],"sdtmterm:TrialPhase_NA"))
# print(list(test[1]))
