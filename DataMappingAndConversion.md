
# Data Mapping and Conversion
## Introduction
This document describes the conversion of data from the source XPT files to RDF.
**CAUTION**: It is almost certain this document is out of date. It is definitely
incomplete.

Pre-processing and creation of new data not in the original sources is mimizied wherever possible. Data imputation is used for values typically seen in SDTM source data but absent from the study used to develop the prototype. See the discussion below on birth date as an example. 


## General Notes
Stardog Mapping Syntax (SMS) is employed in the conversion process. Mapping files are named
using the convention *domainname*_mappings.TTL and are located in the /data/source
folder. The mapping files rely on previous conversion of the source .XPT to .CVS
using the R script **XPTtoCSV.R**.

## Data Files
Source data comes from the PhUSE "Test Data Factory" CDISCPILOT01 study,
SDTM 3.2 version. The files are available within this project at:  
./data/source/updated_cdiscpilot
Domains under construction include: DM, SUPPM, VS. SUPPVS and EX are pending.
TS will follow.


### Process
1. Run ./r/*XPTtoCSV.R*
  * Convert from XPT
  * Impute values
  * Subset as needed for testing
  * Create .CSV for each domain
2. Upload to Stardog using SMS mapping
  a. execute /data/source/*StarDogUpload.bat*


### General Rules
#### Hashing
Hashed values are used to create IRIs from source values that may contain spaces or other special characters that may interfere with IRI creation. Stardog uses the SHA-1 hash over a UTF-8 encoded string represented in base 32 encoding with padding omitted.

* All dates are hashed
* All *interval* IRIs are constructed with hashed dates using the startDate_stopDate pattern.  Examples: *Lifespan_{#brthdate}_{#dthdtc}* , *StudyParticipationInterval_{#dmdtc}_{#rfpendtc}* 

### Graph Metadata
**PENDING**: 
*Creation of graph metadata (graph creation date, version, etc.) has not yet migrated from the R to the SMS process. When it does, it will be documented here.*


### Additional Data 
Some data required by the ontology is not in the original source. When it is associated with a domain that is being converted, it will be closely tied to the conversion step for that domain. Eg: See DM_imputeCSV.R under the DM domain.

Other data is imputed as needed:

#### Investigator and Site
| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
|invest_imputed.csv | Data imputation | Investigator and assignment of investigator to a site 
|invest_mappings.TTL | SMS Map        | Upload of imputed data |


### DM
| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
|DM_imputeCSV.R | Data imputation | Creation of *birthdate* <br/>Assignment of Informed Consent Date<br/>Subject 01-701-1015: Death Date and Flag created.|
| DM.XPT | Orginal XPT  |  From pilot data |
| DM_subset.csv | Subset for dev  |  First 3 patients (subject to change) |
| DM_mappings.TTL | SMS Map |   See SMS Details |
 

#### SMS details

All study:participatesIn relations use *usubjid* in the IRIs because these are unique to that subject. Examples: *InformedConsentAdult_{usubjid}* , *DemographicDataCollection_{usubjid}*  All labels for intervals and labels that reference the Person now also use *usubjid* instead of the row order number.


The following values are created in the mapping:

 `VisitScreening1DemogDataColl` because DEMOG info was collected at Screening 1 for this study
  `code:ActivityStatus_1` : Assumes successful collection of data for demographics, informed consent, etc.
  `RandomizationBAL3` : should be moved out conversion from a datasource at a future time.


| Entity    | SMS                      | Description                                   |
| --------- | ------------------------ | --------------------------------------------- |
| Person    | `Person_{usubjid}`       | |
| Person Label | `Person {usubjid}`  | Previous conversion process used a number based on row order. Where applicable, all labels follow this new approach |



### SUPPDM

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
| SUPPDM.XPT | Orginal XPT  |  From pilot data |
| SUPPDM_subset.csv | Subset for dev  |  First 3 patients (subject to change) |
| SUPPDM_mappings.TTL | SMS Map |   See SMS Details |

#### SMS details

The following values are created in the mapping. 
 `study:activityStatus code:ActivityStatus_1;`
 `study:hasPerformer cd01p:Sponsor_1 ;`
 `study:outcome "true"^^xsd:boolean ;`
 At a minimum, `Sponsor_` should be constructed from a data source.


| Entity    | SMS                      | Description                                   |
| --------- | ------------------------ | --------------------------------------------- |
| Population Flags  | `PopFlag{qnam}_{usubjid}`  | Unique to each Person,  a combination of the qnam and subjid |


### VS

| Entity    | SMS                      | Description 
| --------- | ------------------------ | ---------------------------------------------
| Visit     | Visit_{#visit}_{usubjid} | Unique to each visit x person. visit has spaces and must be hashed. 
| AssumeBodyPosition | AssumeBodyPosition_{vspos}_{#vstpt} | Combination of the *vspos* (SUPINE or STANDING) and *vstpt* (After standing for X, after lying for X) 

