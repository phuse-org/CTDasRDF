
library(reshape2)

# dm date columns
dmDates <- dm[,c("rfstdtc", "rfendtc", "rfxstdtc")]

#TODO vs date columns

#TODO Add vs:  Combined the date datframes  ((CBIND))
allDates <- dmDates

dateList <- melt(allDates, measure.vars=c("rfstdtc", "rfendtc", "rfxstdtc"),
                 variable.name="source",
                 value.name="date"
                 )


# Remove duplicates
dateList <- dateList[!duplicated(dateList$date), ]  # is DF here.

# Sort by date
dateList <- dateList[with(dateList, order(date)),]

# Create the coded value for each date as Date_n 
dateList$dateNum<-paste0("Date_", 1:nrow(dateList))   # Generate a list of ID numbers

