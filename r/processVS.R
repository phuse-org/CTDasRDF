###############################################################################
# FILE : processVS.R
# DESC: Create VS domain triples
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: Logic decisions made on the vs field 
#        vstestOrder = sequence number created to facilitate triple creation/identification
# TODO: 
#   
#   *****  Only DIABP working. Add SYSBP, and the other tests.
#           
#   ** vsdtc was converted to date only. consider as mix of date and datetime 
#           as originally entered
#  * Recode to use switch() for recoding and Dddply() instead of FOR loops
#          see processSUPPDM.R for methods
# - Collapse the categories DIABP, SYSBP, etc. into functions?
###############################################################################

# Create numbering within each usubjid, vstestcd, sorted by date (vsdtc)
#    to allow creation of number triples within that category.    
# Convert for proper sorting
vs$vsdtc_ymd = as.Date(vs$vsdtc, "%Y-%m-%d")
# Sort by the categories, including the date
vs <- vs[with(vs, order(usubjid, vstestcd, vsdtc_ymd)), ]

# Add ID numbers within categories, excluding date (used for sorting, not for cat number)
vs <- ddply(vs, .(usubjid, vstestcd), mutate, vstestOrder = order(vsdtc_ymd))

#-- Data Creation for testing purposes. --------------------------------------- 
# Investigator ID hard coded. See also processDM.R
vs$invid  <- '123'

#---- vsloc  for DIABP, SYSBP all assigned as 'ARM' for development purposes.
# Unfactorize the  column to allow entry of a bogus data
vs$vsloc <- as.character(vs$vsloc)
vs$vsloc <- vs$vsloc[vs$testcd %in% c("DIABP", "SYSBP") ] <- "ARM"

# More imputations for the first 3 records to match data created by AO : 2016-01-19
vs$vsgrpid <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "GRPID1", "" )) 
vs$vsscat <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "SCAT1", "" )) 

# Assign 1st 3 obs as COMPLETE to match AO
vs$vsstat <- as.character(vs$vsstat) # Unfactorize to all allow assignment 
vs[1:3,grep("vsstat", colnames(vs))] <- "COMPLETE"

# vsspid
vs[vs$vsseq %in% c(1), "vsspid"]  <- "123"
vs[vs$vsseq %in% c(2), "vsspid"]  <- "719"
vs[vs$vsseq %in% c(3), "vsspid"]  <- "235"

# vslat
vs[vs$vsseq %in% c(1,3), "vslat"]  <- "RIGHT"
vs[vs$vsseq %in% c(2), "vslat"]    <- "LEFT"


vs[vs$vsseq %in% c(1), "vsblfl"]    <- "Y"


vs$vsdrvfl <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "N", "" )) 
vs$vsrftdtc <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "2013-12-16", "" )) 

