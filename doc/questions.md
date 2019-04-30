
## Purpose

Please ask your questions related to data or ontologies here to get answers from the project. You can simply login to Github and use the "Edit" Button in the top-right action box. Please remove your question when it is answered and you noticed the answer. If a question/answer is relevant to others, the content might go into general documentation.

## AdverseEvent study:hasSubcategory

### Question: update study:hasSubcategory
Hi Armando,

can you please check study:hasSubcategory? According the current study.ttl it is still connected to study:StudyActivity and not study:StudyComponent as mentioned in your answer below:

> study:hasCategory and study:hasSubcategory: I do not see these variables in the pilot AE domain, therefore, there is no direct link in the ontology between these concepts and Adverse Event. However, I recognize that they might exist in other AE domains for othe studies. Therefore, I have replaced the follwowing triples: study:hasCategory rdfs:domain study:Activity and study:hasSubcategory rdfs:domain study:Activity with the following triples: study:hasCategory rdfs:domain study:StudyComponent and study:hasSubcategory rdfs:domain study:StudyComponent. Since study:AdverseEvent is a subclass of Study:Component, I believe the link is now established.

I see triples in the cdiscpilot01.ttl using the category and subcategory:

```
cdiscpilot01:AE3_Diarrhoea	study:hasSubcategory	SCAT1
```


## SPIN Rules - Get Data Tabular

### Question: How to query a SPIN rule?

SPIN rules, like the one for the MedDRA extract are modeled. How can this spin rule query be executed to receive the content? Same we have for domain load, don't we?
