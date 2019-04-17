
## Purpose

Please ask your questions related to data or ontologies here to get answers from the project. You can simply login to Github and use the "Edit" Button in the top-right action box. Please remove your question when it is answered and you noticed the answer. If a question/answer is relevant to others, the content might go into general documentation.

# Temporary Keep for tracking

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




