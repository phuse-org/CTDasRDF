###############################################################################
# FILE : processVS.R
# DESCR: Create VS domain triples
# SRC  : 
# KEYS : 
# NOTES: Logic decisions made on the vs field 
#        vstestOrder = sequence number created to facilitate triple creation/identification
# INPUT: 
#      : 
# OUT  : 
# REQ  : 
# TODO :  create a count identifer for each vstestcd BY PERSON
###############################################################################

vs <- readXPT("vs")

names(vs) <- gsub( "^vs\\.",  "", names(vs), perl = TRUE)

# Create numbering within each usubjid, vstestcd, sorted by date (vsdtc)
#    to allow creation of number triples within that category.    
# COnvert to numeric for proper sorting
vs$vsdtc_ymd = as.Date(vs$vsdtc, "%Y-%m-%d")
# Sort by the categoies, including the date
vs <- vs[with(vs, order(usubjid, vstestcd, vsdtc_ymd)), ]

# Add ID numbers within categories, excluding date (used for sorting, not for cat number)
vs<-ddply(vs, .(usubjid, vstestcd), mutate, vstestOrder = order(vsdtc_ymd))

vs<-addpersonId(vs)

# Loop through the dataframe and create the triples for each Person_<n>
#TODO: If possible, collapse these into a loop through DIABP, SYSBP, HEIGHT...
for (i in 1:nrow(vs))
{
    person <-  paste0("Person_", vs[i,"personNum"])
    
    #-- DIABP 
    # uses coding as :  1_DBP_1  (person 1, DBP test 1), 1_DBP_2  (person 1, DBP test 2)
    # study:participatesIn cdiscpilot01:P1_DBP_1 ;
    if (vs$vstestcd=="DIABP"){
        add.triple(store,
                   paste0(prefix.CDISCPILOT01, person),
                   paste0(prefix.STUDY,"participatesIn" ),
                   paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"])
        )
        #TODO subtriples for P(n)_DBP_(n)
        #TODO sub-subtriples for date-P(n)_DBP_(n)
    }
    #-- SYSBP
    #if (vs$vstestcd=="SYSBP"){
    #}
    
    #-- HEIGHT
    #if (vs$vstestcd=="SYSBP"){
    #}
    
    #-- PULSE
    #if (vs$vstestcd=="SYSBP"){
    #}
    
    #-- TEMP
    #if (vs$vstestcd=="SYSBP"){
    #}
    
    #-- WEIGHT
    #if (vs$vstestcd=="SYSBP"){
    #}
}    # End looping through the domain dataframe.    