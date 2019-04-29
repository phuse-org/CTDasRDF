# Data Mapping and Conversion
**NOTE: The R Scripts described in this section need updated to match latest changes in the Ontology. Code should also be restructured to follow the most recent conversion domain, working backward from AE to DM.**


## Introduction
Data from study CDISCPILOT01, part of the PhUSE project "Test Data Factory", provides the source XPT files for this project as SDTM version 3.2. The files are available within this project at: ./data/source/updated_cdiscpilot.

Instance data from source XPT files is converted to CSV files for mapping to the  graph database using Stardog SMS. Data correction and augmentation occurs during the conversion process and includes correction of obvious data errors, creation of new data to facilitate testing and graph development, and creation of graph metadata (when and how the graph was created). Creation of new data is discouraged but necessary in many cases. The value for birth date is an example described later in this document.

R scripts convert the XPT files and perform data manipulation. Creation of new data is minimized, with new values created only to test specific rules or functionality or as needed to create functional URIs. As a general rule, **augmentation** data should be sourced from Excel files created for this purpose with the naming convention *<domain name>*_SUPPLMENTAL.XLSX  (Example TS_SUPPLEMENTAL.XLSX).

*TODO: This approach was initiated with the TS domain in January 2019. R scripts for DM, VS, and EX  should be revisited and the supplmental XLSX files created where appropriate*. 

The resulting CSV files are mapped to the graph using Stardog Mapping Syntax (SMS). SMS files are created manually in a text editor by referencing the ontology and instance data created by the ontology team. Map files are named using the convention  *domainname*_map.TTL and are located in the same /data/source folder as the CSV files.


Ontology triples that are NOT instance data are not recreated during the data conversion process. Rather, this information is extracted from the ontology TTL files, saved, and uploaded to the CTDasRDFSMS graph manually.  *Documentation will be added for this process.*

