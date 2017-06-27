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
#   !!!ERROR  in assignment of vss# Add visit to Person. Eg: visit_SCREENING1_P1tat_Frag in vsWide. Possibly move fragment creation to 
#       after creation of vsWide?
#   *****  Only DIABP working. Add SYSBP, and the other tests.
#           
#  * Recode to use switch() for recoding and Dddply() instead of FOR loops
#          see processSUPPDM.R for methods
# - Collapse the categories DIABP, SYSBP, etc. into functions?
###############################################################################
#-- Data Creation for prototype development -----------------------------------
# Create numbering within each usubjid, vstestcd, sorted by date (vsdtc)
#    to allow creation of number triples within that category.    
# Convert for proper sorting 
#TODO: Evaluate next lines if needed now that using Frag approach
vs$vsdtc_ymd = as.Date(vs$vsdtc, "%Y-%m-%d")
# Sort by the categories, including the date
vs <- vs[with(vs, order(usubjid, vstestcd, vsdtc_ymd)), ]
# Add ID numbers within categories, excluding date (used for sorting, not for cat number)
vs <- ddply(vs, .(usubjid, vstestcd), mutate, vstestOrder = order(vsdtc_ymd))


#-- End Data Creation ---------------------------------------------------------
#-- Data Coding ---------------------------------------------------------------
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

#-- Fragment Creation and merging ---------------------------------------------
vs <- addDateFrag(vs, "vsdtc")  
vs <- createFragOneDomain(domainName=vs, processColumns="vsstat", fragPrefix="activitystatus")

# Create bpoutcome_n fragment. 
#  Blood pressure results come from both SYSBP and DIABP so only these values from 
#    vstestcd / vsorres must be coded to bpoutcome
#TODO Later this becomes a function to allow creation of similar 
# fragments that rely on values from different vstestcd. 
# Possible solution: createFragOneDomain: add another parameter: valSubset that creates 
#    the fragment numbering based only a subset of values in the column: eg; SYSBP, DIABP
vstestcd.subset <- vs[,c("vstestcd", "vsorres", "vsorresu")]
vstestcd.subset.bp <- subset(vstestcd.subset, vstestcd %in% c("SYSBP", "DIABP"))

# create the bpoutcome_(n) fragment
vstestcd.subset.bp  <- createFragOneDomain(domainName=vstestcd.subset.bp, 
       processColumns=c("vsorres"), fragPrefix="bpoutcome", numSort = TRUE)

# Keep only the value field for the match (vsorres) and the fragement to merge in
vstestcd.frag <- vstestcd.subset.bp[, c("vsorres", "vsorres_Frag")]

# Merge the vsorres_Frag created in the steps above back into the VS domain.
vs <- merge(x = vs, y = vstestcd.frag, by.x="vsorres", by.y="vsorres", all.y = TRUE)

#  NOTE: Other test value fragements are created from vsWide to disttinguish between
#   similar and dissimilar tests AT THE TEST LEVEL attached to a PERSON_(n)
# Cast the data from long to wide based on values in vstestcd
vsWide <- dcast(vs, ... ~ vstestcd, value.var="vsorres")

# Fragments for the type of test: DIABP_<n>, SYSBP_<n>, but NOT for the numeric results of those
#   tests. See later frag creation.
vsWide <- createFragOneDomain(domainName=vsWide, processColumns="DIABP", fragPrefix="DBP")
vsWide <- createFragOneDomain(domainName=vsWide, processColumns="SYSBP", fragPrefix="SBP")
# Results in problem of additional columns SYSBP_Frag, DIABP_Frag as already created!
# vsWide <- createFragOneDomain(domainName=vsWide, 
#    processColumns=c("SYSBP", "DIABP"), fragPrefix="bpoutcome", numSort = TRUE)

#TODO: Add fragments for the other results...
# visit_Frag is a special case that combines the text value of the visit name with the personNum
# vsWide$personVisit_Frag <- paste0("VisitScreening", gsub(" ", "", vsWide$visit), "_", vsWide$personNum)
vsWide$visit_Frag <- sapply(vsWide$visit,function(x) {
    switch(as.character(x),
        'SCREENING 1' = 'VisitScreening1',
        as.character(x) ) } )
# add personNum to finish creation of the fragment.
vsWide$visit_Frag <- paste0(vsWide$visit_Frag,"_",vsWide$personNum)

