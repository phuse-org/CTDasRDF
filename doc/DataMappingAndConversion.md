# Data Mapping and Conversion

## Introduction
Most instance data is uploaded to the graph by converting source XPT files. Notable exceptions include graph metadata (when and how the graph was created) and other information that is not stored in the XPT files  [ADD EXAMPLE - TW]

Pre-processing and creation of new data not in the original sources is minimized wherever possible. Data imputation is used for values typically seen in SDTM source data but absent from the study used to develop the prototype. The value for birth date is an example described later in this document.


## General Notes
XPT files are converted to CSV using R. The conversion process then relies on Stardog Mapping Syntax (SMS) to convert CSV files to the graph. Mapping files are named using the convention *domainname*_mappings.TTL and are located in the same /data/source folder as the CSV files.

## Data Files
Source data comes from the PhUSE "Test Data Factory" CDISCPILOT01 study,
SDTM version 3.2. The files are available within this project at: ./data/source/updated_cdiscpilot . Domains under construction include: DM, SUPPM, EX, and VS. SUPPVS is pending and the projet is likely to extend to TS in the near future.


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
| 3.     | DM_imputeCSV.R       | DM imputation, encoding. Must be run before EX. See Details for DM,EX data files. |
|        | XPTtoCVS:SUPPDM      | No imputation for SUPPMD. XPTtoCVS.R processes SUPPDM directly. |
| 4.     | EX_imputeCSV.R       | EX imputation, encoding. Incomplete 2012-12-21
| 5.     | VS_imputeCSV.R       | VS Imputation|
| 6.     | _TS_impute.CVS_      | **_planned_** |
| 7.     | _TBD_                | _TBD_ |

### Stardog .BAT files
| Order  | File                 | Description                                  |
| ------ | -------------------- | ---------------------------------------------|
| NA     | StarDogUpload.BAT    | Calls the individual mapping files to upload domains to the triplestore. |




## General Rules

### Data Creation
Some data required for developing and testing the model is not present in the source XPT files. Examples include `Investigator` and `InvestigatorID`. Values created for this purpose are stored in CSV files prefixed with the name `ctdasrdf_` to identify it as supplemental data created for the project. Each CSV file has a corresponding `_mappings.TTL` file. The timesstamp in the metadata file ctdasrdf_graphMeta.csv is updated programmatically when XPTtoCSV.R is run. The other CSV files are created and maintained manually.

| File                   | Description                       |
| ---------------------- | ----------------------------------|
| ctdasrdf_invest.csv    | Site and Investigator |
| ctdasrdf_graphmeta.csv | Graph Metadata. Timestamp updated by XPTtoCVS.R . |


### Data Creation: Adding Rules
_Creation of rules in the RDF data is currently under development. OWL 2 is being invesitaged as a way to infer the assigned rules instead of creating them during the import process._


#### Interval IRIs
In many cases, either the start or end date of an interval may be missing in the source data. Missing values within SMS entity map result in that entity not being created. But the start of an interval must be represented in the data even when that interval has note yet been completed (eg: Lifespan). For this reason, interval IRI source values are computed during the XPT to CSV conversion process by concatenating the start and end dates with an underscore. When the end date is missing, the interval value ends in an underscore.

Example of complete and incomplete LifeSpan intervals:

    study:hasLifespan  cdiscpilot01:Interval_1925-04-08_2013-07-14
    study:hasLifespan  cdiscpilot01:Interval_1972-05-11_

skos:prefLabel for intervals are derived from the imputed (_im) interval value  used in their corresponding subject IRIs (_im_en) (format: xxxxx_xxxx), not the original dates: 
     "Interval 1925-04-08_2013-07-14"
     "Interval 1972-05-11_"
See addtional details in the **Labels** section, below.     
     

### Encoding
Date fields may contain dateTime values that include colons. Other fields to be converted to IRIs may contain spaces or other characters observed to be problematic in TopBraid and queries from R. The values must  be "encoded" by replacing the problematic characters. URLencoding/percent coding was tested but was also found to be an issue in TopBraid and R. The current kludge is to replace the characters with an underbar using the function `encodeCol()` located in **`Functions.R`** .

