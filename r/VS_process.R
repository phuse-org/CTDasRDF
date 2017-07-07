###############################################################################
# FILE : VS_process.R
# DESC: Create VS domain triples
# REQ : 
# SRC : 
# IN  : 
# OUT : 
# NOTE: Logic decisions made on the vs field 
#        vstestOrder = sequence number created to facilitate triple creation/identification
# TODO: 
#   
#   
#   *****  Only DIABP working. Add SYSBP, and the other tests.
#           
#  
#  
# - Collapse the categories DIABP, SYSBP, etc. into functions?
###############################################################################

# Create Visit triples that should be created ONLY ONCE: Eg: Triples that describe an 
# individual visit. Eg: VisitScreening1_1
# Subset down to only the columns needed
uniqueVisits <- vsWide[,c("visit_Frag", "visitPerson_Frag","personNum", "visit", "visitnum", "vsdtc_Frag", "vsstat_Frag", "vsreasnd")]
# remove duplicate rows
# uniqueVisits <-uniqueVisits[!duplicated(uniqueVisits), ]
uniqueVisits <- uniqueVisits[!duplicated(uniqueVisits$visitPerson_Frag),]

# a kludge late in the process to remove NA introducted when adding values for
#   the prototype. 
#TODO: Fix this earlier!
uniqueVisits <- na.omit(uniqueVisits)  

# Loop through the unique visits. 
#   Note how vsWide could not be used here 
#   because it would result in mulitple copies of repeated literal values
#   like the label. Later, loop through vsWide to add the Subactivities
ddply(uniqueVisits, .(visitPerson_Frag), function(uniqueVisits)
{
    
    person <-  paste0("Person_", uniqueVisits$personNum)

    # Person_(n) ---> visit (visitPerson_Frag)
    # Add visit to Person. Eg: Person_1 participatesIn visitScreening1_1 
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, uniqueVisits$visitPerson_Frag)
    )

       #-- Visit sub triples. Eg: VisitScreening1_1
       add.triple(cdiscpilot01,
           paste0(prefix.CDISCPILOT01, uniqueVisits$visitPerson_Frag),
           paste0(prefix.RDF,"type" ),
           paste0(prefix.OWL,"NamedIndividual")
       )
       add.triple(cdiscpilot01,
           paste0(prefix.CDISCPILOT01, uniqueVisits$visitPerson_Frag),
           paste0(prefix.RDF,"type" ),
           paste0(prefix.CUSTOM,uniqueVisits$visit_Frag)
       )
       add.data.triple(cdiscpilot01,
           paste0(prefix.CDISCPILOT01, uniqueVisits$visitPerson_Frag),
           paste0(prefix.RDFS,"label" ),
           paste0("P", uniqueVisits$personNum, " Visit ", uniqueVisits$visitnum), type="string"
       )
       add.data.triple(cdiscpilot01,
           paste0(prefix.CDISCPILOT01, uniqueVisits$visitPerson_Frag),
           paste0(prefix.SKOS,"prefLabel" ),
           paste0(gsub(" ", "", uniqueVisits$visit)), type="string"
       )
       if (! is.na(uniqueVisits$vsstat_Frag)){
           add.triple(cdiscpilot01,
               paste0(prefix.CDISCPILOT01, uniqueVisits$visitPerson_Frag),
               paste0(prefix.STUDY,"activityStatus" ),
               paste0(prefix.CODE, uniqueVisits$vsstat_Frag)   
           )
       } 
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, uniqueVisits$visitPerson_Frag),
            paste0(prefix.STUDY,"hasCode" ),
            paste0(prefix.CUSTOM,uniqueVisits$visit_Frag)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, uniqueVisits$visitPerson_Frag),
            paste0(prefix.STUDY,"hasDate" ),
            paste0(prefix.CDISCPILOT01,uniqueVisits$vsdtc_Frag)   
        )
        # Add that this date is a Visit Date (Date_<n> is a study:VisitDate)
        assignDateType(uniqueVisits$vsdtc, uniqueVisits$vsdtc_Frag, "VisitDate")
})

