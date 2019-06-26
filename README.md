# Going Translational With Linked Data (GoTWLD) 
GoTWLD is the successor to the PhUSE project "Clinical Trials Data as RDF (CTDasRDF)." CTDasRDF successfully modeled the CDISC Study Data Tabulation (SDTM) domains AE, DM, EX, TS, and VS. Instance data from  SAS Transport Files was converted to Linked Data as Resource Description Framework (RDF) based on the supporting ontologies developed for this project. Information about the ontologies, source data, conversion scripts, and other related files can be found by following the links in the  [Table of Contents](doc/TableOfContents.md).

At the PhUSE CSS Conference in June 2019, it was decided change project focus away from modeling additional SDTM domains to instead create three subprojects, each with its own dedicated Git Hub repository:

* Conversion of MedDRA terminology to RDF <https://github.com/phuse-org/MedDRAasRDF>
* Unique Identifiers for the Pharmaceutical Industry <https://github.com/phuse-org/UIDPharma>
* Conformance Rules for Non-Clinical data (SEND) <https://github.com/phuse-org/SENDConform>

Work on converting additional SDTM domains may continue as time permits. You can obtain more information by contacting the project leads:

* Tim Williams <tim.williams@phuse.eu>

* Armando Oliva <https://github.com/aolivamd>


# Obtaining project files
Github novices should download the files: 
Click "Clone or Download" and select "Download Zip"
Extract the file to a location like  C:\\_github
This will create the folder C:\\_github\\CTDasRDF-MASTER and subfolders. Some file paths must change for scripts to run. 