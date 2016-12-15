###############################################################################
# Name : codeLists.R
# AUTH : Tim W. 
# DESCR: Build code lists based on values in the data. 
#        These differ from codelists in an RDF Datacube and as such lack 
#            the complexities of conceptScheme, Concept, etc. 
# NOTES: Under development using Investigator as first attempt.
#        WILL REPLACE codeListsCSV.R
# IN   : masterData dataframe
# OUT  : 
# REQ  : Called from buildRDF-Driver.R
# TODO :  ERROR: Creating the RDFS label 3x. WHY?
#
###############################################################################

# Using: 
#  		masterData$invnam <- 'Jones'
#  		masterData$invid  <- '123'
# Build this:
#			cdiscpilot01:Investigator_123               TODO: NOT YET CODED! NEW SUB NEEDED in R SCRIPT
#			  rdf:type study:Investigator ;
#			  study:hasInvestigatorID "123"^^xsd:string ;
#			  study:hasLastName "JONES"^^xsd:string ;
#			  rdfs:label "Investigator 123"^^xsd:string ;


# Investigator List
# Get unique investigator ID info from masterData
investigators <- masterData[,c("invnam", "invid")]
# remove duplicates
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