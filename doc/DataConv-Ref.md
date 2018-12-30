
Data Conversion
===============
TO BE MERGED WITH OTHER CONTENT

This page describes the methods used to convert XPT files to the graph. These activities occur in parallel
with ontology development, which also creates instance data. Instance data from the SMS conversion (described on this page)
is compared with instance data created during ontology development. 

Information here is incomplete and may move to other pages. [2018-12-21]


Background
----------

The source data XPT files are converted to .CSV format using R. The conversion process massages the data into the form required for Stardog Mapping Syntax (SMS) to map the instance data to the graph.. 

SMS can be converted back to R2RML, the open source W3C standard.


R Scripts
=========

To be added: A description of the various R scripts used for processing and visualizing the data.

Data Preparation
----------------

-   **DM\_imputeCSV.R**
-   Converts the source DM.XPT to CSV and imputes values needed to test the model. Example: Setting the death flag and date for Subject 1. Based on the original DM\_impute.R.

Validation
----------

-   **CompTriples-Shiny.R**
    -   R Shiny App to facilitate comparison of the .TTL file created by the SMS process with the ontology instance data created by AO using TopBraid.

Visualization
-------------

-   **Person-MultLevel-VisNetwork-ForceNetwork.R**
    -   Triples attached to Person\_1 in cdiscpilot01.TTL as a force network graph using visNetwork. Functionality includes: selection by node or group, node selection by mouse click, mouseover of relations. NOTE: OUTDATED: Must be updated to use new IRI specifications based on hashes.

Coding Conventions
==================

Variable naming
---------------

-   CamelCase for classes
-   CamelCase\_(n) for instances of classes.

Data Types
----------

### Dates and Date Processing

NOTE: This section will be updated after implications of SMS conversion process become apparent.

Date values are evaluated during the conversion to RDF.

-   Date values (as represented in fields like rfstdtc, rfendtc, rfxendtc, etc.) with complete and valid year, month, and data values are typed as xsd:date.
-   Incomplete date values or values that have incomplete dateTime values (missing seconds, for example) are typed as xsd:string, since xsd:dateTime would be semantically incorrect. See discussion at: <http://stackoverflow.com/questions/25165456/is-this-a-valid-xsddatetime-if-so-why> At a later time, incomplete date values may be coded to their corresponding components (year,day,hour..) using the TIME ontology (not currently implemented).

Dates are assigned a URI by first combining all dates (during dev, only a subset!) from the domains being processed (DM, SUPPDM, VS, EX) into a single column, sorting by date, then assigning a number. This is accomplished in the function createDateDict() within createFrag\_F.R. It is called from buildRDF-Driver.R after the domains have been imported from the XPT. To add new domains and date columns you must edit createDateDict().

After the list of all dates and their URIs is created, the date URI's must be merged back into the individual domains. This is accomplished using addDateFrag(), called from <domain>\_Frag.R , one call for each date column. TODO: Make the assignments back to the respective domains within createDateDic(), removing the need to call addDateFrag.

Data Modeling Decisions
=======================

Introduction
------------

The traditional SDTM data model is limited by its row x column structure and modeling decisions that can be solved by the RDF ontologies and a multi-dimensional data structure. This section of the project wiki documents the details of the RDF data model and the issues in SDTM that are resolved using Linked Data approaches. Expect this page to change as the model evolves during the project.

"SDTM model" refers to the various approved SDTM versions published by CDISC and "RDF Model" refers to the model under development as part of this project.

Treatment Arms
--------------

SDTM allows "fake" arms, like SCRNFL (screen failure) and NOT TREATED, for valid values for Arm and ArmCD. In the RDF model we treat them as real Arms so we can do the roundtripping back out to SDTM from RDF, but we exclude them from participating as values of Outcomes for "Randomization Activity", since no one is randomized to a screen failure or Not Treated arm.

Observations
------------

SDTM recognizes three types of Observations:

1.  Findings
2.  Interventions
3.  Events

### Findings and Interventions

In stark contrast to the SDTM Model, the RDF Model defines Findings as a type of Intervention, thus providing a single standard approach to document the process that leads to either a Finding or a therapeutic Intervention. For example, some procedures like cardiac catheterization involve both concepts: a) Finding: determines there is a blocked artery b) (therapuetic) Intervention: inserts a stent to keep artery open

All Findings are Interventions in the sense that "someone has to do something" (that one wouldn't ordinarily do in the course of the subject's daily routine, i.e. to intervene) to make and record the Finding. This is true for simple measures like temperature through to more complex tests like a biopsy. It is often important to document the more complex procedures. For example, to record collection of a biospecimen collection and its processing, and/or the use of a medical device.

### Events

The RDF model defines certain Events like Adverse Events not as Observations, but as Medical Conditions that are identified as an AsessmentOutcome. The SDTM model does not capture the Assessment information that led to the Outcome. In SDTM, assessment information is usually either 1) lumped together with observation data, 2) saved in SUPPQUAL, or 3) relegated to custom domains. The RDF model fixes this modeling problem **\[TODO: ADD PRECISELY HOW\]** while making it challenging to recreate SDTM datasets that perpetuate the modeling error. Automation across submissions may also prove difficult. **\[TODO: ADD MORE HERE ABOUT THE AUTOMATION ISSUE\]**

### Activities \[2017-11-02\]

Measurement activites like Blood Pressure, Pulse, etc. are considered subActivities of a visit, that occur during a visit. BP, Pulse are a subClass of Visit Activity, as shown in the hierarchy:

Activity --&gt; Study Activity -- Visit Activity

The predicate study:subActivity makes this link.

### VS : Body Position, Start Rules, Test sequence \[updated 2017-11-02\]

Each subject has two AssumeBodyPosition activities, 1 lying and 1 standing

Sequence:

1.  After lying 5 minutes: SBP1, DBP1, Pulse1
2.  Stand. After standing 1 min: SBP2, DBP2, Pulse2
3.  Still standing: after 3 min: SBP3, DBP3, Pulse3

Both standing activities are associated with the same standing "event" : AssumeBodyPositionStanding\_(n). The person stands (assumes standing position), then the two start rules come into play: StartRuleStanding1\_(n) (1 minute stand rule), followed later by StartRuleStanding3\_(n) (3 minute standing rule).

This sequence is not explicit in the SDTM data. For data conversion purposes, it is derived by a combination of the USUBJID, VISIT, and VSPTNUM fields during triple creation.

Start Rules indicate the pre-requisite activities. The measurements conducted in the standing position are preceded by lying down, then the subject stands for 1 min and measurements are conducted. Then the 3min measurements are conducted. This means that the **AssumeBodyPositionStanding\_1** triples have a prequisite **StartRuleLying5\_1** , as illustrated in the following set of triples:



### Miscellaneous

SDTM variables --CAT and --SCAT have no consistent meaning across submissions and so cannot be modeled consistently in the RDF ontology. This is also true for the entire RELREC domain which relates records with each other **\[TODO:ADD MORE DETAIL ON CURRENT USE\]**. In the semantically consistent the RDF model the concept of a record disappears where concepts and data values are related by design.