## Process Overview
1. Run ./r/**XPTtoCSV.R**
  * Convert sources from XPT
  * Impute values
  * Read in augmentation data
  * Subset as needed for testing
  * Create .CSV for each domain
2. Upload to Stardog using SMS mapping
  * Execute /data/source/*StarDogUpload.bat*

### R Programs
| Order  | File                 | Description                                  |
| ------ | -------------------- | ---------------------------------------------|
| 1.     | XPTtoCSV.R           | Main driver program for data conversion. Metadata import and time stamp. |
| 2.     | Functions.R          | Functions called during conversion process |
| 3.     | DM_imputeCSV.R       | DM imputation, encoding. **NOTE Must be run before EX.** See Details for DM,EX data files. |
|        | XPTtoCVS:SUPPDM      | No imputation for SUPPMD. XPTtoCVS.R processes SUPPDM directly. |
| 4.     | EX_imputeCSV.R       | EX imputation, encoding. *Currently incomplete.*
| 5.     | VS_imputeCSV.R       | VS Imputation|
| 6.     | TS_imputeCSV.R       | TS imputation. |
| 7.     | AE_imputeCSV.R       | **Work in progress** |

### Stardog .BAT files
| Order  | File                 | Description                                  |
| ------ | -------------------- | ---------------------------------------------|
| NA     | StarDogUpload.BAT    | Calls the individual mapping files to upload domains to the triplestore. |

## General Rules

### Data Creation
Some data required for developing and testing the model is not present in the source XPT files. Examples include `Investigator` and `InvestigatorID`. Values created for this purpose are stored in CSV files prefixed with the name `ctdasrdf_` to identify it as supplemental data created for the project. Each CSV file has a corresponding `_map.TTL` file. The times stamp in the metadata file ctdasrdf_graphMeta.csv is updated when XPTtoCSV.R is run. The other CSV files are created and maintained manually.

| File                   | Description                       |
| ---------------------- | ----------------------------------|
| ctdasrdf_invest.csv    | Site and Investigator |
| ctdasrdf_graphmeta.csv | Graph Metadata. Time stamp updated by XPTtoCVS.R . |


### Data Creation: Adding Rules
_Creation of rules in the RDF data is currently under development. OWL 2 is being invesitaged as a way to infer the assigned rules instead of creating them during the import process._


#### Interval IRIs
In many cases, either the start or end date of an interval may be missing in the source data. Missing values within SMS entity map result in that entity not being created. But the start of an interval must be represented in the data even when that interval has note yet been completed (example: Lifespan). For this reason, interval IRI source values are computed during the XPT to CSV conversion process by concatenating the start and end dates with an underscore. When the end date is missing, the interval value ends in an underscore.

Example of complete and incomplete LifeSpan intervals:

    study:hasLifespan  cdiscpilot01:Interval_1925-04-08_2013-07-14
    study:hasLifespan  cdiscpilot01:Interval_1972-05-11_

skos:prefLabel for intervals are derived from the imputed (_im) interval value  used in their corresponding subject IRIs (_im_en) (format: xxxxx_xxxx), not the original dates: 
     "Interval 1925-04-08_2013-07-14"
     "Interval 1972-05-11_"
See additional details in the **Labels** section, below.     
     

### Encoding
Date fields may contain dateTime values that include colons. Other fields to be converted to IRIs may contain spaces or other characters observed to be problematic in TopBraid and queries from R. The values must  be "encoded" by replacing the problematic characters. URLencoding/percent coding was tested but was also found to be an issue in TopBraid and R. The current kludge is to replace the characters with an under bar using the function `encodeCol()` located in **`Functions.R`** .

Encoded fields include "_en" their name. Examples: `lifeSpan_im_en`, `refInt_im_en`, `studyPartInt_im_en` .

`_im` - indicates values are data derived or computed from the combination of other columns of original data. I.e., non-original values.

`_en` - values that have been "encoded" as described above in order to use them in IRIs that are compatible with TopBraid and R interfaces.

#### Hashing
Stardog SMS can hash source values using the SHA-1 hash over a UTF-8 encoded string represented in base 32 encoding with padding omitted. This approach was tested in addition to the URLencoding and percent encoding. The resulting IRI values work in TopBraid and R but are not very human-readable, which is a consideration in this prototype. Hashing may be revisited at a later date.  

### Links to SDTM Terminology and Other External Codelists
Values are linked to their corresponding SDTM Terminology codes via the `code.ttl` file  and corresponding `code:` prefix. Values for the code come directly from the data whenever possible. In the example below, the "F" is from the `sex` column in the DM domain.

Example:
<pre>
  cdiscpilot01:DemographicDataCollection_01-701-1015 study:sex code:<b><font color=red>Sex_</font><font color=blue>F</font></b>
</pre>

Then in code.ttl:
<pre>
  code:<b><font color=red>Sex_</font><font color=blue>F</font></b>
    rdf:type code:Sex ;
    owl:sameAs sdtmterm:<font color=#ff8c00>C66731.C16576</font> ;
    skos:altLabel ""^^xsd:string ;
    skos:prefLabel "F"^^xsd:string ;
</pre>
The same approach is followed for links to all code and terminology values.


### Miscellaneous RDF Guidance
#### Labels

* `skos:prefLabel` is the primary label used in the graph. It may be supplemented later with `rdfs:label` and language tags. 
* Labels specific to a person, including intervals specific to that person, include the value of usubjid in that label.
* Labels for *intervals* use the imputed (_im) values as the `skos:prefLabel` instead of the more readable individual dates. The reason is that if one date is missing, as is common for LifeSpan and InformedConsent intervals, the label is not created. 


# Data Files and Mapping Detail

## Graph Metadata 
Graph metadata including data conversion date and graph version is stored in the file **ctdasrdf_graphmeta.CSV**. When the data conversion scripts are executed in R, **XPTtoCSV.R** reads in the CSV file, updates the time stamp value, then overwrites the file with the new information. The CSV file is mapped to the graph using the SMS process.

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
|Graphmeta.csv | Basic graph metadata | Description of graph content, status, version, and time stamp information.
|Graphmeta_map.TTL|SMS Map | Map to graph. |


## Investigator and Site
Investigator and site information was not available in the original data. This information is common in most studies and so was created for the prototype.

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
|Invest.csv | Investigator and site data | Investigator and assignment of investigator to site 
|Invest_map.TTL | SMS Map        | Map to graph. |

-------------------------------------------------------------------------------
## DM

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
|DM_imputeCSV.R | Data imputation and encoding| Creation of *birthdate* <br/>Assignment of Informed Consent Date<br/>Subject 01-701-1015: Death Date and Flag created. Creates dmDrugInt dataframe to merge into EX. |
| DM.XPT | Original XPT  |  From pilot data |
| DM_subset.csv | Subset for dev  |  First 3 patients (subject to change) |
| DM_map.TTL | SMS Map |   Map to graph. |
 
### Data limitations

In the source data, there is no explicit link between the *SITE ID* in *DM* and the country in *TS* domain. These links are created as part of the conversion process and show the benefit of representing this data in a graph. Country is an important component in understanding and making decisions with the data, yet this information is typically not explicitly available in SDTM!

### SMS details

Most `study:participatesIn` relations use *usubjid* in the IRIs because the participatesIn Objects are unique to that person. Examples include *InformedConsentAdult_{usubjid}* and *DemographicDataCollection_{usubjid}* . CumulativeDrugAdministration is an exception because it is an interval that may be common to more then one usubjid. It is therefore based on the CumulativeDrugAdministration interval as `CumulativeDrugAdministration_{cumuDrugAdmin_im_en}` where `cumuDrugAdmin_im_en` is created in **DM_imputeCSV.R** as the combination of `rfxstdtc` and `rfxendtc`  (drug admin start and end dates).


The following values are created in the map file:

* `VisitScreening1DemogDataColl` because DEMOG info was collected at Screening 1 for this study
*  `code:ActivityStatus_CO` : Assumes successful collection of data for demographics, informed consent, etc.
  `RandomizationBAL3` : should be moved out conversion from a data source at a future time.

### Exposure in DM
DM contains the Drug Exposure interval: `rfxstdtc` to `rfxendtc`  and is therefore mapped in the SMS file for DM, not for EX as one may expect.

DM_imputeCSV.R also creates the dataframe dmDrugInt that contains the field `cumuDrugAdmin_im`, the cumulative drug administration interval which is the combination of `rfxstdtc` and `rfxendtc`.  This value could also be computed for EX (min and max exposure dates on a per-patient basis) but the values in DM as taken as the authority.  dmDrugInt is merged into EX within XPTtoCSV.R (this may later move to EX_imputeCSV.R).


### Site and Country in DM
Site identifier (siteid) is present in DM, while the country for sites is stored in TS. There is no explicit link between the two!
For data processing, siteid is extracted to sites.csv and country (USA) hard coded. 

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
| sites.csv | Site identifiers         |  All sites listed in DM + country            |
| sites_map.TTL | SMS Map |   Map to graph. |


-------------------------------------------------------------------------------
## SUPPDM
This domain is very simple so there is no SUPPDM_imputeCSV.R The XPT is loaded within XPTtoCSV.R, subset to the correct list of usubjids, then written out to the CSV file.


| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
| SUPPDM.XPT | Original XPT  |  From pilot data |
| SUPPDM_subset.csv | Subset for dev  |  First 3 patients (subject to change) |
| SUPPDM_map.TTL | SMS Map |   Map to graph. |

### SMS details

The following values are created in the map: 

 * `study:activityStatus code:ActivityStatus_CO;`
 * `study:hasPerformer cd01p:Sponsor_1 ;`
 * `study:outcome "true"^^xsd:boolean ;`
 
 `Sponsor_` should be constructed from a data source. This small amount of data did not warrant creation of a manually created CSV data source.


| Entity    | SMS                      | Description                                   |
| --------- | ------------------------ | --------------------------------------------- |
| Population Flags  | `PopFlag{qnam}_{usubjid}`  | Unique to each Person,  a combination of the qnam and subjid |


-------------------------------------------------------------------------------
## VS

### Visit Activity
A **visit activity** is defined as one that is _scheduled_ to begin during a Visit but may extend _beyond_ the visit date. The actual performed date may be different from the scheduled date. For example, you have doctor's appointment on a Monday; they prescribe a medicine, tells you to start taking it the same day, but you wait and take it on Tuesday. The visit was Monday. The scheduled exposure was Monday, but the actual exposure was Tuesday. Three dates are needed to represent this information: 1. Actual Visit date (`vsdtc`)  2. scheduled Exposure date  3. Actual exposure date (`exstdtc`). SDTM only collects 1. and 3. These dates are often not the same, as shown in the Week 2 visit for subject usubjid=01-701-1015:  vsdtc= 1/16/2014 , exstdtc= 1/**17**/2014  
[AO- 15APR18]