#-- Data COding ---------------------------------------------------------------
#-- Value/Code Translation
# Translate values in the domain to their corresponding codelist code
# for linkage to the SDTM graph
# Example: vsloc  is coded to the SDTM Terminology graph by translating the value 
#  in the VS domain to its corresponding URI code in the SDTM terminology graph.
# TODO: This type of recoding to external graphs will be moved to a function
#        and driven by a config file and/or separate SPARQL query against the graph
#        that holds the codes, like SDTMTERM for the CDISC SDTM Terminology.
#---- vsloc
vs$vslocSDTMCode <- recode(vs$vsloc, 
                         "'ARM'         = 'C74456.C32141';
                          'EAR'         = 'C74456.C12394';                           
                          'ORAL CAVITY' = 'C74456.CC12421'" )
# bodyPosition
vs$posSDTMCode <- recode(vs$vspos, 
                           "'STANDING' = 'C71148.C62166';
                            'SUPINE'   = 'C71148.C62167'" )

# activity code
#  Note values in lowercase in SDTM terminlogy, unlike others above.
#    This is correct match with vstest case in source data 
vs$vstestSDTMCode <- recode(vs$vstest, 
                          "'Systolic Blood Pressure'  =   'C67153.C25298';
                           'Diastolic Blood Pressure' =   'C67153.C25299'" )
# laterality
vs$vslatSDTMCode <- recode(vs$vslat, 
                          "'RIGHT' = 'C99073.C25228';
                           'LEFT'  = 'C99073.C25229'" )

# Merge in the date fragment from the date dictionary created in createFrag.R
vs <- addDateFrag(vs, "vsdtc")  

#------------------------------------------------------------------------------
# vsstat
#------------------------------------------------------------------------------
vs <- createFragOneDomain(domainName=vs, processColumns="vsstat", fragPrefix="activitystatus"  )


# Create the codelist values for vsstat/activitystatus_<n>
vsstat <- vs[,c("vsstat", "vsstat_Frag")]
vsstat <- vsstat[!duplicated(vsstat), ]

vsstat$shortLabel[vsstat$vsstat=="COMPLETE"] <- 'CO'
vsstat$shortLabel[vsstat$vsstat=="NOT DONE"] <- 'ND'

# Loop through the arm_ codes to create  custom-terminology triples
ddply(vsstat, .(vsstat_Frag), function(vsstat)
{
    add.triple(code,
        paste0(prefix.CODE, vsstat$vsstat_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CODE, "ActivityStatus")
    )
    add.data.triple(code,
        paste0(prefix.CODE, vsstat$vsstat_Frag),
        paste0(prefix.RDFS,"label" ),
        paste0(vsstat$shortLabel), type="string"
    )
    # Original value here:  NOT DONE, COMPLETE
    add.data.triple(code,
        paste0(prefix.CODE, vsstat$vsstat_Frag),
        paste0(prefix.SKOS,"altLabel" ),
        paste0(vsstat$vsstat), type="string"
    )
    add.data.triple(code,
        paste0(prefix.CODE, vsstat$vsstat_Frag),
        paste0(prefix.SKOS,"prefLabel" ),
        paste0(vsstat$shortLabel), type="string"
    )
    
})



# Drop vars that are not needed in triple creation
dropMe <- c("studyid", "domain")  # usubjid used later, could be replaced by use of personNum
vs<-vs[ , !(names(vs) %in% dropMe)]



    ##DEL Delete following after new Fragments approach is implemented.
    ## Following is not implemented
    ##------------------------------------------------------------------------------
    ## valueCode()
    ##   Create a values code list that is later associated with the values for an individual.
    ##  Two parts needed: 1: Create the list values as a section of triples
    ##    2. Code the individiual person values to that triple.
    ##
    ## Cat col is used to select down to rows that contain the values
    ##    that will build the list. Eg: domain=vs, catCol="DIABP"
    ## See here: http://stackoverflow.com/questions/13040120/how-to-take-in-text-character-argument-without-quotes
    #
    ## domain = domain dataset (dm, vs...)
    ## catCol = 
    ## catVal = Category value used to subset down to the results. Eg: "DIABP", "SYSBP"
    ## resCol = The "result column" from which to obtain the list of unique values to be coded
    #valueCode <- function(domain, catCol, catVal, resCol)
    #{
    #    
    #    # Build:  vs[vs$vstestcd == "DIAPBP", ]
    #    # note use of [[]] instead of $ as per 
    #    # http://stackoverflow.com/questions/2641653/pass-a-data-frame-column-name-to-a-function
    #    tempDf <- domain[domain[[catCol]] == eval(substitute(catVal)), ]
    #    # tempU <- unique(tempDf[[resCol]])
    #    tempU <- domain[!duplicated(domain[[resCol]]), eval(substitute(resCol))]
    #    for (i in tempU)
    #    {
    #        # ADD THE TRIPLES HERE FOR WRITING. Write to STORE Is OK as is GLOBAL DF
    #        add.triple(cdiscpilot01,
    #                   paste0(prefix.CDISCPILOT01, person),
    #                   paste0(prefix.STUDY,"FOO" ),
    #                   paste0(prefix.STUDY,"FOO" )
    #        )
    #    }   
    #    
    #    return(tempU)
    #}
    # #assignment not needed? 
    #foo2<-valueCode(domain=vs, catCol="vstestcd", catVal="DIABP", resCol="vsorres")

library(reshape2)

# TESTIN HERE!!
# Cast the data from long to wide based on values in vstestcd
vsWide <- dcast(vs, ... ~ vstestcd, value.var="vsorres")

# Create IRI fragments
vsWide <- createFragOneDomain(domainName=vsWide, processColumns="DIABP", fragPrefix="DBP"  )
vsWide <- createFragOneDomain(domainName=vsWide, processColumns="SYSBP", fragPrefix="SBP"  )
vsWide <- createFragOneDomain(domainName=vsWide, processColumns="vspos", fragPrefix="vspos"  )

#TODO: Add fragments for the other results...

# visit_Frag is a special case that combines the text value of the visit name with the personNum
vsWide$personVisit_Frag <- paste0("visit_", gsub(" ", "", vsWide$visit), "_P", vsWide$personNum)
vsWide$visit_Frag <- paste0("visit_", vsWide$visitnum)  # Links to a visit description in custom:

# First-level triples attached to Person_<n>
ddply(vsWide, .(personNum, vsseq), function(vsWide)
{
    person <-  paste0("Person_", vsWide$personNum)
    
    # Each person has a visit in the VS dataset
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag)
    )
    
    if (! is.na(vsWide$DIABP_Frag)){
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
            paste0(prefix.STUDY,"hasSubActivity" ),
            paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag)
        )
    }
#WIP HERE    
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
        paste0(prefix.STUDY,"hasSubActivity" ),
        paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag)
    )
    
    
    
    
