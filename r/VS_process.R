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
vsVisits <- vsWide[,c("visit_Frag", "visitPerson_Frag","personNum", "visit", "visitnum", "vsdtc_Frag", "vsstat_Frag", "vsreasnd")]
# remove duplicate rows
vsVisits <-vsVisits[!duplicated(vsVisits), ]

# a kludge late in the process to remove NA introducted when adding values for
#   the prototype. 
#TODO: Fix this earlier!
vsVisits <- na.omit(vsVisits)  

# Loop through the unique visits. 
#   Note how vsWide could not be used here 
#   because it would result in mulitple copies of repeated literal values
#   like the label. Later, loop through vsWide to add the Subactivities
ddply(vsVisits, .(visitPerson_Frag), function(vsVisits)
{
    
    person <-  paste0("Person_", vsVisits$personNum)

    # Add visit to Person. Eg: Person_1 participatesIn visitScreening1_1 
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, person),
        paste0(prefix.STUDY,"participatesIn" ),
        paste0(prefix.CDISCPILOT01, vsVisits$visitPerson_Frag)
    )

        # Build out the visitScreening1_1 triples
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$visitPerson_Frag),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.OWL,"NamedIndividual")
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$visitPerson_Frag),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.CUSTOM,vsVisits$visit_Frag)
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$visitPerson_Frag),
            paste0(prefix.RDFS,"label" ),
            paste0("P", vsVisits$personNum, " Visit ", vsVisits$visitnum), type="string"
        )
        add.data.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$visitPerson_Frag),
            paste0(prefix.SKOS,"prefLabel" ),
            paste0(gsub(" ", "", vsVisits$visit)), type="string"
        )
        if (! is.na(vsVisits$vsstat_Frag)){
            add.triple(cdiscpilot01,
                paste0(prefix.CDISCPILOT01, vsVisits$visitPerson_Frag),
                paste0(prefix.STUDY,"activityStatus" ),
                paste0(prefix.CODE, vsVisits$vsstat_Frag)   
            )
        } 
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$visitPerson_Frag),
            paste0(prefix.STUDY,"hasCode" ),
            paste0(prefix.CUSTOM,vsVisits$visit_Frag)
        )
        add.triple(cdiscpilot01,
            paste0(prefix.CDISCPILOT01, vsVisits$visitPerson_Frag),
            paste0(prefix.STUDY,"hasDate" ),
            paste0(prefix.CDISCPILOT01,vsVisits$vsdtc_Frag)   
        )
        # Add that this date is a Visit Date (Date_<n> is a study:VisitDate)
        assignDateType(vsVisits$vsdtc, vsVisits$vsdtc_Frag, "VisitDate")
})

# Loop through vsWide to add the subActivites to each visit.
ddply(vsWide, .(personNum, vsseq), function(vsWide)
{
    # Body Positions
    add.triple(cdiscpilot01,
        paste0(prefix.CDISCPILOT01, vsWide$visitPerson_Frag),
        paste0(prefix.STUDY,"hasSubActivity" ),
        paste0(prefix.CDISCPILOT01,vsWide$AssumeBodyPos_Frag)   
    )
    # AsssumeBodyPosition sub-triples....    
    
    
})




#------------------------------------------------------------------------------
# Now build the subacivties assigned to each Visit. 
#  Eg: VisitScreening1_1 has: 
#  1) both Standing and Supine positions, both built out in this TTL
#  2) 


#------------------------------------------------------------------------------
# Triples from each row in the (widened) source domain
# Loop through each row in the widened df, create triples for each observation
#------------------------------------------------------------------------------
# First-level triples attached to Person_<n>
#ddply(vsWide, .(personNum, vsseq), function(vsWide)
#{
#    person <-  paste0("Person_", vsWide$personNum)
#    # Add visit to Person. Eg: VisitScreening1_1
#    add.triple(cdiscpilot01,
#        paste0(prefix.CDISCPILOT01, person),
#        paste0(prefix.STUDY,"participatesIn" ),
#        paste0(prefix.CDISCPILOT01, vsWide$visit_Frag)
#    )
##       #---- Build out the visit. Eg: VisitScreening1_1
#       #TODO: replace all visit_Frag with visit_Frag?
#       add.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
#           paste0(prefix.RDF,"type" ),
#           paste0(prefix.CUSTOM, vsWide$visit_Frag)
#       )
#       add.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
#           paste0(prefix.RDF,"type" ),
#           paste0(prefix.OWL, "NamedIndividual")
#       )
#       add.data.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
#           paste0(prefix.RDFS,"label" ),
#           paste0("P", vsWide$personNum, " Visit ", vsWide$visitnum), type="string"
#       )
#       add.data.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
#           paste0(prefix.SKOS,"prefLabel" ),
#           paste0(gsub(" ","", vsWide$visit)), type="string"
#       )
#
#       if (! is.na(vsWide$vsstat_Frag)){
#           add.triple(cdiscpilot01,
#               paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
#               paste0(prefix.STUDY,"activityStatus" ),
#               paste0(prefix.CODE, vsWide$vsstat_Frag)
#           )
#       }
#       
#       #       add.data.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
#           paste0(prefix.RDFS,"label" ),
#           paste0(gsub(" ","", vsWide$visit)), type="string"
#       )



#      add.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
#           paste0(prefix.STUDY,"hasDate"),
#           paste0(prefix.CDISCPILOT01,vsWide$vsdtc_Frag) 
#       )
#       # The date is a visit date, to mark it as such.
#       assignDateType(vsWide$vsdtc, vsWide$vsdtc_Frag, "VisitDate")

#AOQUESTION: 2017-05-26
#      add.data.triple(cdiscpilot01,
#           paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
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
#               paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
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
#               paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
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
#               paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
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
#            paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
#            paste0(prefix.RDFS,"label" ),
#            paste0("P", vsWide$personNum, "DBP", vsWide$visitnum), type="string"
#         )

#            add.triple(cdiscpilot01,
#            paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
#            paste0(prefix.RDF,"type" ),
#            paste0(prefix.CUSTOM, vsWide$visit_Frag)
#        )

#        
#        add.triple(cdiscpilot01,
#            paste0(prefix.CDISCPILOT01, vsWide$visit_Frag),
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
#})
   

