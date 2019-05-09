# Extensions for Ontology

## Trial Summary - DESIGN parameter (Trial Design)




study.ttl:

study:interventionModel
  rdf:type owl:ObjectProperty ;
  rdfs:domain study:Study ;
  rdfs:range code:InterventionModel ;
  skos:prefLabel "intervention model" ;
.


code.tts:

code:InterventionModel
  rdf:type owl:Class ;
  rdfs:subClassOf code:DefinedConcept ;
  rdfs:subClassOf [
      rdf:type owl:Restriction ;
      owl:hasValue code:CodeSystem_CDISCTerminology ;
      owl:onProperty code:hasCodeSystem ;
    ] ;
  skos:prefLabel "Intervention model" ;
.

sdtmterm:InterventionModel_CROSS-OVER
  rdf:type code:InterventionModel ;
  rdf:type mms:PermissibleValue ;
  skos:prefLabel "CROSS-OVER" ;
  code:hasCode "C82637" ;
  schema:cdiscDefinition "Participants receive one of two or more alternative intervention(s) during the initial epoch of the study and receive other intervention(s) during the subsequent epoch(s) of the study." ;
  schema:cdiscSubmissionValue "CROSS-OVER" ;
  schema:nciCode "C82637" ;
  schema:nciPreferredTerm "Crossover Study" ;
  mms:inValueDomain sdtmterm:C99076 ;
.

...