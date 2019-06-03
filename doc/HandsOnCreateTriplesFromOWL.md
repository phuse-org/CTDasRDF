# Getting hands on Creating Triples from Ontology

[Go to TOC](TableOfContents.md)

## Revision

Date         | Comment
------------ | ----------------------------
2018-11-23   | Documentation creation (KG)
2018-11-26   | Further Documentation (KG)
2019-01-04   | Updates (KG)
2019-05-09   | Updates (KG)


## Overview

To get start with creating triples using ontology, you might want to perform the following steps:

- Analyze OWL and figure out which object types you need
- Create triples step by step, start with prototyping
- Load more triples and use automation, e.g. use Stardog Mapping Syntax or different programming

In this hands on we use the Trial Summary (TS) as example. The ontology is located mainly in the study.ttl using also other ontology links from the CTDasRDF project.

## Analyze Ontology - concentrate on subset

The more complex an ontology is, the more difficult it is to figure out how the final structure should look like. You can use various ways to browse the ontology provided. In [HandsOnCTDasRDF](https://github.com/phuse-org/CTDasRDF/blob/master/doc/HandsOnCTDasRDF.md) there is a section "Get Hands on Ontologies" where different ways are made available.

You find different HTML files containing visualization in the r/vis/output folder. To look at them you need to download these files, as somehow the display through github does not work. The following visualizations are available:

Name                            |  Description
-----------------------------   | -----------------
study_ttl_vis.html              | Domain-Range connections of the study.ttl
study_ttl_vis_subclass.html     | Class-SubClass connections of the study.ttl
cdiscpilot01_protocol_ttl.html  | Visualization of the protocol triples, so the instances
sdtm_ttl_first300obs.html       | Part of the Tripples for sdtm.ttl ontology
code_tts_first300obs.html       | Part of the Tripples for code.ttl ontology

In the r/vis subfolder you can also find various programs for different visualizations. To get on overview of the related Ontology elements required for the TS mapping, the program r/vis/vis_stardog_dbs.R is used - "create Ontology graph for CTDasRDFOWL (ofInterest_01)".

## Starting small for first experiences

### Setup and start with first instances

Let's concentrate first on a small subset to see how things are working. Checking the Ontology, we currently concentrate only on a few objects:

* study:Study
* skos:prefLabel
* study:narms
* study:hasTitle
* study:Title
* study:longTitle
* study:shortTitle
* study:PrimaryObjective
* study:SecondaryObjective

We are going to start with the "Study" as core element and associate different objects to this. The "Title" object has potentially a longTitle and shortTitle which is a simple string. Then there is the narms (number of arms) as a simple integer assignment and finally we will include a PrimaryObjective and SecondaryObjective.

The Visualization is done through r/vis/vis_stardog_dbs.R in section "create Ontology graph for CTDasRDFOWL (ofInterest_01)".

![Figure: Ontology with parts of interest](./images/hands_on_triples_01.png)

Now we need to create the final objects as triples, so a .ttl file. We might want to check the general format to get a feeling by looking into the data/rdf/cdiscpilot01.ttl file. We want to use prefixes to avoid using the complete links for our triples. So we include these into our file:

```
@prefix cd01p: <https://w3id.org/phuse/cd01p#> .
@prefix cdiscpilot01: <https://w3id.org/phuse/cdiscpilot01#> .
@prefix code: <https://w3id.org/phuse/code#> .
@prefix cts: <https://w3id.org/phuse/cts#> .
@prefix custom: <https://w3id.org/phuse/custom#> .
@prefix mms: <https://w3id.org/phuse/mms#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix sdtmterm: <https://w3id.org/phuse/sdtmterm#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix sp: <http://spinrdf.org/sp#> .
@prefix spin: <http://spinrdf.org/spin#> .
@prefix study: <https://w3id.org/phuse/study#> .
@prefix time: <http://www.w3.org/2006/time#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix prot: <https://w3id.org/phuse/prot#> .
```

Then we need to include the triples. We are going to look first into study:Study. We need to create an instant first. An instant belongs to a namespace, which is the target. As the triples are more related to the protocol instead of the study itself, we store our triples in a separate protocol file cdiscpilot01-prot.ttl, so the namespace will be called prot and have as uri the following which is also used as prefix: "@prefix prot: <https://w3id.org/phuse/prot#>". You can find a final protocol and TS mapping already in the existing file: data/rdf/cdiscpilot01-protocol.ttl file.

To make the study:Study instant unique, we need a unique name, which will be Study_CDISCPILOT01. To make it clear that this instance has as type the "study:Study" object, we define the "rdf:type" for this instance. Furthermore a preferred Label would be nice, so we include this as well.

Then we can look at the connections for our study instance. It links to one base type - integer - with the "narms" and links to multiple other objects. As each object needs unique names / URIs, we include the study id as postfix. In case multiple objects of the same type are expected, we include additionally a number postfix which is true for the objectives. Actually our study contains multiple primary and secondary objectives. We are going to include the additional ones soon.

We create our first instances the following way using the URIs described:

```
prot:Study_CDISCPILOT01
  rdf:type                            study:Study;
  skos:prefLabel                      "Study: CDISCPILOT01"^^xsd:string ;
  study:narms                         "3"^^xsd:int;
  study:hasTitle                      prot:Title_CDISCPILOT01;
  study:hasPrimObjective              prot:PrimaryObjective_CDISCPILOT01_001;
  study:hasSecObjective               prot:SecondaryObjective_CDISCPILOT01_001;
.
```

To visualize, we store the ts_testmap.ttl file including the prefix definitions and first instances, upload these triples into a triple store - e.g. the stardog database - and run the visualization.

### Example - Clear DB, Add instances, Run Visualization

Delete all triples from the CTDasRDFSMS database through the Stardog Web interface. Open your database <http://localhost:5820/CTDasRDFSMS>. Go to ">_Query" and execute the delete all triples command: DELETE{?s ?p ?o} WHERE{?s ?p ?o}.

Load the ts_test001.ttl file into the database through "Data" -> "+Add", choose the corresponding file and click "Upload". You should get a "Success!" message. You can check the success by selecting all triples in the store with the command: SELECT * WHERE {?s  ?p ?o}.

The Visualization is done through r/vis/vis_stardog_dbs.R in section "create content graph for CTDasRDFSMS".

![Figure: Instances](./images/hands_on_triples_02.png)

### Continue with first instances

As a next step we need to define the linked instances further. In our case these are the three for the title, the primary objective and the secondary objective. Out study has just one long Title. Furthermore we should also specify the type of the Title. This we can do with the following triples:

```
prot:Title_CDISCPILOT01
  rdf:type                            study:Title;
  study:longTitle                     "Safety and Efficacy of the Xanomeline Transdermal Therapeutic System (TTS) in Patients with Mild to Moderate Alzheimer’s Disease."^^xsd:string ;
.
```

The objectives do not contain any further connections. They are unique as they are and the content should be included in the preferred label. As we have multiple primary and secondary objectives, we must create for each unique objective a unique instance. We change the definition for our Study_CDISCPILOT01 to include all objectives and furthermore define all single objectives. 


Our final ttl file contains now the following triple definitions additionally to the prefixes:

```
prot:Study_CDISCPILOT01
  rdf:type                            study:Study;
  skos:prefLabel                      "Study: CDISCPILOT01"^^xsd:string ;
  study:narms                         "3"^^xsd:int;
  study:hasTitle                      prot:Title_CDISCPILOT01;
  study:hasPrimObjective              prot:PrimaryObjective_CDISCPILOT01_001;
  study:hasPrimObjective              prot:PrimaryObjective_CDISCPILOT01_002;
  study:hasSecObjective               prot:SecondaryObjective_CDISCPILOT01_001;
  study:hasSecObjective               prot:SecondaryObjective_CDISCPILOT01_002;
  study:hasSecObjective               prot:SecondaryObjective_CDISCPILOT01_003;
  study:hasSecObjective               prot:SecondaryObjective_CDISCPILOT01_004;
.

prot:Title_CDISCPILOT01
  rdf:type                            study:Title;
  study:longTitle                     "Safety and Efficacy of the Xanomeline Transdermal Therapeutic System (TTS) in Patients with Mild to Moderate Alzheimer’s Disease."^^xsd:string ;
.
  
prot:PrimaryObjective_CDISCPILOT01_001
  rdf:type                            study:PrimaryObjective;
  skos:prefLabel										  "To determine if there is a statistically significant relationship between the change in both ADAS-Cog and CIBIC+ scores, and drug dose (0, 50 cm2 [54 mg], and 75 cm2 [81 mg])"^^xsd:string ;
.

prot:PrimaryObjective_CDISCPILOT01_002
  rdf:type                            study:PrimaryObjective;
  skos:prefLabel										  "To document the safety profile of the xanomeline TTS."^^xsd:string ;
.

prot:SecondaryObjective_CDISCPILOT01_001
  rdf:type                            study:SecondaryObjective;
  skos:prefLabel										  "To assess the dose-dependent improvement in behavior. Improved scores on the Revised Neuropsychiatric Inventory (NPI-X) will indicate improvement in these areas."^^xsd:string ;
.

prot:SecondaryObjective_CDISCPILOT01_002
  rdf:type                            study:SecondaryObjective;
  skos:prefLabel										  "To assess the dose-dependent improvements in activities of daily living. Improved scores on the Disability Assessment for Dementia (DAD) will indicate improvement in these areas."^^xsd:string ;
.


prot:SecondaryObjective_CDISCPILOT01_003
  rdf:type                            study:SecondaryObjective;
  skos:prefLabel										  "To assess the dose-dependent improvements in an extended assessment of cognition that integrates attention/concentration tasks. The ADAS-Cog (14) will be used for this assessment."^^xsd:string ;
.


prot:SecondaryObjective_CDISCPILOT01_004
  rdf:type                            study:SecondaryObjective;
  skos:prefLabel										  "To assess the treatment response as a function of Apo E genotype."^^xsd:string ;
.
```

### Visualize first instances

Now we have loaded all information available from the selected ontology parts into our graph database. We can visualize this again through the above described process: delete data, add data, visualize via R. 

The following graphic displays the content (r/vis/vis_stardog_dbs.R - section "create content graph for CTDasRDFSMS"):

![Figure: Instances](./images/hands_on_triples_03.png)

Our current database looks already quite crowded. But typically you would not look into the graphic presentations of a database, but look into specific questions. If you want to see all secondary Objectives in the current database, you can perform the following query:

```
SELECT ?SecondaryObjective
WHERE
  { ?s rdf:type study:SecondaryObjective .
    ?s skos:prefLabel ?SecondaryObjective }
```

And will get the following output:

* To assess the dose-dependent improvement in behavior. Improved scores on the Revised Neuropsychiatric Inventory (NPI-X) will indicate improvement in these areas.
* To assess the dose-dependent improvements in activities of daily living. Improved scores on the Disability Assessment for Dementia (DAD) will indicate improvement in these areas.
* To assess the dose-dependent improvements in an extended assessment of cognition that integrates attention/concentration tasks. The ADAS-Cog (14) will be used for this assessment.
* To assess the treatment response as a function of Apo E genotype.

## More TS mapping

### Get related ontology elements out of domain-range connections

To continue with the TS mapping from the pilot study we check which ontology elements we need to fill. Quite a lot of the content can simply be mapped when looking into the domain-range connections of the ontology. 

The Visualization is done through r/vis/vis_stardog_dbs.R in section "create Ontology graph for CTDasRDFOWL (ofInterest_02)".

![Figure: Ontology for simple mappings](./images/hands_on_triples_04.png)

So we are able to map more than half of all observations from Trial Summary after this step in our domain and are missing just a few observations. But where should the other observations be mapped to? Some might be missing as the ontology is under development, but some are already available, but can only be mapped when considering the sub-class connections.

### Connecting sub-class hierarchies

As the next step we might want to look into the Data Cutoff example. 

TSPARMCD     |   TSPARM 
------------ | ----------------------------
DCUTDESC     | Data Cutoff Description
DCUTDTC      | Data Cutoff Date

Where might this mapping go? When we look into the ontology, for example with Protege, we find a class called "study:DateCutoff". Checking the sub-class hierarchy, we figure out that this is a sub-class of "study:AdministrativeActivity", which is a sub-class of "study:StudyActivity" which is a sub-class of "study:Activity".

![Figure: Sub-Class hierarchy for DateCutoff](./images/hands_on_triples_05.png)

According the class hierarchy, the sub-classes have the same attributes like the "parents" and might have further connections. The "study:Activity" class has already the required attributes we find in our TS domain which is study:activityDescription and study:hasDate. Furthermore we see the link from "study:Study" to "study:StudyActivity".


![Figure: Attributes for class study:Activity](./images/hands_on_triples_06.png)

So now we merge all required attributes and sub-class values together to be able to map the two Cutoff values to our graph.

![Figure: Attributes for class study:Activity](./images/hands_on_triples_07.png)

### Mapping CDISC codes - NoYesResponse

The examples so far showed how a text or a number is instanciated. Let us also have a look how controlled terminology is mapped. Controlled terminology items are available in the code.ttl triples. We might start with the simple No-Yes-Response. The "study:adaptiveDesign" predicate has as connection the "code:NoYesResponse". According CDISC, three possible values are available: N, Y and NA. So there are three different instances available. In the code.ttl you can find three corresponding instnaces named sdtmterm:NoYesResponse_N, sdtmterm:NoYesResponse_Y and sdtmterm:NoYesResponse_NA. CDISC definitions as well as the nciCode and even alternative labels are attached to these items, additional information is coming out of the box (if existing).

As these items are already available in an ontology, we simply can connect our study instance with the corresponding answer as triple:

```
prot:Study_CDISCPILOT01   study:adaptiveDesign  sdtmterm:NoYesResponse_N;
```

This simple step we can do for all NoYesResponse variables. If you are using automatic processes, you should consider that data is quite often not clean. So there might be values like "No", "Yes" or similar in the values. Make sure to perform a data cleaning to be able to map to the correct instances.

Our study:Study definition including the NoYesResponse variables is now looking like this:

```
prot:Study_CDISCPILOT01
  rdf:type                            study:Study;
  skos:prefLabel                      "Study: CDISCPILOT01"^^xsd:string ;
  study:narms                         "3"^^xsd:int;
  study:adaptiveDesign                sdtmterm:NoYesResponse_N ;
  study:hasTitle                      prot:Title_CDISCPILOT01;
  study:hasPrimObjective              prot:PrimaryObjective_CDISCPILOT01_001;
  study:hasPrimObjective              prot:PrimaryObjective_CDISCPILOT01_002;
  study:hasSecObjective               prot:SecondaryObjective_CDISCPILOT01_001;
  study:hasSecObjective               prot:SecondaryObjective_CDISCPILOT01_002;
  study:hasSecObjective               prot:SecondaryObjective_CDISCPILOT01_003;
  study:hasSecObjective               prot:SecondaryObjective_CDISCPILOT01_004;
  study:adaptiveDesign                sdtmterm:NoYesResponse_N ;
  study:isAddOnStudy                  sdtmterm:NoYesResponse_N ;
  study:randomizedTrial               sdtmterm:NoYesResponse_Y ;
.

```


## Design Decisions

### Populations

When looking also into sub-class connections of the model, there are two different types of populations available, the StudyPopulation and the EnrolledPopulation. These have different meanings and content and are for this two different items. So properties only belong to the StudyPopulation as the complete population and others are available for the EnrolledPopulation.

![Figure: Ontology details for Population](./images/hands_on_triples_08_a.png)

The final mapping considers two populations with different attributes. So we create our study with two populations:

```
prot:Study_CDISCPILOT01
   study:hasPopulation prot:EnrolledPopulation_CDISCPILOT01;
   study:hasPopulation prot:StudyPopulation_CDISCPILOT01;
.
```

And then create the corresponding attributes for the populations:

```
cd01p:EnrolledPopulation_CDISCPILOT01
  rdf:type study:EnrolledPopulation ;
  skos:prefLabel "Enrolled population CDISCPILOT01" ;
  study:actualPopulationSize 254 ;
  study:plannedPopulationSize 300 ;
.

cd01p:StudyPopulation_CDISCPILOT01
  rdf:type study:StudyPopulation ;
  skos:prefLabel "Study population CDISCPILOT01" ;
  study:ageGroup code:AgeGroup_ADULT ;
  study:ageGroup code:AgeGroup_ELDERLY ;
  study:maxSubjectAge <https://w3id.org/phuse/code#PlannedSubjectAge_NULL.PINF> ;
  study:minSubjectAge code:PlannedSubjectAge_P50Y ;
  study:sexGroup sdtmterm:SexGroup_BOTH ;
.
```

![Figure: Using two different populations](./images/hands_on_triples_08.png)