Encoded fields include "_en" their name. Examples: `lifeSpan_im_en`, `refInt_im_en`, `studyPartInt_im_en` .

`_im` - indicates values are data derived or computed from the combination of other columns of original data. I.e., non-original values.

`_en` - values that have been "encoded" as described above in order to use them in IRIs that are compatible with TopBraid and R interfaces.

#### Hashing
Stardog SMS can hash source values using the SHA-1 hash over a UTF-8 encoded string represented in base 32 encoding with padding omitted. This approach was tested in addition to the URLencoding and percent encoding. The resulting IRI values work in TopBraid and R but are not very human-readable, which is a consideration in this prototype. Hashing may be revisted at a later date.  

### Links to SDTM Terminology and Other External Codelists
Values are linked to their corresponding SDTM Terminology codes via the `code.ttl` file  and corrsponding `code:` prefix. Values for the code come directly from the data whenever possible. In the example below, the "F" is from the `sex` column in the DM domain.

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

* `skos:prefLabel` is the primary label used in the graph. It may be supplmented later with `rdfs:label` and language tags. 
* Labels specific to a person, including intervals specific to that person, include the value of usubjid in that label.
* Labels for *intervals* use the imputed (_im) values as the `skos:prefLabel` instead of the more readable indivdual dates. The reason is that if one date is missing, as is common for LifeSpan and InformedConsent intervals, the label is not created. 


# Data Files and Mapping Detail

## Graph Metadata 
Graph metadata including data conversion date and graph version is stored in the file **ctdasrdf_graphmeta.CSV**. When the data conversion scripts are executed in R, **XPTtoCSV.R** reads in the CSV file, updates the timestamp value, then overwrites the file with the new information. The CSV file is mapped to the graph using the SMS process.

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
|ctdasrdf_graphmeta.csv | Basic graph metadata | Description of graph content, status, version, and timestamp information.
|ctdasrdf_graphmeta_mappings.TTL|SMS Map | Map to graph. |


## Investigator and Site
Investigator and site information was not available in the original data. This information is common in most studies and so was created for the prototype.

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
|ctdasrdf_invest.csv | Investigator and site data | Investigator and assignment of investigator to site 
|ctdasrdf_invest_mappings.TTL | SMS Map        | Map to graph. |


## DM

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
|DM_imputeCSV.R | Data imputation and encoding| Creation of *birthdate* <br/>Assignment of Informed Consent Date<br/>Subject 01-701-1015: Death Date and Flag created. Creates dmDrugInt dataframe to merge into EX.|
| DM.XPT | Orginal XPT  |  From pilot data |
| DM_subset.csv | Subset for dev  |  First 3 patients (subject to change) |
| DM_mappings.TTL | SMS Map |   Map to graph. |
 

### SMS details

Most `study:participatesIn` relations use *usubjid* in the IRIs because the participatesIn Objects are unique to that person. Examples include *InformedConsentAdult_{usubjid}* and *DemographicDataCollection_{usubjid}* . CumulativeDrugAdministration is an exception because it is an interval that may be common to more then one usubjid. It is therefore based on the CumulativeDrugAdministration interval as `CumulativeDrugAdministration_{cumuDrugAdmin_im_en}` where `cumuDrugAdmin_im_en` is created in **DM_imputeCSV.R** as the combination of `rfxstdtc` and `rfxendtc`  (drug admin start and end dates).


The following values are created in the mapping:

* `VisitScreening1DemogDataColl` because DEMOG info was collected at Screening 1 for this study
*  `code:ActivityStatus_CO` : Assumes successful collection of data for demographics, informed consent, etc.
  `RandomizationBAL3` : should be moved out conversion from a datasource at a future time.

### Exposure in DM
DM contains the Drug Exposure interval: `rfxstdtc` to `rfxendtc`  and is therefore mapped in the SMS file for DM, not for EX as one may expect.