#TODO: evaluate the use of this next statement.
#vsWide$visit_Frag <- paste0("visit_", vsWide$visitnum)  # Links to a visit description in custom:

# end fragment creation

# Create the codelist values for vsstat/activitystatus_<n>
vsstat <- vs[,c("vsstat", "vsstat_Frag")]
vsstat <- vsstat[!duplicated(vsstat), ]

vsstat$shortLabel[vsstat$vsstat=="COMPLETE"] <- 'CO'
vsstat$shortLabel[vsstat$vsstat=="NOT DONE"] <- 'ND'

#------------------------------------------------------------------------------
#  Single/Unique Resource Creation for CUSTOM, CODE, CDISCPILOT01 namespaces
#   Create triples for unique values (ones that are not one obs per patient)
#    eg. Treatment arm, country, etc.
#------------------------------------------------------------------------------
#-- CUSTOM namespace ----------------------------------------------------------

# visit_n
valToIndex <-vsWide[,c("visit_Frag", "visit")]
valToIndex <- unique(valToIndex)  # list of unique values
# a kludge late in the process to remove NA introducted when adding values for
#   the prototype. 
#TODO: Fix this earlier!
valToIndex <- na.omit(valToIndex)  
ddply(valToIndex, .(visit_Frag), function(valToIndex)
{
    add.triple(custom,
        paste0(prefix.CUSTOM, valToIndex$visit_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.OWL, "Class")
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, valToIndex$visit_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CUSTOM, "Visit")
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, valToIndex$visit_Frag),
        paste0(prefix.RDFS,"label" ),
        paste0(valToIndex$visit), type="string"
    )
    add.triple(custom,
        paste0(prefix.CUSTOM, valToIndex$visit_Frag),
        paste0(prefix.RDFS,"subClassOf"),
        paste0(prefix.CUSTOM, "Visit")
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, valToIndex$visit_Frag),
        paste0(prefix.SKOS,"prefLabel" ),
        paste0(valToIndex$visit), type="string"
    )
})


## bpoutcome_<n> 
#    from  vstestcd.subset.bp : "vstestcd", "vsorres", "vsorresu")]
#    to create the values list in the CUSTOM file
# TODO: Wrap this within another function that process data similar to the vstestcd.subset.bp 
ddply(vstestcd.subset.bp, .(vsorres_Frag), function(vstestcd.subset.bp)
{
    add.triple(custom,
        paste0(prefix.CUSTOM, vstestcd.subset.bp$vsorres_Frag),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.CUSTOM, "BloodPressureOutcome")
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, vstestcd.subset.bp$vsorres_Frag),
        paste0(prefix.SKOS,"prefLabel" ),
        paste0(vstestcd.subset.bp$vsorres, " ",vstestcd.subset.bp$vsorresu )
    )
    # Note: Pressure Unit URI is hard coded kludge
    add.triple(custom,
        paste0(prefix.CUSTOM, vstestcd.subset.bp$vsorres_Frag),
        paste0(prefix.CODE,"hasUnit" ),
        paste0(prefix.CODE, "pressureunit_1")
    )
    add.data.triple(custom,
        paste0(prefix.CUSTOM, vstestcd.subset.bp$vsorres_Frag),
        paste0(prefix.CODE,"hasValue" ),
        paste0(vstestcd.subset.bp$vsorres), type="int"
    )
    
    
})



#-- CODE namespace ------------------------------------------------------------
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
    # Original value here, equals  'NOT DONE', 'COMPLETE'
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

#------------------------------------------------------------------------------
#-- CDISCPILOT01 namespace
# Create Visit triples that should be created ONLY ONCE: Eg: Triples that describe an 
# individual visit. Eg: visit_<VISITTYPE><n>_P<n> = cdiscpilot01:visit_SCREENING1_P1

#---- visit_<VISITTYPE><n>_P<n>
# Subset down to only the columns needed
#DEL 2017-06-14 vsVisits <- vsWide[,c("personVisit_Frag", "visit_Frag", "personNum", "visit", "visitnum", "vsdtc_Frag", "vsstat_Frag", "vsreasnd")]
vsVisits <- vsWide[,c("visit_Frag", "personNum", "visit", "visitnum", "vsdtc_Frag", "vsstat_Frag", "vsreasnd")]
# remove duplicate rows
vsVisits <-vsVisits[!duplicated(vsVisits), ]

# a kludge late in the process to remove NA introducted when adding values for
#   the prototype. 
#TODO: Fix this earlier!
vsVisits <- na.omit(vsVisits)  

