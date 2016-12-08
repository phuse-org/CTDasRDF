###############################################################################
# Name : codeListsCSV.R
# AUTH : Tim W. 
# DESCR: Build code lists based on specications in the CSV codelist file 
#      : Builds the Class, ConceptScheme and codes required for standard RDF 
#            codelists.
# NOTES: The function receives the name of the codelist to be built. Corresponds
#            to the "name" column in the CSV. 
#        Separate calls are made for each codelist to be created. 
# IN   : data/codelist.csv 
# OUT  : See buildRDF-Driver.R 
# REQ  : 
# TODO : Codelists are under development and likely incomplete. 
#        Codelists like Country could be built from other existing sources? 
#        Country:  build based on the values present in the data, and/or ref. 
#            to an existing graph of all ISO country names?
#        ARM/ARMCD codelists should later include description of the ARMs. 
#        LATER: instead of one call per codelist, process the entire spreadsheet
#               row by row and build all listed?
#
###############################################################################

#------------------------------------------------------------------------------
# buildCodelist()
# Build the Class and Concept Scheme for a code list
#    conceptName
#    codesDF - codes dataframe with cols: codesLabel, codesDscr 
# Spaces must be removed from the codes in order to properly form the SUBJECT
#     URI of the coded value in the TTL file. See use of gsub in codes <-
#     gsub(" ", "", ...
#------------------------------------------------------------------------------
buildCodelist <- function(conceptName){
    conceptName <- tolower(conceptName)       # Lowercase for Concept Defn
    capConceptName <- capitalize(conceptName) # capitalized for Class name
    uConceptName  <- toupper(conceptName)     # Uppperase for class Code (VALUE)
    
    # The subset of the codes for this call only
    codesSel<-codelist[codelist$name ==conceptName,]

    #------------- CLASS------------------------------------------------------- 
    add.triple(store,
        paste0(prefix.CODE, capConceptName),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.OWL, "Class")
    )
    add.triple(store,
        paste0(prefix.CODE, capConceptName),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.RDFS, "Class")
    )
    add.data.triple(store,
        paste0(prefix.CODE, capConceptName),
        paste0(prefix.RDFS,"label"),
        paste0("Class for code list: ", conceptName),
        lang="en"
    )
    add.data.triple(store,
        paste0(prefix.CODE, capConceptName),
        paste0(prefix.RDFS,"comment"),
        paste0("Specifies the ", conceptName, " for each observation"),
        lang="en"
    )
    add.triple(store,
        paste0(prefix.CODE, capConceptName),
        paste0(prefix.RDFS, "subClassOf"),
        paste0(prefix.SKOS, "Concept")
    )
    # Cross reference between the Class (capConceptName) and the codelist (conceptName)
    add.triple(store,
        paste0(prefix.CODE, capConceptName),
        paste0(prefix.RDFS, "seeAlso"),
        paste0(prefix.CODE, conceptName)
    )
    #------------- CONCEPT SCHEME ---------------------------------------------
    add.triple(store,
        paste0(prefix.CODE,conceptName),
        paste0(prefix.RDF,"type" ),
        paste0(prefix.SKOS, "ConceptScheme")
    )
    add.data.triple(store,
        paste0(prefix.CODE,conceptName),
        paste0(prefix.RDFS,"label"),
        paste0("Codelist scheme: ", conceptName),
        lang="en"
    )
    # skos:notation is uppercase by convention. Eg: CL_SEX, CL_RACE
    add.data.triple(store,
                paste0(prefix.CODE,conceptName),
                paste0(prefix.SKOS,"notation"),
                paste0("CL_",toupper(conceptName))
    )
    add.data.triple(store,
        paste0(prefix.CODE,conceptName),
        paste0(prefix.SKOS,"note"),
        paste0("Specifies the ", conceptName, " for each observation or group of obs."),
        lang="en"
    )
    add.data.triple(store,
                paste0(prefix.CODE,conceptName),
                paste0(prefix.SKOS,"prefLabel"),
                paste0("Codelist scheme: ", conceptName),
                lang="en"
    )

    #--------- hasTopConcept ---------
    # List each unique code. Eg: SEX-F, SEX-M, etc. for each possible value 
    #     represented in the codelist.
    # iterate over the codes subset. Previously was codesDF
    # NOTE: Add a LITERAL (type=en, type=string, etc. use add.data.triple
    #       Add a URI:  used add.triple
    for (i in 1:nrow(codesSel)){
            add.triple(store,
                paste0(prefix.CODE,conceptName),
                paste0(prefix.SKOS, "hasTopConcept"),
                paste0(prefix.CODE, conceptName,"-",gsub(" ", "",codesSel[i,"code"])))
    }
    # CONVERSION NOTE:  codesDF becomes codesSel
    #------------- CODES ------------------------------------------------------
    for (i in 1:nrow(codesSel)) {
        add.triple(store,
            paste0(prefix.CODE,conceptName,"-",toupper(codesSel[i,"code"])),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.SKOS, "Concept"))
        add.triple(store,
            paste0(prefix.CODE,conceptName,"-",toupper(codesSel[i,"code"])),
            paste0(prefix.RDF,"type" ),
            paste0(prefix.CODE, capConceptName))
        add.triple(store,
            paste0(prefix.CODE,conceptName,"-",toupper(codesSel[i,"code"])),
            paste0(prefix.SKOS,"topConceptOf"),
            paste0(prefix.CODE, conceptName))
        add.triple(store,
            paste0(prefix.CODE,conceptName,"-",toupper(codesSel[i,"code"])),
            paste0(prefix.SKOS,"inScheme"),
            paste0(prefix.CODE, conceptName))
        # Build the additiaion triples using the predicate,object columns from the source CSV
        if(codesSel[i,"type"]=="en"){
            add.data.triple(store,
                paste0(prefix.CODE,conceptName,"-",toupper(codesSel[i,"code"])),
                paste0(codesSel[i, "predicate"]),
                paste0(codesSel[i, "object"]), lang="en")
        }
        else if(codesSel[i,"type"]=="uri"){
            add.triple(store,
                paste0(prefix.CODE,conceptName,"-",toupper(codesSel[i,"code"])),
                paste0(codesSel[i, "predicate"]),
                paste0(codesSel[i, "object"]))
        }
        else{
            add.data.triple(store,
                paste0(prefix.CODE,conceptName,"-",toupper(codesSel[i,"code"])),
                paste0(codesSel[i, "predicate"]),
                paste0(codesSel[i, "object"]))
        }
    }  # END BUIDLING TRIPLES
}

#------------------------------------------------------------------------------
# Build the individual Codelists
#   No spaces in code names for proper URI formation
# buildCodelist(arg1)
#       arg 1 is the name of the concept Scheme, corresponds to "name" in the 
#       source CSV
#  codes:  no spaces or special characters like + , /, <, >, &,  etc.
#------------------------------------------------------------------------------
codelist <- as.data.frame( read.csv(sourceCodelist,
    header=T,
    sep=',' ,
    strip.white=TRUE))

    #DEBUG:  Keep only the sex codelist for development purposes
    #codelist<-codelist[codelist$name =="sex",]
codelist$codes <- toupper(codelist$name)
codelist$codesLabel <- codelist$name

# One call for each codelist to be built. Later: loop through and build all in 
#     listed in the CSV?  
buildCodelist("arm")
buildCodelist("country")
buildCodelist("sdtmdomain")
buildCodelist("sex")
buildCodelist("site")
buildCodelist("study")
buildCodelist("unit")