### Sequence of events in VS
The sequence of data collection from each patient is important to how the data in VS is represented. The patient is told to lie down. After 5 min supine, blood pressures and temp are recorded. The patient then stands up. After 1 min standing the same tests are performed, and then again after 3 min standing time.


#<font color=red>---- THE FOLLOWING SECTIONS ARE UNDER REVISION APRIL 2018  ----</font>

The data is modeled to the graph using this pattern:

| #  | Event                     | Coded as                                       |
| -- | ------------------------- | -----------------------------------------------|
| 1  | Lie Down | `AssumeBodyPositionSupine_{usubjid}` |
| 2  | After lying 5 min | `StartRuleLying5_{usubjid}` |
| 3  | Perform tests | vstested=DIABP, SYSBP, TEMP |
| 4  | Stand up | `AssumeBodyPositionStanding_{usubjid}` |
| 5  | After standing for 1 min | `StartRuleStanding1_{usubjid}` |
| 6  | Perform tests | vstestcd=DIABP, SYSBP, TEMP |
| 7  | After standing for 3 min | `StartRuleStanding3_{usubjid}` |
| 8  | Perform tests | `vstestcd=DIABP, SYSBP, TEMP |


| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
| VX.XPT    | Original XPT              |  From pilot data |
| VS_subset.csv | Subset for dev       |  All VS obs. for patient 1015. this is more data than Ont Instances. |
| VS_map.TTL | SMS Map | Map to graph. |


### SMS details

| Entity    | SMS                      | Description 
| --------- | ------------------------ | ---------------------------------------------
| Visit     | Visit_{im_visit_CCaseSh}_{usubjid} | Unique to each visit x person. im_visit_CCaseSh is Camel-cased `visit` shortened, no spaces. 
| AssumeBodyPosition | AssumeBodyPosition{im_vspos_CCase}_{usubjid} | im_vspos_CCase = Camel-cased `vspos` (=Supine or Standing) specific to each patient.  Patient 1 Standing, Patient 2 standing, etc.


-------------------------------------------------------------------------------
## EX

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
| EX.XPT    | Original XPT              |  From pilot data |
| EX_subset.csv | Subset for dev       |  First 3 exposure events for patient 1015    |
| EX_map.TTL | SMS Map |   Map to graph. |

### SMS details
Date for the visit is extracted from VS, not from EX, because the EX date is sometimes later (not on the same day as the visit date). Date of the visit from VS:`vsdtc_en` while the EX exposure date is `exstdtc_en`.

Recall that the Drug Exposure interval is created from data in DM, not EX. See DM details, above.

-------------------------------------------------------------------------------

## TS

| File        | Role                     | Description                                  |
| ---------   | ------------------------ | ---------------------------------------------|
| TS.XPT      | Original XPT              |  From pilot data |
| TS_wide.csv | Wide format for map      |  Complete, original TS with corrections and imputations  |
| TS_wide_map.TTL | SMS Map              |  Map to graph. |

### Data Corrections and Imputations
The file is converted from the original TS.XPT long form to the wide form for mapping using SMS.

*Notes from AO, paraphrased from* https://phuse.teamworkpm.net/#messages/535928

Primary outcome measure(s) are those measures needed to support the Primary Objective of the trial. An outcome measure is a type of (i.e. subClassOf) an Observation, with  study:OutcomeMeasure a subclass of study:Observation. Sub classes are added for Primary and Secondary outcome measures (and in the future, tertiary & exploratory measures). 

In the original TS data, OUTMPRI = "Evaluate the efficacy and safety of transdermal xanomeline, 50cm2 and 75cm2, and placebo in subjects with mild to moderate Alzheimer's disease."  This is an objective, not an outcome measure so it was recoded as the third Primary Objective.

In typical Alzheimer's trials, the **primary outcome measure** is the ADAS-Cog (Alzheimer's Disease Assessment Scale, Cognitive Subscale). ADAS-Cog was added as the primary outcome measure.

Maximum age (Object of predicate study:maxSubjectAge predicate) is changed from NA to NULL.4, indicating 
that the value for age is missing due to null flavor reason #4.  [AO to TW, 2019-01-06]

### Data Additions

Some values did original data did not have CDISC code.
Trial length was missing so it was added *182 days


####Visit Activities
VistAmbulECGPlaceActivity, VisitBaselineActivity, VisitWk12Acvitity, etc.

Are created in **TS_supplemental.xlsx**. Visit information was needed to complete the VS and EX data representations in support of deriving DM reference exposure start and end dates. 



### SMS details
To be added.


-------------------------------------------------------------------------------

## AE

Under development starting January 2019  


| File        | Role                     | Description                                  |
| ---------   | ------------------------ | ---------------------------------------------|
| AE.XPT      | Original XPT        |  From pilot data |
| AE.csv      | Instance data      |                |
| AE_map.TTL  | SMS Map            |  Map to graph. |

### Data Corrections and Imputations

### Data Additions

### SMS details


-------------------------------------------------------------------------------
# Data Validation

Location:  ./r/validation

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
| CompTriples-Stardog-Shiny.R  | Triples Comparison         | RShiny app to compare select triples attached to specified Subject node|
| CollapsibleTree-PathQuery-Shiny.R  | Structure Comparison         | Collapsible tree view of all triples from specified Subject downward  |
| FullTripleComp-Stardog.R    | Triples Comparison   | Comparison of all triples from Ontology and SMS graphs in Stardog. |



# Exporting TTL from Stardog

A TTL file is constructed from within Stardog Studio using this query, then saving as TTL:
./SPARQL/ConstructTT.rq

The TTL file is usually saved to : ./data/rdf/cdiscpilot01-SMS.TTL when exploring the mapped instance data.


[Back to TOC](TableOfContents.md)