# -- visit -- hasSubActivity --> x
# Loop through vsWide to add the subActivites to each visit.
#!!!ERROR: vsstat_Frag not created.
ddply(vsWide, .(personNum, vsseq), function(vsWide)
{
    # Body Positions
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, vsWide$visitPerson_Frag),
        paste0(prefix.STUDY,"hasSubActivity" ),
        paste0(prefix.CDISCPILOT01,vsWide$vspos_Frag)   
    )
    #---- AsssumeBodyPosition sub-triples....    
    # a) Standing
    if (grepl("Standing",vsWide$vspos_Frag)){
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.CODE,"AssumeBodyPositionStanding")   
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
            paste0(prefix.RDFS,"label" ),
            paste0("assume standing position")   
        )
        if (! is.na(vsWide$vsstat_Frag)) {
           add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
                paste0(prefix.STUDY,"activityStatus" ),
                paste0(prefix.CODE, vsWide$vsstat_Frag)   
            )
        }
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
            paste0(prefix.STUDY,"hasCode" ),
            paste0(prefix.CODE,"AssumeBodyPositionStanding")   
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
            paste0(prefix.STUDY,"hasDate" ),
            paste0(prefix.CDISCPILOT01,vsWide$vsdtc_Frag)   
        )
        # Link to SDTM terminology "upright position" 
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
            paste0(prefix.STUDY,"outcome" ),
            paste0(prefix.SDTM,"C71148.C62166")   
        )
    }
    
    # b) Supine
    else if (grepl("Supine",vsWide$vspos_Frag)){
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.CODE,"AssumeBodyPositionSupine")   
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
            paste0(prefix.RDFS,"label" ),
            paste0("assume supine position")   
        )
        if (! is.na(vsWide$vsstat_Frag)) {
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
                paste0(prefix.STUDY,"activityStatus" ),
                paste0(prefix.CODE, vsWide$vsstat_Frag)   
            )
        }
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
            paste0(prefix.STUDY,"hasCode" ),
            paste0(prefix.CODE,"AssumeBodyPositionSupine")   
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
            paste0(prefix.STUDY,"hasDate" ),
            paste0(prefix.CDISCPILOT01,vsWide$vsdtc_Frag)   
        )
        # Link to SDTM terminology "recumbent position" 
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
            paste0(prefix.STUDY,"outcome" ),
            paste0(prefix.SDTM,"C71148.C62167")   
        )
    }
#!!! NEW CODE UNTESTED BELOW HERE 2017-07-06
    #--SDTM CODES for test result 
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, vsWide$visitPerson_Frag),
        paste0(prefix.STUDY,"hasSubActivity" ),
        paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag)   
    )
        #---- test result subtriples
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.SDTMTERM, vsWide$vstestSDTMCode)
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.RDFS,"label" ),
            paste0("P", vsWide$personNum, "_", vsWide$testNumber)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.STUDY,"activityStatus" ),
            paste0(prefix.CODE, vsWide$vsstat_Frag)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.STUDY,"anatomicLocation" ),
            paste0(prefix.SDTMTERM, vsWide$vslocSDTMCode)
        )
        #AOQUESTION: Possible data fabrication issue. email to AO 2017-05-26
        if (! as.character(vsWide$vsblfl) == "") {
            add.data.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
                paste0(prefix.STUDY,"baselineFlag" ),
                paste0(vsWide$vsblfl), type="string"
            )
        }
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.STUDY,"bodyPosition" ),
            paste0(prefix.SDTMTERM, vsWide$posSDTMCode)
        )
        # derived flag. If non-missing, code the value as the object (Y, N...)
        if (! as.character(vsWide$vsdrvfl) == "") {
            add.data.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
                paste0(prefix.STUDY,"derivedFlag" ),
                paste0(vsWide$vsdrvfl), type="string"
            )
        }
        if (! as.character(vsWide$vsgrpid) == "") {
            add.data.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
                paste0(prefix.STUDY,"groupID" ),
                paste0(vsWide$vsgrpid), type="string"
            )
        }
        # Category & Subcategory hard coded. See email from AO May, 2017.
        #  May change with addition of more results.
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.STUDY,"hasCategory" ),
            paste0(prefix.CD01P, "category_1")
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.STUDY,"hasSubcategory" ),
            paste0(prefix.CD01P, "subcategory_1")
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.STUDY,"hasCode" ),
            paste0(prefix.SDTM, vsWide$vstestSDTMCode)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.STUDY,"hasPlannedDate" ),
            paste0(prefix.CDISCPILOT01, vsWide$vsdtc_Frag)
        )
        # StartRule
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.STUDY,"hasStartRule" ),
            paste0(prefix.CDISCPILOT01, vsWide$startRule_Frag)
        )
        #TODO: Add Subtriples for the start rule frags
         if (! is.na(vsWide$vslatSDTMCode)){
             add.triple(cdiscpilot01,
                 paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
                 paste0(prefix.STUDY,"laterality" ),
                 paste0(prefix.SDTMTERM, vsWide$vslatSDTMCode)
              )
         }
         add.triple(cdiscpilot01,
             paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
             paste0(prefix.CODE,"outcome" ),
             paste0(prefix.CUSTOM, vsWide$vsorres_Frag)
         )
         if (! is.na(vsWide$vsreasnd)){
             add.data.triple(cdiscpilot01,
                 paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
                 paste0(prefix.STUDY,"reasonNotDone" ),
                 paste0(vsWide$vsreasnd), type="string"
             )
         }
         add.data.triple(cdiscpilot01,
             paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
             paste0(prefix.STUDY,"seq" ),
             paste0(vsWide$vstestOrder), type="int"
         )
         add.data.triple(cdiscpilot01,
             paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
             paste0(prefix.STUDY,"sponsordefinedID" ),
             paste0(vsWide$invid), type="string"
         )
})
