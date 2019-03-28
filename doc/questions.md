
## Purpose

Please ask your questions related to data or ontologies here to get answers from the project. You can simply login to Github and use the "Edit" Button in the top-right action box. Please remove your question when it is answered and you noticed the answer. If a question/answer is relevant to others, the content might go into general documentation.

## Code.ttl - Prefix differences code: vs sdtmterm:

**Question**: I guess we use "code:" as prefix for cutstom code items and "sdtmterm:" for CDISC codelists? Extensible codelists are also maintained under "code:", even though the values might be CDISC Terminology for our pilot? Or should we include all CDISC terms with the "sdtmterm:" prefix instead? How would it look like for having CDISC code + extensions? These extensions are typically company specific.

Example: code:AgeGroup uses the code prefix but only CDISC terminology for the extended codelist.

**Answer**:

## Code.ttl - update with CDISC Controlled Terminology

**Question**: 1) Would it be ok to include additional CDISC Controlled Terminology using the same strategy as available in code.ttl and update code.ttl accordingly? For example include also other AgeGroup declarations which are available in CDISC controlled terminology? 2) Can we include altLabels where it make sense? "No" / "Yes" has already been included as alternative Labels for the response code.

**Answer**:

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

**Answer**:


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

**Answer**:
