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
# - Collapse the categories DIABP, SYSBP, etc. into functions?
###############################################################################

vs <- readXPT("vs")

# Create numbering within each usubjid, vstestcd, sorted by date (vsdtc)
#    to allow creation of number triples within that category.    
# Convert for proper sorting
vs$vsdtc_ymd = as.Date(vs$vsdtc, "%Y-%m-%d")
# Sort by the categoies, including the date
vs <- vs[with(vs, order(usubjid, vstestcd, vsdtc_ymd)), ]

# Add ID numbers within categories, excluding date (used for sorting, not for cat number)
vs <- ddply(vs, .(usubjid, vstestcd), mutate, vstestOrder = order(vsdtc_ymd))

vs <- addPersonId(vs)

# Loop through the dataframe and create the triples for each Person_<n>
for (i in 1:nrow(vs))
{
    #DEV Limit to first 3 obs for testing purposes only
    if (i<4) 
    {
    person <-  paste0("Person_", vs[i,"personNum"])
    
    #-- DIABP 
    # uses coding as :  1_DBP_1  (person 1, DBP test 1), 1_DBP_2  (person 1, DBP test 2)
    # study:participatesIn cdiscpilot01:P1_DBP_1 ;
    if (vs[i, "vstestcd"] == "DIABP"){
        add.triple(store,
            paste0(prefix.CDISCPILOT01, person),
            paste0(prefix.STUDY,"participatesIn" ),
            paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"])
        )
        # Level 2 P(n)_DBP_(n)
        #TW if DiastolicBPMeasure in another file, this triple ends here.
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.STUDY, "DiastolicBPMeasure")
        )
        add.triple(store,
            paste0(prefix.CDISCPILOT01, "P", vs[i,"personNum"],"_DBP_", vs[i,"vstestOrder"]),
            paste0(prefix.STUDY,"activityStatus" ),
            paste0(prefix.CODE, "DiastolicBPMeasure")
        )
        
        
        
        
        #TODO Level 3 date-P(n)_DBP_(n)
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
    } # End limit of loop to first 3 obs
}    # End looping through the domain dataframe.    