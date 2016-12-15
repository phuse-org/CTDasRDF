###############################################################################
# Name : singleResources.R
# AUTH : Tim W. 
# DESCR: Create triples for resources that existin ONCE in the graph in contrast
#            to those created once for each person. Includes items like 
#            investigators, treatment ARMs, etc.
# NOTES: 
# IN   : masterData dataframe
# OUT  : 
# REQ  : Called from buildRDF-Driver.R
# TODO : 
###############################################################################

#-- Investigators
# Get unique investigator ID 
investigators <- masterData[,c("invnam", "invid")]
# Remove duplicates
investigators <- investigators[!duplicated(investigators),]

# Loop through the unique investigators, building the triples for each one
for (j in 1:nrow(investigators))
{
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators[j,"invid"]),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "Investigator")
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators[j,"invid"]),
        paste0(prefix.STUDY,"hasInvestigatorID" ),
        paste0(investigators[j,"invid"]), type="string"
   )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators[j,"invid"]),
        paste0(prefix.STUDY,"hasLastName" ),
        paste0(investigators[j,"invnam"]), type="string"
    )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "Investigator_", investigators[j,"invid"]),
        paste0(prefix.RDFS,"label" ),
        paste0("Investigator ", investigators[j,"invid"]), type="string"
    )
}

# Treatment Arms
#TODO : Build this out.