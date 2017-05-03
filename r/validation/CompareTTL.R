###############################################################################
# FILE : CompareTTL.R
# DESCR: Compare TTL files created with R vs those from AO
# SRC  : 
# KEYS : 
# NOTES: 
#        
# INPUT: 
#      : 
# OUT  : 
# REQ  : 
# TODO : 
###############################################################################
require(rrdf)
# library(plyr)  # for rename . ply must load prior to dplyr!
require(dplyr) # for compare of dataframes using anti_join


# For use with local TTL file:
setwd("C:/_gitHub/SDTMasRDF")

TWSource = load.rdf("data/rdf/cdiscpilot01.TTL", format="N3")

# AOSource = load.rdf("data/rdf/AO-2017-01-27/cdiscpilot01local.TTL", format="N3")
AOSource = load.rdf("data/rdf/cdiscpilot01local.TTL", format="N3")

###############################################################################
#--checkPers()
#  All triples directly attached to Person_<n> , with no path traversal

checkPerson <- function(){

query = 'PREFIX cdiscpilot01: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/cdiscpilot01#>
PREFIX custom: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/custom#>
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX study:  <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/study#>

SELECT ?s ?p ?o
WHERE { cdiscpilot01:Person_1 ?p ?o . 
  BIND("cdiscpilot01:Person_1" as ?s)
}'
TWTriples = as.data.frame(sparql.rdf(TWSource, query))


AOTriples = as.data.frame(sparql.rdf(AOSource, query))


inTWNotAO<-anti_join(TWTriples, AOTriples)
inAONotTW<-anti_join(AOTriples, TWTriples)

# In the TW TTL file but not in the AO file                 
inTWNotAO
# In the AO TTL file but not in the TO file
# Clean up the artifacts from TopBraid
inAONotTW <- inAONotTW[!is.na(inAONotTW$o), ]
inAONotTW <- inAONotTW[!(inAONotTW$o==""), ]  # The values are actually "", not NA. 
inAONotTW

}
checkPerson()


###############################################################################
#--checkPredicate()
#  Check select predicates attached to person_1 and the direct p,o attached to 
#      them

checkPredicate <- function(predicate){
    #-----------------------------------------------------------------
    #-- cdiscpilot01:Person_1 study:hasAgeMeasurement 
    query = paste(' 
        PREFIX cdiscpilot01: <http://example.org/cdiscpilot01#>
        PREFIX custom: <http://example.org/custom#>
        PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
        PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> 
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        PREFIX study:  <http://example.org/study#>
        PREFIX time: <http://www.w3.org/2006/time#>
        SELECT *
        FROM <http://localhost:8890/CDISCPILOT01>
        WHERE{
        cdiscpilot01:Person_1 ', 
        predicate,
        ' ?s .
        ?s ?p ?o
        }
        ',
        "\n"
    )
    
    TWTriples = as.data.frame(sparql.rdf(TWSource, query))
    AOTriples = as.data.frame(sparql.rdf(AOSource, query))
    
    inTWNotAO<-anti_join(TWTriples, AOTriples)
    inAONotTW<-anti_join(AOTriples, TWTriples)
    inAONotTW<-inAONotTW[!(inAONotTW$o==""),]  # remove cases where O is missing (atrifact from TopBraid)
    # In the TW TTL file but not in the AO file                 
    inTWNotAO
    # In the AO TTL file but not in the TO file
    inAONotTW
}

# checkPredicate("study:hasAgeMeasurement")
# checkPredicate("study:hasBirthdate")   
# checkPredicate("study:hasDeathdate")   
# checkPredicate("study:participatesIn") # OMIT : VS Domain not yet implemented 
# checkPredicate("time:hasBeginning")    
# checkPredicate("time:hasEnd")          
# checkPredicate("study:hasSite")      # Fixed prefix. Test again

# NEW:
# Following are from custom.ttl from AO
# checkPredicate("study:allocatedToArm")   # ERROR WHEN RUN. WRONG NAME 
# checkPredicate("study:treatedAccordingToArm")          # ERROR WHEN RUN. WRONG NAME         

