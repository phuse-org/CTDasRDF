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
#     Move all hard coded Object values into VS_Frag and VS_Impute
#   
#  
#  
###############################################################################

# Create Visit triples that should be created ONLY ONCE: Eg: Triples that describe an 
# individual visit. Eg: VisitScreening1_1
u_Visit <- vsWide[,c("visit_Frag", "visitPerson_Frag","personNum", "visit", 
    "visitnum", "vsdtc_Frag", "vsstat_Frag", "vsreasnd")]

u_Visit <- u_Visit[!duplicated(u_Visit$visitPerson_Frag),] # remove duplicates

ddply(u_Visit, .(visitPerson_Frag), function(u_Visit)
{
    
    person <-  paste0("Person_", u_Visit$personNum)

    # Person_(n) ---> visit (visitPerson_Frag)
    # Add visit to Person. Eg: Person_1 participatesIn visitScreening1_1 
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag)
    )

       #-- Visit sub triples. Eg: VisitScreening1_1
       # Removed 2017-07-07 to match AO file
       #add.triple(cdiscpilot01,
       #    paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
       #    paste0(prefix.RDF,"type" ),
       #    paste0(prefix.OWL,"NamedIndividual")
       #)
       add.triple(cdiscpilot01,
           paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
           paste0(prefix.RDF,"type" ),
           paste0(prefix.CDISCPILOT01,u_Visit$visit_Frag)
       )
       add.data.triple(cdiscpilot01,
           paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
           paste0(prefix.RDFS,"label" ),
           paste0("P", u_Visit$personNum, " Visit ", u_Visit$visitnum), type="string"
       )
       add.data.triple(cdiscpilot01,
           paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
           paste0(prefix.RDFS,"label" ),
           paste0(gsub(" ", "", u_Visit$visit)), type="string"
       )
       add.data.triple(cdiscpilot01,
           paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
           paste0(prefix.SKOS,"prefLabel" ),
           paste0(gsub(" ", "", u_Visit$visit)), type="string"
       )
       if (! is.na(u_Visit$vsstat_Frag)){
           add.triple(cdiscpilot01,
               paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
               paste0(prefix.STUDY,"activityStatus" ),
               paste0(prefix.CODE, u_Visit$vsstat_Frag)   
           )
       } 
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
            paste0(prefix.STUDY,"hasCode" ),
            paste0(prefix.CDISCPILOT01,u_Visit$visit_Frag)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, u_Visit$visitPerson_Frag),
            paste0(prefix.STUDY,"hasDate" ),
            paste0(prefix.CDISCPILOT01,u_Visit$vsdtc_Frag)   
        )
        # This date is a Visit Date (Date_<n> is a study:VisitDate)
        assignDateType(u_Visit$vsdtc, u_Visit$vsdtc_Frag, "VisitDate")
})

# -- visit -- hasSubActivity --> x
# Loop through vsWide to add the subActivites to each visit.
ddply(vsWide, .(personNum, vsseq), function(vsWide)
{
    # Body Positions
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, vsWide$visitPerson_Frag),
        paste0(prefix.STUDY,"hasSubActivity" ),
        paste0(prefix.CDISCPILOT01,vsWide$vspos_Frag)   
    )
    
    #---- AsssumeBodyPosition sub-triples....    
    add.triple(cdiscpilot01,
     paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
     paste0(prefix.RDF,"type" ),
     paste0(prefix.CODE, vsWide$vsposCode_Frag)   
    )
    add.data.triple(cdiscpilot01,
     paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
     paste0(prefix.RDFS,"label" ),
     paste0(vsWide$vspos_Label)   
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
     paste0(prefix.CODE, vsWide$vsposCode_Frag)   
    )
    add.triple(cdiscpilot01,
     paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
     paste0(prefix.STUDY, "hasDate" ),
     paste0(prefix.CDISCPILOT01, vsWide$vsdtc_Frag)   
    )
    # Link to SDTM terminology "upright position" 
    add.triple(cdiscpilot01,
     paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag),
     paste0(prefix.STUDY, "outcome" ),
     paste0(prefix.SDTMTERM, vsWide$vsposSDTM_Frag)   
    )
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
            paste0(vsWide$vstestcd_Label)
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
        # Category & Subcategory hard coded in VS_Frag.R
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.STUDY,"hasCategory" ),
            paste0(prefix.CD01P, vsWide$vscat_Frag)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.STUDY,"hasSubcategory" ),
            paste0(prefix.CD01P, vsWide$vsscat_Frag)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
            paste0(prefix.STUDY,"hasCode" ),
            paste0(prefix.SDTMTERM, vsWide$vstestSDTMCode)
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
            #Add Subtriples for the start rule frags
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, vsWide$startRule_Frag),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.CODE, vsWide$startRuleType_Frag)
            )
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, vsWide$startRule_Frag),
                paste0(prefix.RDF,"type" ),
                paste0(prefix.CODE, "StartRule")
            )
            add.data.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, vsWide$startRule_Frag),
                paste0(prefix.RDFS,"label" ),
                paste0(paste0("startrule-", vsWide$vstestcd_Label))
            )
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, vsWide$startRule_Frag),
                paste0(prefix.CODE,"hasPrerequisite" ),
                paste0(prefix.CDISCPILOT01, vsWide$vspos_Frag)
            )
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, vsWide$startRule_Frag),
                paste0(prefix.STUDY,"hasCode" ),
                paste0(prefix.CODE, vsWide$startRuleType_Frag)
            )
        if (! is.na(vsWide$vslatSDTMCode)){
             add.triple(cdiscpilot01,
                 paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
                 paste0(prefix.STUDY,"laterality" ),
                 paste0(prefix.SDTMTERM, vsWide$vslatSDTMCode)
              )
         }
         add.triple(cdiscpilot01,
             paste0(prefix.CDISCPILOT01,vsWide$vstestSDTMCode_Frag),
             paste0(prefix.STUDY,"outcome" ),
             paste0(prefix.CDISCPILOT01, vsWide$vsorres_Frag)
         )
             # Build out the result triples
             add.triple(cdiscpilot01,
                 paste0(prefix.CDISCPILOT01, vsWide$vsorres_Frag),
                 paste0(prefix.RDF,"type" ),
                 paste0(prefix.STUDY, vsWide$vstestOutcomeType_Frag)
             )
             add.data.triple(cdiscpilot01,
                 paste0(prefix.CDISCPILOT01, vsWide$vsorres_Frag),
                 paste0(prefix.SKOS,"prefLabel" ),
                 paste0(vsWide$vstestOutcomeType_Label)
             )
             add.triple(cdiscpilot01,
                 paste0(prefix.CDISCPILOT01, vsWide$vsorres_Frag),
                 paste0(prefix.CODE,"hasUnit" ),
                 paste0(prefix.CODE, vsWide$vsstresu_Frag)
             )
             add.data.triple(cdiscpilot01,
                 paste0(prefix.CDISCPILOT01, vsWide$vsorres_Frag),
                 paste0(prefix.CODE,"hasValue" ),
                 paste0(vsWide$vsstresc)
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