###ddply(vsVisits, .(personVisit_Frag), function(vsVisits)
###{
###        #Build out visit_Frag here. Eg: visit_SCREENING1_P1 
###        add.triple(cdiscpilot01,
###            paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
###            paste0(prefix.RDF,"type" ),
###            paste0(prefix.CUSTOM,vsVisits$visit_Frag)   #TODO: Build out custom:visit_<n>
###        )
###        add.data.triple(cdiscpilot01,
###            paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
###            paste0(prefix.RDFS,"label" ),
###            paste0("Person ", vsVisits$personNum, " Visit ", vsVisits$visitnum), type="string"
###        )
###        add.data.triple(cdiscpilot01,
###            paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
###            paste0(prefix.SKOS,"prefLabel" ),
###            paste0(gsub(" ", "", vsVisits$visit)), type="string"
###        )
###        add.triple(cdiscpilot01,
###            paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
###            paste0(prefix.STUDY,"hasDate" ),
###            paste0(prefix.CDISCPILOT01,vsVisits$vsdtc_Frag)   #TODO: Build out custom:visit_<n>
###        )
###            # Add that this date is a Visit Date (Date_<n> is a study:VisitDate)
###            add.triple(cdiscpilot01,
###                paste0(prefix.CDISCPILOT01, vsVisits$vsdtc_Frag),
###                paste0(prefix.RDF,"type" ),
###                paste0(prefix.STUDY, "VisitDate")
###            )
###        if (! is.na(vsVisits$vsstat_Frag)){
###            add.triple(cdiscpilot01,
###                paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
###                paste0(prefix.STUDY,"activityStatus" ),
###                paste0(prefix.CODE, vsVisits$vsstat_Frag)   
###            
###            )
###        }    
###        add.data.triple(cdiscpilot01,
###            paste0(prefix.CDISCPILOT01, vsVisits$personVisit_Frag),
###            paste0(prefix.STUDY,"seq" ),
###            paste0(vsVisits$visitnum), type="float"   
###            
###        )
###
###})
###
###
#------------------------------------------------------------------------------
# Triples from each row in the (widened) source domain
# Loop through each row in the widened df, create triples for each observation
#------------------------------------------------------------------------------
# First-level triples attached to Person_<n>
ddply(vsWide, .(personNum, vsseq), function(vsWide)
{
    person <-  paste0("Person_", vsWide$personNum)
    # Add visit to Person. Eg: visit_SCREENING1_P1
    # Add visit to Person. Eg: VisitScreening1_1
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, vsWide$visit_Frag)
    )
    
    
    
    
#       #---- Build out the visit. Eg: VisitScreening1_1
#      #TODO: replace all personVisit_Frag with visit_Frag?
#       add.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#           paste0(prefix.RDF,"type" ),
#           paste0(prefix.CUSTOM, vsWide$visit_Frag)
#       )
#       add.data.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#           paste0(prefix.RDFS,"label" ),
#           paste0(gsub(" ","", vsWide$visit)), type="string"
#       )
#       add.data.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#           paste0(prefix.RDFS,"label" ),
#           paste0("P", vsWide$personNum, " Visit ", vsWide$visitnum), type="string"
#       )


#       add.data.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#           paste0(prefix.SKOS,"prefLabel" ),
#           paste0(gsub(" ","", vsWide$visit)), type="string"
#       )

#       if (! is.na(vsWide$vsstat_Frag)){
#           add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#               paste0(prefix.STUDY,"activityStatus" ),
#               paste0(prefix.CODE, vsWide$vsstat_Frag)
#           )
#      }
#      add.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#           paste0(prefix.STUDY,"hasDate"),
#           paste0(prefix.CDISCPILOT01,vsWide$vsdtc_Frag) 
#       )
#       # The date is a visit date, to mark it as such.
#       assignDateType(vsWide$vsdtc, vsWide$vsdtc_Frag, "VisitDate")

#AOQUESTION: 2017-05-26
#      add.data.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#           paste0(prefix.STUDY,"seq"),
#           # paste0(vsWide$vsseq), type="int" 
#           paste0(vsWide$visitnum), type="int"     
#       )

#      
#       #Activity Status CO/activitystatus_1 ; ND/activitystatus_2 is attached to the 
#       if (! is.na(vsWide$vsstat_Frag)){
#           add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01,"AssumeBodyPositionStanding_", vsWide$personNum), 
#               paste0(prefix.STUDY,"activityStatus" ),
#               paste0(prefix.CODE, vsWide$vsstat_Frag)
#           )
#       }

