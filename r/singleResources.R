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



# Sites
# Get unique investigator ID 
sites <- masterData[,c("siteid", "invid", "countryCode" )]
# Remove duplicates
sites <- sites[!duplicated(sites),]

# Loop through the unique investigators, building the triples for each one
for (s in 1:nrow(sites))
{
    #TODO: Site definition must be moved to singleResource.R !
    #>>
    add.triple(store,
               paste0(prefix.CDISCPILOT01, "site-",sites[s,"siteid"]),
               paste0(prefix.RDF,"type" ),
               paste0(prefix.STUDY,"Site" )
    )
    #TODO Change this to the coded value of Country based on the data, as per links
    #     to Sex codelist, etc.
    # exact coding may have to change based on the values in the graph:
    #   /3166/#840 from AO to become 3166#840 or different value
    add.triple(store,
               paste0(prefix.CDISCPILOT01, "site-",sites[s,"siteid"]),
               paste0(prefix.STUDY,"hasCountry" ),
               paste0(prefix.COUNTRY,sites[s,"countryCode"] )
    )
    add.triple(store,
               paste0(prefix.CDISCPILOT01, "site-", sites[s,"siteid"]),
               paste0(prefix.STUDY,"hasInvestigator" ),
               paste0(prefix.CDISCPILOT01,"Investigator_", sites[s,"invid"])
    )
    add.data.triple(store,
                    paste0(prefix.CDISCPILOT01, "site-",sites[s,"siteid"]),
                    paste0(prefix.STUDY,"hasSiteID" ),
                    paste0(sites[s,"siteid"]), type="string" 
    )
    add.data.triple(store,
                    paste0(prefix.CDISCPILOT01, "site-",sites[s,"siteid"]),
                    paste0(prefix.RDFS,"label" ),
                    paste0("site-",sites[s,"siteid"]), type="string" 
    )
}    

# Treatment Arms
#TODO : Build this out.
#cdiscpilot01:arm-PLACEBO  ()
#  rdf:type study:Arm ; ()
#  study:hasArmCode <http://example.org/custom#armcd-PBO> ; ()
#  rdfs:label "Placebo"^^xsd:string ; ()
# Get unique arm values 
# ASSUMPTION: Source data has same values: arm/actarm and armcd/actarmcd.
#     TODO: improve code by combining both to use any values that may differ 
#            between the two
arms <- masterData[,c("arm", "armcd")]
# Remove duplicates
arms <- arms[!duplicated(arms),]
arms$armUC   <- toupper(gsub(" ", "", arms$arm))
arms$armcdUC <- toupper(gsub(" ", "", arms$armcd))
for (a in 1:nrow(arms))
{
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "arm-", arms[a,"armUC"]),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.STUDY, "Arm")
    )
    add.triple(store,
        paste0(prefix.CDISCPILOT01, "arm-", arms[a,"armUC"]),
        paste0(prefix.STUDY,"hasArmCode" ),
        paste0(prefix.CODECUSTOM, "armcd-", arms[a,"armcdUC"])
   )
    add.data.triple(store,
        paste0(prefix.CDISCPILOT01, "arm-", arms[a,"armUC"]),
        paste0(prefix.RDFS,"label" ),
        paste0(arms[a,"arm"]), type="string"
    )
}