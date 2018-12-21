#______________________________________________________________________________
# FILE: protocol_imputeCSV.R
# DESC: Creates data values required for prototyping and ontology develeopment
#         Values are hard coded in this script. IRL they would be extracted
#         from the Protocol document and other sources like Site list.
# REQ : 
# SRC : N/A
# IN  :  
# OUT : protocol dataframe  
#       
# NOTE:  The constructed dataframe is an inefficient structure, with many 
#         repeated values, but the frame is small so it is acceptabel for 
#         this intiial POC until a better method is employed.
# TODO:   
#______________________________________________________________________________
#
# Remove next lines when integrated with XPTtoCSV.R 
# Set working directory to the root of the work area
  setwd("C:/_github/CTDasRDF")
  source('R/Functions.R')  # Functions: readXPT(), encodeCol(), etc.
  library(dplyr)  # recode, mutate with pipe in Functions.R, other dplyr goodness
# End lines to be removed

  
library(rowr)  # cbind.fill  - add to main driver code
  
  
singleRow <- data.frame(

  actualPopSize    = "254",
  adaptiveDesignNY = "N",
  addOnNY          = "N",
  adminActivity    = "DataCutoff",
  adminActivityLbl = "Admin activity Data cutoff",
  adminActivityDt  = "2015-03-31",
  ageGroup         = c("ADULT", "ELDERLY"),  
  blindingSchema   = "DOUBLE_BLIND",
  controlType      = "PLACEBO",
  countryIdSeq     = "1",
  epoch            = "BlindedTreatment",
  epochLC          = "blindedtreatment",
  epochLbl         = "Epoch Blinded treatment",
  intervModel      = "PARALLEL",
  intervType       = "DRUG",
  maxSubjAge       = "NULL",
  minSubjAge       = "P50Y",
  nArms            = "3",
  plannedPopSize   = "300",
  primOutMeas      = "ADAS-Cog",
  randTrialNY      = "Y",
  regid            = "NCT00987090",
  sdtmtermNY       = "N",
  sexGroup         = "BOTH",
  siteid           = "701",
  siteIdSeq        = "1",
  studyBegin       = "2012-07-06",
  studyDrug        = "xanomeline",
  studyEnd         = "2015-03-05",
  studyid          = "CDISCPILOT01",
  studyIdSeq       = "1",
  studyIdMeth      = "ASSIGNED",
  studyIdCRFLoc    = "1",
  studyIdCRFLocPg  = "7",
  studyStopRuleSeq = "1",
  studyStopRuleDsc = "Last patient completed last visit or sponsor decided to discontinue study",
  studyTitle       = "Safety and Efficacy of the Xanomeline Transdermal Therapeutic System (TTS) in Patients with Mild to Moderate Alzheimers Disease.",
  studyType        = "INT",
  trialPhase       = "PHASE2"
  )
  
studyPop <- data.frame(
      studyPop = c("ADULT", "ELDERLY")
)

primObj <- data.frame(
  primObjSeq = c("1", "2", "3"),
  primObj    = c("To determine if there is a statistically significant relationship between the change in both ADAS-Cog and CIBIC+ scores, and drug dose (0, 50 cm2 [54 mg], and 75 cm2 [81 mg])",
                       "To document the safety profile of the xanomeline TTS.",
                       "Evaluate the efficacy and safety of transdermal xanomeline, 50cm2 and 75cm2, and placebo in subjects with mild to moderate Alzheimer's disease."
                )
)

secObj <- data.frame(
  secObjSeq        = c("1", "2", "3", "4"),
  secObj           = c("To assess the dose-dependent improvement in behavior. Improved scores on the Revised Neuropsychiatric Inventory (NPI-X) will indicate improvement in these areas.",
                       "To assess the dose-dependent improvements in activities of daily living. Improved scores on the Disability Assessment for Dementia (DAD) will indicate improvement in these areas.",
                       "To assess the dose-dependent improvements in an extended assessment of cognition that integrates attention/concentration tasks. The ADAS-Cog (14) will be used for this assessment.",
                       "To assess the treatment response as a function of Apo E genotype."
                        )
)

trialType <- data.frame(
  trialType = c("EFF", "PK", "SAF")
)

# Treatment Arms have variable number of rdf:type. Define separately.
# Each arm defined on separate lines for the code below and must match
#   the number of items across variables. eg: PBO has two arm types, so 
#   all data for PBO has two values. This is just one kludgy way to do it.
arms <- data.frame(
  armAbbr    = c("Pbo", "Pbo",
                 "ScreenFailure",
                 "XanomelineHigh", "XanomelineHigh",
                 "XanomelineLow", "XanomelineLow"
  ),
  armType    = c("ControlArm", "RandomizationOutcome",
                  "FalseArm",
                  "InvestigationalArm","RandomizationOutcome",
                  "InvestigationalArm","RandomizationOutcome"
  ),
  armAltLbl  = c("Pbo","Pbo",
                 "Scrnfail",
                 "Xan_High","Xan_High",
                 "Xan_Lo","Xan_Lo"
  ),
  armPrefLbl = c("Placebo","Placebo",
                 "Screen Failure",
                "Xanomeline High","Xanomeline High",
                "Xanomeline Low", "Xanomeline Low"
  )
)

visits <- data.frame(
  visitActivity = c("AmbulECGPlace", "AmbulECGRemove", "Baseline", "Retrieval", 
    "Screening1", "Screening2", "Wk12", "Wk16", "Wk20", "Wk24", "Wk26", "Wk2",
    "Wk4", "Wk6", "Wk8" )
)


# Bring the data together
protocol  <- cbind.fill(singleRow, studyPop, primObj, secObj, trialType, arms, visits)

# Sort column names in the df for quicker referencing
protocol <- protocol %>% select(noquote(order(colnames(protocol))))

write.csv(protocol, file="data/source/protocol.csv", 
  row.names = F,
  na = "")



