
# Data Mapping and Conversion
## Introduction
This document describes the conversion of data from the source XPT files to RDF.
**CAUTION**: It is almost certain this document is out of date. It is definitely
incomplete.

Pre-processing and creation of new data not in the original sources is minimized wherever possible. Data imputation is used for values typically seen in SDTM source data but absent from the study used to develop the prototype. See the discussion below on birth date as an example. 


## General Notes
XPT files are converted to CSV using R. The conversion process then relies on Stardog Mapping Syntax (SMS) to convert CSV files to the graph. Mapping files are named using the convention *domainname*_mappings.TTL and are located in the /data/source folder.

## Data Files
Source data comes from the PhUSE "Test Data Factory" CDISCPILOT01 study,
SDTM version 3.2. The files are available within this project at:  
./data/source/updated_cdiscpilot . Domains under construction include: DM, SUPPM, VS. SUPPVS and EX are pending.
TS will follow.


## Process Overview
1. Run ./r/**XPTtoCSV.R**
  * Convert sources from XPT
  * Impute values
  * Subset as needed for testing
  * Create .CSV for each domain
2. Upload to Stardog using SMS mapping
  a. execute /data/source/*StarDogUpload.bat*

### R Programs
| Order  | File                 | Description                                  |
| ------ | -------------------- | ---------------------------------------------|
| 1.     | XPTtoCSV.R           | Main driver program data conversion using R |
| 2.     | Functions.R          | Functions called during conversion process |
| 3.     | DM_imputeCSV.R       | DM imputation, encoding. No SUPPDM impute script needed as of 02APR18 |
| 4.     | VS_imputeCSV.R       | OUTDATED: Needs update to latest SMS mapping methods 02APR18 |
| 5.     |  ||
| 6.     |  ||

### Stardog .BAT files
| Order  | File                 | Description                                  |
| ------ | -------------------- | ---------------------------------------------|
| NA     | StarDogUpload.BAT    | Calls the various mapping files to upload domains to the triplestore. |
| NA     | StarDogExportTTL.BAT | Export the entire CTDasRDF graph to TTL. (outdated: use SPARQL CONSTRUCT instead) |



## General Rules

### Data Creation
Some data required for developing and testing the model was not present in the orginal source. Examples include Investigator and Site. Each .CSV data source of this type is prefixed with the name `ctdasrdf_` to indicate it is supplemental data created for the project and each has a corresponding `_mappings.TTL` file.

| File                   | Description                       |
| ---------------------- | ----------------------------------|
| ctdasrdf_invest.csv    | Site and Investigator |
| ctdasrdf_graphMeta.csv | Graph Metadata: NOT YET PRESENT. Will be created from R. |


### Data Creation: Adding Rules
Values that enable creation of IRIs for rules are also created within the imputation steps.

*TODO: ADD DETAILS, EXAMPLES OF STANDING RULE FOR BLOOD PRESSURE AND HOW IT IS THEN USED IN VS.*

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


### SMS details
| Entity    | SMS                      | Description 
| --------- | ------------------------ | ---------------------------------------------
| Visit     | Visit_{im_visit_CCaseSh}_{usubjid} | Unique to each visit x person. im_visit_CCaseSh is Camel-cased `visit` shortned, no spaces. 
| AssumeBodyPosition | AssumeBodyPosition{im_vspos_CCase}_{usubjid} | im_vspos_CCase = Camel-cased `vspos` (=Supine or Standing) specific to each patient.  Patient 1 Standing, Patient 2 standing, etc.

**More to be added.