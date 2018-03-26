
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


## Process
1. Run ./r/*XPTtoCSV.R*
  * Convert from XPT
  * Impute values
  * Subset as needed for testing
  * Create .CSV for each domain
2. Upload to Stardog using SMS mapping
  a. execute /data/source/*StarDogUpload.bat*


## General Rules
### Hashing
Hashed values are used to create IRIs from source values that may contain spaces or other special characters that may interfere with IRI creation. Stardog uses the SHA-1 hash over a UTF-8 encoded string represented in base 32 encoding with padding omitted.

* All dates are hashed

#### Interval IRIs - Special Hashing
In many cases, either the start or end date of an interval may be missing in the source data. This could lead to the creatoin of incorrect IRI values. Example: Lifespan should not be coded as: *Lifespan_{#brthdate}_{#dthdtc}* , because in most instances the death date would be missing and this could lead to two people being assigned the same Lifespan if they were born on the same date and have not yet died.

Creation of all interval IRIS (Lifespan, reference interval, study partcipation interval, etc.) are created from an imputed column creating during the conversion from XPT to CSV. The data is prefixed with the type of interval being constructed, once again to ensure the IRI is unique to the data being represented. A lifespan IRI should be unique from an study participation IRI, even if the start and end dates are identical.

    dm$im_lifeSpan     <- paste("lifeSpan",dm$brthdate, dm$dthdtc)

These imputations occur in the R program code unique to each domain (`DMImpute_CSV.R`, `VSImput_CSV.R`, etc.).

Then in the mapping file the imputed column is used to create the Lifespan IRI:

    cdiscpilot01:Lifespan_{#im_lifeSpan} 

### Links to SDTM Terminology and Other External Codelists
Values are created during the imputation step allow linkage to external terminlogy files. 
TODO: Add Example for how SYSBP is coded to the proper Cxxx.Cxxx termin. 


### Links Rules 
Values that enable creation of IRIs for rules are also created within the imputation steps.
TODO: Add example of STANDING rule for blood pressure.


## Graph Metadata
**PENDING**: 
*Creation of graph metadata (graph creation date, version, etc.) has not yet migrated from the R to the SMS process. When it does, it will be documented here.*


## Additional Data 
Some data required by the ontology is not in the original source. When it is associated with a domain that is being converted, it will be closely tied to the conversion step for that domain. Eg: See DM_imputeCSV.R under the DM domain.

Other data is imputed as needed:

### Investigator and Site

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

| Entity    | SMS                      | Description 
| --------- | ------------------------ | ---------------------------------------------
| Visit     | Visit_{#visit}_{usubjid} | Unique to each visit x person. visit has spaces and must be hashed. 
| AssumeBodyPosition | AssumeBodyPosition_{vspos}_{#vstpt} | Combination of the *vspos* (SUPINE or STANDING) and *vstpt* (After standing for X, after lying for X) 

