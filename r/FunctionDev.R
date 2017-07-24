# FunctionDev.R
# developing : createFragOneColByCat<-function(domainName, dataCol, byCol, fragPrefixCol, numSort=FALSE)
library(plyr)
library(dplyr)

vsTest <- read.table(header=T, text='
               vsorres  vstestcd vstestCat              bogusCol
               65       DIABP    BloodPressureOutcome   A
               57       DIABP    BloodPressureOutcome   B
               61       DIABP    BloodPressureOutcome   C
               61       DIABP    BloodPressureOutcome   C2
               100      SYSBP    BloodPressureOutcome   D
               88       SYSBP    BloodPressureOutcome   E
               110      SYSBP    BloodPressureOutcome   F
               65       PULSE    PulseHROutcome         G
               100      PULSE    PulseHROutcome         H
               100      PULSE    PulseHROutcome         H2
               65       HEIGHT   HeightOutcome          I
               57       HEIGHT   HeightOutcome          J
               61       HEIGHT   HeightOutcome          K
               61       HEIGHT   HeightOutcome          K2
                 ')

createFragOneColByCat<-function(domainName, dataCol, byCol, fragPrefixCol, numSort=FALSE)
{
  temp <- domainName[,c(byCol, dataCol)]
  temp2 <- temp[!duplicated(temp), ]
  # sort by category, data column value
  temp2 <- temp2[ order(temp2[,1], temp2[,2]), ]
  
  # Create the new column named based on the input column name by appending
  #  "_Frag" to the value of the the dataCol parameter
  varname <- paste0(dataCol, "_Frag")

  # Note use of !! to resolve the value of varname created above and assign
  #   a value to it using :=
  temp2 <- temp2 %>% group_by_(byCol) %>% mutate(id = row_number())%>% 
    mutate( !!varname := paste0(vstestCat,"_", id)) 
  
  # Remove the ID variable. It is now part of the fragment value in each row
  temp2 <- temp2[,!(names(temp2) %in% "id")]
  
  # Merge the fragment value back into the original data
  withFrag <<- merge(domainName, temp2, by = c(byCol, dataCol), all.x=TRUE)

}
vsTest <- createFragOneColByCat(domainName=vsTest, dataCol="vsorres", byCol="vstestCat", fragPrefixCol="vstestCat")