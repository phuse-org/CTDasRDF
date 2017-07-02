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
#   !!!ERROR  in assignment of vss# Add visit to Person. Eg: visit_SCREENING1_P1tat_Frag in vsWide. Possibly move fragment creation to 
#       after creation of vsWide?
#   *****  Only DIABP working. Add SYSBP, and the other tests.
#           
#  * Recode to use switch() for recoding and Dddply() instead of FOR loops
#          see SUPPDM_process.R for methods
# - Collapse the categories DIABP, SYSBP, etc. into functions?
###############################################################################

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
#           # NOTE: value is hard-coded in DM_process.R
#           add.data.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$DIABP_Frag),
#               paste0(prefix.STUDY,"sponsordefinedID" ),
#               paste0(vsWide$invid), type="string"
#           )
#    }
})
   

