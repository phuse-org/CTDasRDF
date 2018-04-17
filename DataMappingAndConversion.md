# Data Mapping and Conversion
_Last updated 16 APR 2018 _

## Introduction
This document describes the conversion of data from the source XPT files to RDF.
**CAUTION**: It is almost certain this document is out of date. It is definitely
incomplete.

Pre-processing and creation of new data not in the original sources is minimized wherever possible. Data imputation is used for values typically seen in SDTM source data but absent from the study used to develop the prototype. The value for birth date is an example described later in this document.


## General Notes
XPT files are converted to CSV using R. The conversion process then relies on Stardog Mapping Syntax (SMS) to convert CSV files to the graph. Mapping files are named using the convention *domainname*_mappings.TTL and are located in the same /data/source folder as the CSV files.

## Data Files
Source data comes from the PhUSE "Test Data Factory" CDISCPILOT01 study,
SDTM version 3.2. The files are available within this project at: ./data/source/updated_cdiscpilot Domains under construction include: DM, SUPPM, EX, and VS. SUPPVS is pending and the projet is likely to extent to TS in the near future.


## Process Overview
1. Run ./r/**XPTtoCSV.R**
  * Convert sources from XPT
  * Impute values
  * Subset as needed for testing
  * Create .CSV for each domain
2. Upload to Stardog using SMS mapping
  * Execute /data/source/*StarDogUpload.bat*

### R Programs
| Order  | File                 | Description                                  |
| ------ | -------------------- | ---------------------------------------------|
| 1.     | XPTtoCSV.R           | Main driver program data conversion using R. Metadata import and timestamp. |
| 2.     | Functions.R          | Functions called during conversion process |
| 3.     | DM_imputeCSV.R       | DM imputation, encoding. |
|        | XPTtoCVS:SUPPDM      | No imputation for SUPPMD. XPTtoCVS.R processes SUPPDM |
| 4.     | EX_imputeCSV.R       | EX imputation, encoding. 
| 5.     | VS_imputeCSV.R       | **_UNDER CONSTRUCTION APRIL 2018_** |
| 6.     | _TS_impute.CVS_      | **_planned_** |
| 7.     | _TBD_                | _TBD_ |

### Stardog .BAT files
| Order  | File                 | Description                                  |
| ------ | -------------------- | ---------------------------------------------|
| NA     | StarDogUpload.BAT    | Calls the individual mapping files to upload domains to the triplestore. |

| NA     | StarDogExportTTL.BAT | Export the entire CTDasRDF graph to TTL. Not in use: SPARQL CONSTRUCT used to create sorted TTL export) |



## General Rules

### Data Creation
Some data required for developing and testing the model is not present in the source XPT files. Examples include `Investigator` and `InvestigatorID`. Values were created by the team and stored in CSV files prefixed with the name `ctdasrdf_` to indicate it is supplemental data created for the project. Each CSV file has a corresponding `_mappings.TTL` file. The metadata file ctdasrdf_graphMeta.csv is created programmatically (as source call from XPTtoCVS.R) because it generates timestamp information. The other CSV files are created and maintained manually.

| File                   | Description                       |
| ---------------------- | ----------------------------------|
| ctdasrdf_invest.csv    | Site and Investigator |
| ctdasrdf_graphMeta.csv | Graph Metadata: NOT YET PRESENT. Will be created from R. |


### Data Creation: Adding Rules
_Creation of rules in the RDF data is currently under development. OWL 2 is being invesitaged as a way to infer the assigned rules instead of creating them during the import process._


#### Interval IRIs - Special Imputation
In many cases, either the start or end date of an interval may be missing in the source data. Missing values within an SMS entity result in that entity not being created. We still want to capture the start of an interval even if that interval is not yet completed (eg: Lifespan). For this reason, interval IRI source values are computed during the XPT to CSV conversion process for intervals like: life span (`lifespan_im`), reference interval (`refInt_im`), study participation interval (`studyPartInt_im`)  by combining their start and end dates. These values are then URL encoded, resulting in new columns: `lifespan_im_en`, `refInt_im_en`, `studyPartInt_im_en` .

During creation of the IRIs in the mapping files, these imputed dates have an additional prefix added so life span IRIs are differentated from Study Participation IRIs, even when the date ranges are identical. Examples:

    cdiscpilot01:Lifespan_{lifeSpan_im_en}
    cdiscpilot01:StudyParticipationInterval_{studyPartInt_im_en} 
    cdiscpilot01:ReferenceInterval_{refInt_im_en} 

### Encoding
URL encoding is used for values that must become IRIs but contain spaces or special characters.A new column is created by calling the encoding function as shown for this example for the column `ethnic` which results in the encoded column `ethnic_en`

    encodeCol(data=dm, col="ethnic")

Imputed columns may also be encoded, resulting in variable names like `varname_im_en` , with the _im and _en identifying hte column as both imputed *and* encoded.

#### Hashing
Hashing of values is not currently in use. It may be employed if URL encoding found to be insufficient. Stardog uses the SHA-1 hash over a UTF-8 encoded string represented in base 32 encoding with padding omitted. Hashing was used prior to switching over to URL encoding on 02APR18. 


### Links to SDTM Terminology and Other External Codelists
TODO: ADD DESCRIPTION OF HOW ENCODED VALUES ARE LINKED TO TERMINOLOGY. Add Example for how SYSBP is coded to the proper Cxxx.Cxxx termin. 


# Data Files and Mapping Detail

## Graph Metadata 
Graph metadata is stored in the .CSV file. During the data conversion process, XPTtoCSV.R reads in the CSV file, updates the timestamp value, and over writes the CSV file with the new information. The CSV file is mapped to the graph using the SMS process.

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
|ctdasrdf_graphmeta_mappings.CSV | Basic graph metadata | Description of graph content, status, version, and timestamp information.
|ctdasrdf_graphmeta_mappings.TTL|Map for CVS to graph| Import of metadata triples.|



## Investigator and Site

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
|invest_imputed.csv | Data imputation | Investigator and assignment of investigator to a site 
|invest_mappings.TTL | SMS Map        | Upload of imputed data |


## DM

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
|DM_imputeCSV.R | Data imputation | Creation of *birthdate* <br/>Assignment of Informed Consent Date<br/>Subject 01-701-1015: Death Date and Flag created.|
| DM.XPT | Orginal XPT  |  From pilot data |
| DM_subset.csv | Subset for dev  |  First 3 patients (subject to change) |
| DM_mappings.TTL | SMS Map |   See SMS Details |
 

### SMS details

All study:participatesIn relations use *usubjid* in the IRIs because these are unique to that subject. Examples: *InformedConsentAdult_{usubjid}* , *DemographicDataCollection_{usubjid}*  All labels for intervals and labels that reference the Person now also use *usubjid* instead of the row order number.


The following values are created in the mapping:

 `VisitScreening1DemogDataColl` because DEMOG info was collected at Screening 1 for this study
  `code:ActivityStatus_1` : Assumes successful collection of data for demographics, informed consent, etc.
  `RandomizationBAL3` : should be moved out conversion from a datasource at a future time.


| Entity    | SMS                      | Description                                   |
| --------- | ------------------------ | --------------------------------------------- |
| Person    | `Person_{usubjid}`       | |
| Person Label | `Person {usubjid}`  | Previous conversion process used a number based on row order. Where applicable, all labels follow this new approach |


## SUPPDM

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
| SUPPDM.XPT | Orginal XPT  |  From pilot data |
| SUPPDM_subset.csv | Subset for dev  |  First 3 patients (subject to change) |
| SUPPDM_mappings.TTL | SMS Map |   See SMS Details |

### SMS details

The following values are created in the mapping. 
 `study:activityStatus code:ActivityStatus_1;`
 `study:hasPerformer cd01p:Sponsor_1 ;`
 `study:outcome "true"^^xsd:boolean ;`
 At a minimum, `Sponsor_` should be constructed from a data source.


| Entity    | SMS                      | Description                                   |
| --------- | ------------------------ | --------------------------------------------- |
| Population Flags  | `PopFlag{qnam}_{usubjid}`  | Unique to each Person,  a combination of the qnam and subjid |


## VS

### Visit Activity
A **visit activity** is defined as one that is _scheduled_ to begin during a Visit but may extend _beyond_ the visit. The actual performed date may be different from the scheduled date. For example, you have doctor's appointment on a Monday; he prescribes a medicine, tells you to start taking it the same day, but you wait and take it on Tuesday. The visit was Monday. The scheduled exposure was Monday, but the actual exposure was Tuesday. Three dates are needed to represent this information: 1. Actual Visit date (`vsdtc`)  2. scheduled Exposure date  3. Actual exposure date (`exstdtc`). SDTM only collects 1. and 3. These dates are often not the same as shown in the Week 2 visit for subject usubjid=01-701-1015:  vsdtc= 1/16/2014 , exstdtc= 1/**17**/2014  
[AO- 15APR18]