#TODO !!!!  MOVE THESE UNDER THE VISIT CREATION.
    
    
    # Build out the hasSubActivity triples under visit_<visitName>P<n>. Eg: visit_SCREENING2_P1
#                add.data.triple(cdiscpilot01,
#            paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#            paste0(prefix.RDFS,"label" ),
#            paste0("P", vsWide$personNum, "DBP", vsWide$visitnum), type="string"
#         )

#            add.triple(cdiscpilot01,
#            paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#            paste0(prefix.RDF,"type" ),
#            paste0(prefix.CUSTOM, vsWide$visit_Frag)
#        )

#        
#        add.triple(cdiscpilot01,
#            paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#            paste0(prefix.STUDY,"hasSubActivity" ),
#            paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag)
#        )
#            # Level 2 DBP_(n)
#            add.triple(cdiscpilot01,
#                paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#                paste0(prefix.RDF,"type" ),
#                paste0(prefix.STUDY, "DiastolicBPMeasure")
#            )
#            #TODO hasOutcome custom:bpoutcome_2   ??
#            
#            
#            
#            # anatomicLocation
#            add.triple(cdiscpilot01,
#                paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#                paste0(prefix.STUDY,"anatomicLocation" ),
#                paste0(prefix.STUDY, vsWide$vslocSDTMCode)
#            )
#            #baselineFlag
#            if (! as.character(vsWide$vsblfl) == "") {
#                add.data.triple(cdiscpilot01,
#                    paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#                    paste0(prefix.STUDY,"baselineFlag" ),
#                    paste0(vsWide$vsblfl), type="string"
#                )
#            }
#            # bodyPosition
#            add.triple(cdiscpilot01,
#                paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#                paste0(prefix.STUDY,"bodyPosition" ),
#                paste0(prefix.STUDY, vsWide$posSDTMCode)
#            )
#
#            # derivedflag
#            # If non-missing, code the value as the object (Y, N...)
#            if (! as.character(vsWide$vsdrvfl) == "") {
#                add.data.triple(cdiscpilot01,
#                    paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#                    paste0(prefix.STUDY,"derivedFlag" ),
#                    paste0(vsWide$vsdrvfl), type="string"
#                )
#            }
#            # groupID
#            if (! as.character(vsWide$vsgrpid) == "") {
#                add.data.triple(cdiscpilot01,
#                    paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#                    paste0(prefix.STUDY,"groupID" ),
#                    paste0(vsWide$vsgrpid), type="string"
#                )
#            }
#            # activityID
#           add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#               paste0(prefix.STUDY,"hasActivityID" ),
#               paste0(prefix.STUDY, vsWide$vstestSDTMCode)
#           )
#          
#           #TODO hasCategory custom:category_1
#           add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#               paste0(prefix.STUDY,"hasCategory" ),
#               paste0(prefix.CUSTOM, "TO_BE_DEFINED_")
#           )
#            
#            #TODO hasPlannedDate    (?planned? ask AO )
#            #add.triple(cdiscpilot01,
#            #  paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#            #   paste0(prefix.STUDY,"hasPlannedDate" ),
#            #    paste0(prefix.STUDY, vsWide$vstestSDTMCode)
#            #)
#           
#           #TODO hasPlannedDate    (?planned? ask AO )
#           
#           #TODO hasStartRule   
#        
#           #TODO hasSubcategory
#            
#           if ( ! is.na (vsWide$vslatSDTMCode)) {
#               add.triple(cdiscpilot01,
#                   paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),       
#                   paste0(prefix.STUDY,"laterality" ),
#                   paste0(vsWide$vslatSDTMCode)
#               )
#           }
#            
#           #TODO plannedReferenceTimePoint  code:timepoint-PT_STANDING                
#            
#           #TODO seq  vsTestOrder or vseq here?  Which source?
#           #add.triple(cdiscpilot01,
#           #   paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),       
#           #   paste0(prefix.STUDY,"seq" ),
#           #   paste0(vsWide$vstestOrder), type="int"
#           #)
#           
#           # sponsordefinedID
#           # NOTE: value is hard-coded in processDM.R
#           add.data.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#               paste0(prefix.STUDY,"sponsordefinedID" ),
#               paste0(vsWide$invid), type="string"
#           )
#    }
})
   

