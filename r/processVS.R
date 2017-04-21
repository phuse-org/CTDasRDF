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
#    USE createFrag to create the IRI fragments for DBP, then use those fragements to 
#       create the triples!
#  !! Recode to use switch() for recoding and Dddply() instead of FOR loops
#          See processSUPPDM.R for methods
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
#---- vsloc  for DIABP, SYSBP all assigned as 'ARM' for development purposes.
# Unfactorize the  column to allow entry of a bogus data
vs$vsloc <- as.character(vs$vsloc)
vs$vsloc <- vs$vsloc[vs$testcd %in% c("DIABP", "SYSBP") ] <- "ARM"


# More imputations for the first 3 records to match data created by AO : 2016-01-19
vs$vsgrpid <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "GRPID1", "" )) 
vs$vsscat <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "SCAT1", "" )) 
vs$vsstat <- with(vs, ifelse(vsseq %in% c(1,2,3) & personNum == 1, "COMPLETE", "" )) 


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
    #        add.triple(store,
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
# Cast the data from long to wide based on values in vstestcd
vsWide <- dcast(vs, ... ~ vstestcd, value.var="vsorres")

# Create IRI fragments
vsWide <- createFragOneDomain(domainName=vsWide, processColumns="DIABP", fragPrefix="DBP"  )
vsWide <- createFragOneDomain(domainName=vsWide, processColumns="SYSBP", fragPrefix="SBP"  )
#TODO: Add fragments for the other results...

# visit_Frag is a special case that combines the text value of the visit name with the personNum
vsWide$personVisit_Frag <- paste0("visit_", gsub(" ", "", vsWide$visit), "_P", vsWide$personNum)
vsWide$visit_Frag <- paste0("visit_", vsWide$visitnum)  # Links to a visit description in custom:

# Loop through the datafram
ddply(vsWide, .(personNum, vsseq), function(vsWide)
{
    person <-  paste0("Person_", vsWide$personNum)
    
    # Each person has a visit in the VS dataset
    add.triple(store,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag)
    )
        #Build out visit_Frag here. Eg: visit_SCREENING1_P1 
        add.triple(store,
            paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.CUSTOM,vsWide$visit_Frag)   #TODO: Build out custom:visit_<n>
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
            paste0(prefix.RDFS,"label" ),
            paste0("P", personNum, "Visit", visitnum), type="string"
        )
        add.data.triple(store,
            paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
            paste0(prefix.SKOS,"prefLabel" ),
            paste0(gsub(" ", "", vsWide$visit)), type="string"
        )
        
        #TODO: Add 1. activitysatus_1  ...
        #          2. hasDate Date_19a  (?? wha is the a?)  EMAIL TO AO re. DATE/DATETIMES
        # 3. Add DBP_1, DBP_2 etc.
        # using: If vsWide$DIABP_FRAG != missing, then write the triple.
        #  4. bodypos_P1Standing, bodypos_P1Supine
        #   5. study:seq "1" as float
        
        
        
})
    

#TW GARBAGE follows. Use as source bin for new code, then DELETE
    #-- DIABP 
    # uses coding as :  1_DBP_1  (person 1, DBP test 1), 1_DBP_2  (person 1, DBP test 2)
    # study:participatesIn cdiscpilot01:P1_DBP_1 ;
   # if (vs[i, "vstestcd"] == "DIABP"){
   #        add.triple(store,
   #         paste0(prefix.CDISCPILOT01, person),
  #            paste0(prefix.STUDY,"participatesIn" ),
   #         paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"])
    #    )
        # Level 2 P(n)_DBP_(n)
        #TW if DiastolicBPMeasure in another file, this triple ends here.
    #    add.triple(store,
    #        paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
    #        paste0(prefix.RDF,"type" ),
    #        paste0(prefix.STUDY, "DiastolicBPMeasure")
    #    )
#        add.triple(store,
#            paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
#            paste0(prefix.STUDY,"activityStatus" ),
#            paste0(prefix.CODE, "DiastolicBPMeasure")
#        )
        
        #-- SDTM codes for next triples...
        #---- Anatomic Location
#       add.triple(store,
#           paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
#           paste0(prefix.STUDY,"anatomicLocation" ),
#           paste0(prefix.CDISCSDTM, vs[i,"vslocSDTMCode"]) 
#       )
#       #---- Body Position
#       add.triple(store,
#           paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
#           paste0(prefix.STUDY,"bodyPosition" ),
#           paste0(prefix.CDISCSDTM, vs[i,"posSDTMCode"]) 
#       )
#       #---- SDTM Activity Code
#       add.triple(store,
#           paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
#           paste0(prefix.STUDY,"hasActivityCOde" ),
#           paste0(prefix.CDISCSDTM, vs[i,"vstestSDTMCode"]) 
#       )
#       #---- SDTM laterality Code
#       if (! as.character(vs[i,"vslatSDTMCode"]) == "") {
#           add.data.triple(store,
#               paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
#               paste0(prefix.STUDY,"groupID" ),
#               paste0(vs[i, "vslatSDTMCode"]), type="string"
#           )
#       } 
#       
#       
#       #TODO Improve code here to deal with the possible vsstat values
#       if (vs[i, "vsstat"] == "COMPLETE"){
#           add.triple(store,
#               paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
#               paste0(prefix.STUDY,"activityStatus" ),
#               paste0(prefix.CODE, "activitystatus-CO") 
#           )
#       }    
#       
#       # Baseline flag
#       # If non-missing, code the value as the object (Y, N...)
#       if (! as.character(vs[i,"vsblfl"]) == "") {
#           add.data.triple(store,
#               paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
#               paste0(prefix.STUDY,"baselineFlag" ),
#               paste0(vs[i, "vsblfl"]), type="string"
#           )
#       }    
#       # Derived flag
#       # If non-missing, code the value as the object (Y, N...)
#       if (! as.character(vs[i,"vsdrvfl"]) == "") {
#           add.data.triple(store,
#               paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
#               paste0(prefix.STUDY,"derivedFlag" ),
#               paste0(vs[i, "vsdrvfl"]), type="string"
#           )
#       }    
#       # Group ID
#       # If non-missing, code the value as the object (Y, N...)
#       if (! as.character(vs[i,"vsgrpid"]) == "") {
#           add.data.triple(store,
#               paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
#               paste0(prefix.STUDY,"groupID" ),
#               paste0(vs[i, "vsgrpid"]), type="string"
#           )
#       } 
          
 