#      
#      #TODO: Condense the STANDING/SUPINE triple creation into a function with values STANDING/SUPINE...

#      # Next triple should cover addition of Objects like AssumeBodyPositionStanding_(n) discpilot01:AssumeBodyPositionSupine_(n)
#      if( vsWide$vspos =="STANDING"){
#          add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#               paste0(prefix.STUDY,"hasSubActivity"),
#               paste0(prefix.CDISCPILOT01,"AssumeBodyPositionStanding_", vsWide$personNum) 
#          )
#              #----AssumeBodyPositionStanding_(n) subtriples
#              add.triple(cdiscpilot01,
#                  paste0(prefix.CDISCPILOT01,"AssumeBodyPositionStanding_", vsWide$personNum), 
#                  paste0(prefix.RDF,"type" ),
#                  paste0(prefix.CODE, "AssumeBodyPositionStanding")
#              )
#              add.data.triple(cdiscpilot01,
#                  paste0(prefix.CDISCPILOT01,"AssumeBodyPositionStanding_", vsWide$personNum), 
#                  paste0(prefix.RDFS,"label" ),
#                  paste0("assume standing position"), type="string"
#              )
#              add.triple(cdiscpilot01,
#                  paste0(prefix.CDISCPILOT01,"AssumeBodyPositionStanding_", vsWide$personNum),
#                  paste0(prefix.CODE,"hasOutcome" ),
#                  paste0(prefix.SDTMTERM, vsWide$posSDTMCode)
#              )
#CONFIRM: DATE_19 triple need an assignDate call here to assign type to that date URI?
#              add.triple(cdiscpilot01,
#                  paste0(prefix.CDISCPILOT01,"AssumeBodyPositionStanding_", vsWide$personNum), 
#                  paste0(prefix.STUDY,"hasDate" ),
#                  paste0(prefix.CDISCPILOT01, vsWide$vsdtc_Frag)
#              )
#      }
#      else if ( vsWide$vspos =="SUPINE"){
#          add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#               paste0(prefix.STUDY,"hasSubActivity"),
#               paste0(prefix.CDISCPILOT01,"AssumeBodyPositionSupine_", vsWide$personNum) 
#          )
#              #----AssumeBodyPositionSupine_(n) subtriples
#              add.triple(cdiscpilot01,
#                  paste0(prefix.CDISCPILOT01,"AssumeBodyPositionSupine_", vsWide$personNum), 
#                  paste0(prefix.RDF,"type" ),
#                  paste0(prefix.CODE, "AssumeBodyPositionSupine")
#              )
#              add.data.triple(cdiscpilot01,
#                  paste0(prefix.CDISCPILOT01,"AssumeBodyPositionSupine_", vsWide$personNum), 
#                  paste0(prefix.RDFS,"label" ),
#                  paste0("assume supine position"), type="string"
#              )
#              add.triple(cdiscpilot01,
#                  paste0(prefix.CDISCPILOT01,"AssumeBodyPositionSupine_", vsWide$personNum), 
#                  paste0(prefix.CODE,"hasOutcome" ),
#                  paste0(prefix.SDTMTERM, vsWide$posSDTMCode)
#              )
#CONFIRM: Correct status fragment used?
#              
#              if (! is.na(vsWide$vsstat_Frag)){
#                  add.triple(cdiscpilot01,
#                      paste0(prefix.CDISCPILOT01,"AssumeBodyPositionSupine_", vsWide$personNum),
#                      paste0(prefix.STUDY,"activityStatus" ),
#                      paste0(prefix.CODE, vsWide$vsstat_Frag)
#                  )
#              }
#CONFIRM: DATE_19 triple need an assignDate call here to assign type to that date URI?
#              add.triple(cdiscpilot01,
#                  paste0(prefix.CDISCPILOT01,"AssumeBodyPositionSupine_", vsWide$personNum),
#                  paste0(prefix.STUDY,"hasDate" ),
#                  paste0(prefix.CDISCPILOT01, vsWide$vsdtc_Frag)
#              )
#      }