### Sequence of events in VS
The sequence of data collection from each patient is important to how the data in VS is represented. The patient is told to lie down. After 5 min supine, blood pressures and temp are recorded. The patient then stands up. After 1 min standng the same tests are performed, and then again after 3 min standing time.
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
| VX.XPT    | Orginal XPT              |  From pilot data |
| VS_subset.csv | Subset for dev       |  All VS obs. for patient 1015. this is more data than Ont Instances. |
| VS_mappings.TTL | SMS Map | See SMS Details |


### Inferencing of Protocol Rules using OWL 2
_[Approach being implemented April 2018 with documentation to follow]_

### SMS details

| Entity    | SMS                      | Description 
| --------- | ------------------------ | ---------------------------------------------
| Visit     | Visit_{im_visit_CCaseSh}_{usubjid} | Unique to each visit x person. im_visit_CCaseSh is Camel-cased `visit` shortned, no spaces. 
| AssumeBodyPosition | AssumeBodyPosition{im_vspos_CCase}_{usubjid} | im_vspos_CCase = Camel-cased `vspos` (=Supine or Standing) specific to each patient.  Patient 1 Standing, Patient 2 standing, etc.


## EX

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
| EX.XPT    | Orginal XPT              |  From pilot data |
| EX_subset.csv | Subset for dev       |  First 3 exposure events for patient 1015    |
| EX_mappings.TTL | SMS Map |   See SMS Details |

### SMS details
Date for the visit is extracted from VS, not from EX, because the EX date is sometimes later (not on the same day as the visit date).