# These predicates are coded values that can not be tested in this way:
# study:hasEthnicity, study:hasRace, study:hasSex 


# checkPredicate("study:")          



###############################################################################
#--checkSubject()
#   Check the p,o directly attached a subject. No graph traversal

checkSubject <- function(subject){

    query = paste(' 
                  PREFIX cdiscpilot01: <http://example.org/cdiscpilot01#>
                  PREFIX custom: <http://example.org/custom#>
                  PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
                  PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> 
                  PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
                  PREFIX study:  <http://example.org/study#>
                  PREFIX time: <http://www.w3.org/2006/time#>
                  SELECT *
                  FROM <http://localhost:8890/CDISCPILOT01>
                  WHERE{', 
                  subject,
                  ' ?p ?o.
                  }
                  ',
                  "\n"
    )
    
    TWTriples = as.data.frame(sparql.rdf(TWSource, query))
    AOTriples = as.data.frame(sparql.rdf(AOSource, query))
    
    inTWNotAO<-anti_join(TWTriples, AOTriples)
    inAONotTW<-anti_join(AOTriples, TWTriples)
    inAONotTW<-inAONotTW[!(inAONotTW$o==""),]  # remove cases where O is missing (atrifact from TopBraid)
    # In the TW TTL file but not in the AO file                 
    inTWNotAO
    # In the AO TTL file but not in the TO file
    inAONotTW
}
# checkSubject("cdiscpilot01:P1_DBP_1")

# checkSubject("cdiscpilot01:AgeMeasurement_1")
# checkSubject("cdiscpilot01:Age_1")
# checkSubject("study:DemogDataCollectionDate") # ERROR: AO has Actual...
# checkSubject("cdiscpilot01:InformedConsentOutcome_1")
# checkSubject("cdiscpilot01:InformedConsentBegin_1")
# checkSubject("cdiscpilot01:DM_CDISCPILOT01")  # NOT PRESENT IN TW file
# checkSubject("cdiscpilot01:Deathdate_1")
# checkSubject("cdiscpilot01:InformedConsent_1")
# checkSubject("cdiscpilot01:Investigator_123")
# checkSubject("cdiscpilot01:RandomizationOutcome_1")
# checkSubject("cdiscpilot01:Randomization_1")
# checkSubject("cdiscpilot01:ReferenceEndDate_1")
# checkSubject("cdiscpilot01:ReferenceStartDate_1")
# checkSubject("cdiscpilot01:StudyParticipationEnd_1")
# checkSubject("cdiscpilot01:site_701")
# checkSubject("cdiscpilot01:study-CDISCPILOT01")


getClasses <- function(subject){

    query = paste(' 
prefix arg: <http://spinrdf.org/arg#> .                                               
prefix code: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/code#> .    
prefix custom: <https://github.com/phuse-org/SDTMasRDF/blob/master/data/rdf/custom#> .
prefix owl: <http://www.w3.org/2002/07/owl#> .                                        
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .                           
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .                                
prefix skos: <http://www.w3.org/2004/02/skos/core#> .                                 
prefix sp: <http://spinrdf.org/sp#> .                                                 
prefix spin: <http://spinrdf.org/spin#> .                                             
prefix spl: <http://spinrdf.org/spl#> .                                               
prefix xsd: <http://www.w3.org/2001/XMLSchema#> .                                     

SELECT *
FROM <http://localhost:8890/CDISCPILOT01>
WHERE{?class rdfs:subClassOf ?subclass 
                  }
                  ',
                  "\n"
    )
    
    TWTriples = as.data.frame(sparql.rdf(TWSource, query))
    AOTriples = as.data.frame(sparql.rdf(AOSource, query))
    
    inTWNotAO<-anti_join(TWTriples, AOTriples)
    inAONotTW<-anti_join(AOTriples, TWTriples)
    inAONotTW<-inAONotTW[!(inAONotTW$o==""),]  # remove cases where O is missing (atrifact from TopBraid)
    # In the TW TTL file but not in the AO file                 
    inTWNotAO
    # In the AO TTL file but not in the TO file
    inAONotTW
}


