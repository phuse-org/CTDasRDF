# FunctionDev.R
# developing : createFragOneColByCat<-function(domainName, dataCol, byCol, fragPrefixCol, numSort=FALSE)
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
  
  
  varname <- paste0(dataCol, "_Frag")

  # This works but the id goes away during later steps!!
  temp2 %>% group_by_(byCol) %>% mutate(id = row_number())%>% 
    mutate( !!varname := paste0(vstestCat,"_", id)) 
  
  
  # temp2[[varname]] <- paste0(temp2[,'id'])
  # temp2[[varname]] <- "test"
  #temp2 <- temp2
    # mutate(temp2, !!varname :=paste0(byCol,"_",id))
  #mutate(temp2, !!varname := id)
  
  # Create the new column name as the value of the byCol (vstestCat), _, id
  # see here, "In the new release" https://stackoverflow.com/questions/26003574/r-dplyr-mutate-use-dynamic-variable-names
  # mutate_(temp2, .)
   #fragVarName <- paste0(dataCol,"_Frag")
   #temp2[[fragVarName]] <- "Test" # paste0(temp2[,1], "_", temp2$id)
  
}



newData <- createFragOneColByCat(domainName=vsTest, dataCol="vsorres", byCol="vstestCat", fragPrefixCol="vstestCat")