#       #-- DBP_(n) attached to visit_(VISIT)_(n)
#       if (! is.na(vsWide$DIABP_Frag)){
#           add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$personVisit_Frag),
#               paste0(prefix.STUDY,"hasSubActivity" ),
#               paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag)
#           )
#          #DBP_<n> is created per person, per row of DIABP data in vsWide 
#           #---- Level 2 DBP_(n)
#           #        bpoutcome_(n)
#           add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#               paste0(prefix.CODE,"hasOutcome" ),
#               paste0(prefix.CUSTOM, vsWide$vsorres_Frag)
#           )
#           add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#               paste0(prefix.RDF,"type" ),
#               paste0(prefix.SDTMTERM, vsWide$vstestSDTMCode)
#           )
#           add.data.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#               paste0(prefix.RDFS,"label" ),
#               paste0("P", vsWide$personNum, " ", gsub("_", " ", vsWide$DIABP_Frag))
#           )
#           add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#               paste0(prefix.STUDY,"activityStatus" ),
#               paste0(prefix.CODE, vsWide$vsstat_Frag)
#           )
#           # anatomicLocation
#           add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#               paste0(prefix.STUDY,"anatomicLocation" ),
#               paste0(prefix.SDTMTERM, vsWide$vslocSDTMCode)
#           )
#           #baselineFlag
#AOQUESTION: Possible data fabrication issue. email to AO 2017-05-26
#           if (! as.character(vsWide$vsblfl) == "") {
#               add.data.triple(cdiscpilot01,
#                  paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#                  paste0(prefix.STUDY,"baselineFlag" ),
#                  paste0(vsWide$vsblfl), type="string"
#              )
#          }
#          # bodyPosition
#          add.triple(cdiscpilot01,
#              paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#              paste0(prefix.STUDY,"bodyPosition" ),
#              paste0(prefix.SDTMTERM, vsWide$posSDTMCode)
#          )
#          # derivedflag
#          # If non-missing, code the value as the object (Y, N...)
#          if (! as.character(vsWide$vsdrvfl) == "") {
#              add.data.triple(cdiscpilot01,
#                  paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#                  paste0(prefix.STUDY,"derivedFlag" ),
#                  paste0(vsWide$vsdrvfl), type="string"
#              )
#          }
#          # groupID
#          if (! as.character(vsWide$vsgrpid) == "") {
#              add.data.triple(cdiscpilot01,
#                  paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#                  paste0(prefix.STUDY,"groupID" ),
#                  paste0(vsWide$vsgrpid), type="string"
#              )
#          }
#AOQuestion. Category and Subcategory is hard coded. What is the source and fnt of this triple? CUSTOM: is not helpful.
#         add.triple(cdiscpilot01,
#             paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#             paste0(prefix.STUDY,"hasCategory" ),
#             paste0(prefix.CUSTOM, "category_1")
#         )
#         add.triple(cdiscpilot01,
#             paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#             paste0(prefix.STUDY,"hasSubcategory" ),
#             paste0(prefix.CUSTOM, "subcategory_1")
#         )
#          add.triple(cdiscpilot01,
#              paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#              paste0(prefix.STUDY,"hasPlannedDate" ),
#              paste0(prefix.CDISCPILOT01, vsWide$vsdtc_Frag)
#          )


#AOQuestion: start rule is hard coded. How add from data??
#TODO Must make conditional and dynamice for _1 suffix!
#         add.triple(cdiscpilot01,
#             paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#             paste0(prefix.STUDY,"hasStartRule" ),
#             paste0(prefix.CDISCPILOT01, "StartRuleLying5_1")
#         )
#TODO: ADD coding of child triples for CDISCPILOT01:StartRuleLying5_1
#         if (! is.na(vsWide$vslatSDTMCode)){
#             add.triple(cdiscpilot01,
#                 paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#                 paste0(prefix.STUDY,"laterality" ),
#                 paste0(prefix.SDTMTERM, vsWide$vslatSDTMCode)
#              )
#         }

#         
#         if (! is.na(vsWide$vsreasnd)){
#             add.data.triple(cdiscpilot01,
#                 paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#                 paste0(prefix.STUDY,"reasonNotDone" ),
#                 paste0(vsWide$vsreasnd), type="string"
#             )
#         }
#         add.data.triple(cdiscpilot01,
#             paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#             paste0(prefix.STUDY,"seq" ),
#             paste0(vsWide$vstestOrder), type="int"
#         )
#         add.data.triple(cdiscpilot01,
#             paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#             paste0(prefix.STUDY,"sponsordefinedID" ),
#             paste0(vsWide$invid), type="string"
#         )
#       }# end processing of DIABP     



    
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
#           
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
   