# Create Visit triples that should be created ONLY ONCE: Eg: TYPE, LABEL, PREFLABEL. 
# cdiscpilot:visit_<VISITTYPE><n>_P<n>
#   EG: cdiscpilot01:visit_SCREENING1_P1
# Subset down to only the columns needed
vsVisits <- vsWide[,c("personVisit_Frag", "visit_Frag", "personNum", "visit", "visitnum", "vsdtc_Frag")]
# remove duplicate rows
vsVisits <-vsVisits[!duplicated(vsVisits), ]

ddply(vsVisits, .(personVisit_Frag), function(vsVisits)
{
        #Build out visit_Frag here. Eg: visit_SCREENING1_P1 
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.CUSTOM,vsVisits$visit_Frag)   #TODO: Build out custom:visit_<n>
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
            paste0(prefix.RDFS,"label" ),
            paste0("P", vsVisits$personNum, " Visit ", vsVisits$visitnum), type="string"
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
            paste0(prefix.SKOS,"prefLabel" ),
            paste0(gsub(" ", "", vsVisits$visit)), type="string"
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
            paste0(prefix.STUDY,"hasDate" ),
            paste0(prefix.CDISCPILOT01,vsVisits$vsdtc_Frag)   #TODO: Build out custom:visit_<n>
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
            paste0(prefix.STUDY,"activityStatus" ),
            paste0(prefix.CODE,"activitystatus_",vsVisits$vsstat_Frag)   
            
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
            paste0(prefix.STUDY,"seq" ),
            paste0(vsVisits$visitnum), type="float"   
            
        )

})
