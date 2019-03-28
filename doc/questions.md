
## Purpose

Please ask your questions related to data or ontologies here to get answers from the project. You can simply login to Github and use the "Edit" Button in the top-right action box. Please remove your question when it is answered and you noticed the answer. If a question/answer is relevant to others, the content might go into general documentation.

## Code.ttl - Prefix differences code: vs sdtmterm:

**Question**: I guess we use "code:" as prefix for cutstom code items and "sdtmterm:" for CDISC codelists? Extensible codelists are also maintained under "code:", even though the values might be CDISC Terminology for our pilot? Or should we include all CDISC terms with the "sdtmterm:" prefix instead? How would it look like for having CDISC code + extensions? These extensions are typically company specific.

Example: code:AgeGroup uses the code prefix but only CDISC terminology for the extended codelist.

**Answer**: The "code:" namespace is used in the pilot to designate a "placeholder" for controlled terminology that is maintained by an outside organization, such as CDISC terminology, MedDRA, WHO-Drug, etc. For example, if code:AgeGroup is maintained by CDISC terminology, then in a production environment code:AgeGroup would be replaced by the corresponding resource maintained by CDISC. Similarly code:DrugProduct would be replaced in a production environment by the DrugProduct resource maintained by WHO-Drug or RxNorm, or whichever Drug Product Terminology is chosen for implementation in a production environment. Custom terminology, such as those custom terms defined by the Sponsor, is represented in the ontology using the placeholder "custom:" namespace and is defined at the protocol level (e.g. cdiscpilot01-protocol.ttl) and would be replaced in a production environment by a sponsor designated namespace for custom terminology.

## Code.ttl - update with CDISC Controlled Terminology

**Question**: 1) Would it be ok to include additional CDISC Controlled Terminology using the same strategy as available in code.ttl and update code.ttl accordingly? For example include also other AgeGroup declarations which are available in CDISC controlled terminology? 2) Can we include altLabels where it make sense? "No" / "Yes" has already been included as alternative Labels for the response code.

**Answer**: Yes, please see previous response. It is acceptable, in fact desirable, to replace any code:<term> with the corresponding resource that is maintained by an external terminology management organization. 

## Duration vs. hasValue - Age

**Question**: We use an age duration for the minimum & maximum planned subject age in the protocol and use a number for age in the DM domain. According CDISC the attached codelist for min/max age in TS is duration. Do we go with mixtures or might it be easier to use a hasValue also for the min/max planned subject age and map it to the duration format for download?

```
clinicspilot1:AgeOutcome_74
  rdf:type study:AgeOutcome ;
  skos:prefLabel "74 YEARS" ;
  code:hasUnit time:unitYear ;
  code:hasValue 74 ;
  
code:PlannedSubjectAge_P50Y
  rdf:type code:Age ;
  skos:prefLabel "Planned subject age P50Y" ;
  code:hasValue "P50Y"^^xsd:duration ;
```

**Answer**: Since CDISC SDTM allows two different representation for age: Number+Unit (xsd:integer + unit) and also duration (xsd:duration) we felt it is necessary to support both representations in the ontology, since it is fairly simple to translate from one to the other. Therefore, age = 50 years has two acceptable representations value=50ˆxsd:integer unit=years or the value=P50Yˆˆxsd:duration. It seems resaonble to move towards a single representation in the ontology ( think xsd:duration), which would allow post-processing to display the AGE using multiple formats/languages/etc. 


## Adverse Event Mapping

**Question**:

Thanks Armando, the mapping looks really good. I try to follow up what is defined where. I checked the study.ttl and have some questions. I investigated the "direct links", "indirect links" and "SHACL links" and documented those in https://github.com/phuse-org/CTDasRDF/blob/master/doc/HandsOnUnderstandingAE.md.

Then I checked the mapping of one AE in the cdiscpilot.ttl. I found some questions which I have as overview also here https://github.com/phuse-org/CTDasRDF/blob/master/doc/temp/ae_mapping.xlsx :

I have not found a mapping for the following links in the study.ttl for study:AdverseEvent:
+ study:cancer
+ study:hasCategory
+ study:hasDataCollectionDate
+ study:hasSubcategory

The following definitions appear twice, as SHACL rule and as direct triple. Is this intended? If so is there a rational?
+ study:causality
+ study:severity
+ The "study:hasInterval" is defined on the upper class study:StudyComponent with time:Interval and on "study:AdverseEvent" with "study:AdverseEventInterval". Does the AdverseEventInterval has something special? Should it be a separate thing?

Thanks, Katja

**Answer**: Katja, I am very impressed by your thorough review. You have correctly identified some errors and inconsistencies which need to be addressed, and which I have corrected in the underlying ontology. Thank you! The corrections/changes are as follows:
1. study:cancer is missing the triple:  study:cancer rdfs:domain study:AdverseEvent. I have added it to study.ttl and this establishes the link that you found was missing. 
2. study:hasCategory and study:hasSubcategory: I do not see these variables in the pilot AE domain, therefore, there is no direct link in the ontology between these concepts and Adverse Event. However, I recognize that they might exist in other AE domains for othe studies. Therefore, I have replaced the follwowing triples:
study:hasCategory rdfs:domain study:Activity  and
study:hasSubcategory rdfs:domain study:Activity with the following triples:
study:hasCategory rdfs:domain study:StudyComponent  and
study:hasSubcategory rdfs:domain study:StudyComponent. 
Since study:AdverseEvent is a subclass of Study:Component, I believe the link is now established. 
3. study:hasDataCollectionDate is missing a link to the AdverseEvent class. I have added the following triple, which should solve this problem. 
study:hasDataCollectionDeate rdfs:domain study:studyComponent 

study:Causality and study:Severity  the asserted triples define the rdfs:domain (study:AdverseEvent) and rdfs:range (i.e. controlled terminology) for each predicate; The SHACL constraints add additional constraints on the data (specifically, cardinality constraints) It is desirable to have both, I think. 

Regarding study:AdverseEventInterval, the ontology recognizes that an AdverseEventInterval is a subclass of time:Interval. Other "types" intervals are also defined, such as FixedDoseInterval, Lifespan, StudyInterval, etc. The SHACL constraint retricts the range of study:interval only to AdverseEventInterval when talking about AdverseEvents. We can, and should, add similar constraints to the other intervals, thereby applying the constraint equally among all the types of intervals. We haven't done that (yet) simply because we haven't gotten around to it. 