DM_imputeCSV.R also creates the dataframe dmDrugInt that contains the field `cumuDrugAdmin_im`, the cumulative drug adminstration interval which is the combination of `rfxstdtc` and `rfxendtc`.  This value could also be computed for EX (min and max exposure dates on a per-patient basis) but the values in DM as taken as the authority.  dmDrugInt is merged into EX within XPTtoCSV.R (this may later move to EX_imputeCSV.R).


## SUPPDM
This domain is very simple so there is no SUPPDM_imputeCSV.R The XPT is loaded within XPTtoCSV.R, subset to the correct list of usubjids, then written out to the CSV file.


| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
| SUPPDM.XPT | Orginal XPT  |  From pilot data |
| SUPPDM_subset.csv | Subset for dev  |  First 3 patients (subject to change) |
| SUPPDM_mappings.TTL | SMS Map |   Map to graph. |

### SMS details

The following values are created in the mapping. 

 * `study:activityStatus code:ActivityStatus_CO;`
 * `study:hasPerformer cd01p:Sponsor_1 ;`
 * `study:outcome "true"^^xsd:boolean ;`
 
 `Sponsor_` should be constructed from a data source. This small amount of data did not warrant creation of a manually created CSV data source.


| Entity    | SMS                      | Description                                   |
| --------- | ------------------------ | --------------------------------------------- |
| Population Flags  | `PopFlag{qnam}_{usubjid}`  | Unique to each Person,  a combination of the qnam and subjid |


## VS

### Visit Activity
A **visit activity** is defined as one that is _scheduled_ to begin during a Visit but may extend _beyond_ the visit date. The actual performed date may be different from the scheduled date. For example, you have doctor's appointment on a Monday; they prescribe a medicine, tells you to start taking it the same day, but you wait and take it on Tuesday. The visit was Monday. The scheduled exposure was Monday, but the actual exposure was Tuesday. Three dates are needed to represent this information: 1. Actual Visit date (`vsdtc`)  2. scheduled Exposure date  3. Actual exposure date (`exstdtc`). SDTM only collects 1. and 3. These dates are often not the same, as shown in the Week 2 visit for subject usubjid=01-701-1015:  vsdtc= 1/16/2014 , exstdtc= 1/**17**/2014  
[AO- 15APR18]

### Sequence of events in VS
The sequence of data collection from each patient is important to how the data in VS is represented. The patient is told to lie down. After 5 min supine, blood pressures and temp are recorded. The patient then stands up. After 1 min standng the same tests are performed, and then again after 3 min standing time.


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
| VX.XPT    | Orginal XPT              |  From pilot data |
| VS_subset.csv | Subset for dev       |  All VS obs. for patient 1015. this is more data than Ont Instances. |
| VS_mappings.TTL | SMS Map | Map to graph. |


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
| EX_mappings.TTL | SMS Map |   Map to graph. |

### SMS details
Date for the visit is extracted from VS, not from EX, because the EX date is sometimes later (not on the same day as the visit date). Date of the visit from VS:`vsdtc_en` while the EX exposure date is `exstdtc_en`.

Recall that the Drug Exposure interval is created from data in DM, not EX. See DM details, above.


# Data Validation

Location:  ./r/validation

| File      | Role                     | Description                                  |
| --------- | ------------------------ | ---------------------------------------------|
| CompTriples-Stardog-Shiny.R  | Triples Comparison         | RShiny app to compare select triples attached to specified Subject node|
| CollapsibleTree-PathQuery-Shiny.R  | Structure Comparison         | Collapsible tree view of all triples from specified Subject downward  |
| FullTripleComp-Stardog.R    | Triples Comparison   | Comparision of all triples from Ontology and SMS graphs in Stardog. |



# Exporing TTL from Stardog

A TTL file is constructed from within Stardog Studio using this query, then saving as TTL:
./SPARQL/ConstructTT.rq

The TTL file is usually saved to : ./data/rdf/cdiscpilot01-SMS.TTL when exporing the mapped instance data.


