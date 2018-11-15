<<<<<<< Updated upstream:doc/HandsOnCTDasRDF.md
---
title: "Getting hands on CTDasRDF Project"
output: 
  html_document:
    toc: true
    keep_md: true
---



## Revision

Date         | Comment
------------ | ----------------------------
2018-08-23   | Documentation creation (KG)
2018-10-12   | Enhance documentation (KG)
2018-10-13   | Ontology viz and namespace cmds (NN)
2018-10-17   | Enhance WebVOWL and Protege documentation (KG)


## Overview

To get start your hands on the project you can perform the following steps:

- Install software (R, RStudio, Stardog)
- Setup stardog (create database, start stardog)
- Then you can create the data in R via the scripts from the repository or skikp this as the data is also available
- Loading the data into stardog
- Now you are ready to explore either in Stardog or in R

![Figure: Screenshot to download .zip](./doc/images/compiled_overview.png)

## Installation Hints (Windows)

- Install R (https://cran.r-project.org/bin/windows/base/)
- Install RStudio (https://www.rstudio.com/products/rstudio/download/)
- Install Stardog (https://www.stardog.com/docs/)

You can install packages in R/RStudio easily through the install.packages("[name]") command.

### Working with Proxy in R / RStudio

You can use proxy settings for RStudio:  
- run file.edit('~/.Renviron') in RStudio console, include:	 
```
http_proxy=http://<proxy-adress>:<proxy-port>  
http_proxy_user=<Domain>%5C<ID>:<password>  
https_proxy=https://<proxy-adress>:<proxy-port>  
https_proxy_user=<Domain>%5C<ID>:<password>  
```
Be aware that the DEVTOOLS package does unluckily not work with an authentification proxy, but you can download the packages manually and install them through load_all("[path]"). For the R rrdf package you could do the following for example:
```
#1) If not behind a PROXY, use this simple way
install.packages("rJava") # if not present already
install.packages("devtools") # if not present already
library(devtools)
install_github("egonw/rrdf", subdir="rrdflibs")
install_github("egonw/rrdf", subdir="rrdf", build_vignettes = FALSE)
#2) If behind PROXY: download rrdf from github and unzip it into <path>
#https://github.com/egonw/rrdf
library(devtools)
load_all('C:/<path>/rrdflibs')
load_all('C:/<path>/rrdf')
library(rrdf)
```

### Stardog installation / execution hints

The windows installation is a bit complex like explained in their [documentation](https://www.stardog.com/docs/?utm_campaign=Stardog%3A%20Product%20Download&utm_source=hs_automation&utm_medium=email&utm_content=57254532&_hsenc=p2ANqtz-8zVpYrKT0H7p1ZHG_8vJD5zs7QE0-M7RhBS4K0DvJ1ar0XrbyTNlxmpgZf8b0gFG-s9Bt7V5BwBrlH9ROZt4rdhXKDyA&_hsmi=57254532#_quick_start_guide).  

Make sure you set the environment variables in your environment - in the console do for example (windows->"cmd"):
```
SET STARDOG_HOME=C:\Temp\Programs\stardog-5.3.2
SET PATH=%PATH%;C:\Temp\Programs\stardog-5.3.2\bin
```

Then you can start the server - in the console (windows->"cmd"):
```
stardog-admin.bat server start
```

Now you are hopefully ready to start the graphical user web interface through <http://localhost:5820>. The initial username and password might be "admin".  
  
  
**Issues with Java**:  
You might have issues with JAVA when stardog is not working. Make sure you have Java installed and it should be not 9 or 10 (so likely it will be 8). You can check the version in the console (windows -> "cmd"):
```
java -version
```
You could install multiple JAVA version on the PC. Make sure that when using Stardog, you have, e.g. the Java binaries from Java 8 in the PATH variable. You can investigate the content of %PATH% in the commando line through 
```
echo %PATH%
```
You could change the content to exclude the wrong JAVA binaries and include the JAVA 8 binaries through the SET PATH comment.

## Download Repository

The project files are available on Github <https://github.com/phuse-org/CTDasRDF> and are regularily updated. It is recommended to clone the repository and update this regularily with the git functionality easily. If you are not familar with git, you might want to just download the complete repository and unzip it a any location. Use the green button to "Clone or Download".

![Figure: Screenshot to download .zip](./doc/images/screen_download.png)

You can read the documentation in the github repository by clicking the *.rmd or *.md files. You might want to read the following documentations in the following order:
* CTDasRDF.rmd - project overview
* DataMappingAndConversion.md - content details
* HandsOnGuidance.rmd - guidance to get hands on experiences based on this project

## Get Hands on Data Preparation Programming (R)

Details on the general processes can be found in DataMappingAndConversion.md

* _im are derived or computed variables
* _en are encoded variables (special character replacement)

You can run the XPTtoCSV.R Program and run all lines together or single execute the commands and the included files to check what's going on. The XPT files are used as basis. Data processing took place which is needed for encoding and similar. Also some data is made up to have a better playground. Finally CSV files are created which are used to import to Stardog.

### XPTtoCSV

Creates the content CSV files which will be read together with the Stardoc SMS mapping to directly load the triples to the Stardoc triple store

Processing Step      | Description
-------------------- | ------------------------------------
initialization       | Initialize environment <br>Read Packages, Functions.R <br>Set Working directory <br>Set Selection number (first 3 subject) and usubjid list
Traceability - update date | update data/source/ctdasrdf_graphmeta.csv to include current date/time
DM Processing        | Read and subset XPT file <br>Impute & Encode variables <br>Create dmDrugInt for cummulative Drug Administration<br>Save DM_subset.csv
EX Processing        | Read and subset XPT file <br>Impute & Encode variables <br>Merge dmDrugInt from DM for cummulative Drug Administration  <br>Save EX_subset.csv                       
VS Processing        | Read XPT file <br>Subset XPT file  <br>Impute & Encode variables <br>Save VS_subset.csv 

## Get Hands on Ontologies 

The core of the linked data is the Ontologies which define the links, object types and for this the structure of the data. To get a first overview, have a look into the corresponding documentation which is available:

* doc/Ontology Roadmap.docx - A short overview of available created/maintained ontology files
* doc/StudyOntologyUserGuide.docx - Detailed information about the study ontology which is the base for this project

### Browse Ontologies with Protege
Protege is an open source tool where you can develop and manage OWLs, so define the data structure and concept for the data linkage. It is used in this project by some members to create and maintain the OWL.

![Figure: Screenshot of Protege](./doc/images/protege_overview.PNG)

On the picture you see the study.ttl file. The left pane displays the class hierarchy. Everything is a subclass of "Thing". What ever is in bold, this is defined in the currently opened owl file (so in study.ttl). All other items come from other referenced owl files. What you can see in the screenshot is that "Enrolled subject" is a subclass from "Human study subject" which is a subclass from "Human subject" and so on. This class hierarchy does not dipslay other relationships, so to investigate the connections using Prot�g� is a bit difficult.

The relations you can see in the "Object properties" tab. In the "Description" window you see next to hierarchies also the "Domain" and "Range". The domain is the relationship-from and range is the relationship-to. When you checkout the "participates in" property which is a subclass of "has activity", you see that this comes from Person (domain, subject) and goes to Activity (range, object).

The following terminology is used for the triples

Subject      | Predicate       | Object
-------------| --------------- | ----------------
Domain       | Object Property | Range
Person       | participates in | Activity

If you follow the "Person" link, the person is displayed in the Classes tab. There is no indicator - neither in "Annotations" view nor in the "Description" view, that there is a relationship available.

To build an OWL using Prot�g� is the typical process. To figure out the structure when you have an available OWL is difficult with this tool. If you have any tips, please add them or let the the project members know, so they can add this.

### Browse Ontologies with WebVOWL
If you want to explore the ontologies (OWL) used, you might want to use the graphical display of the OWLs with the WebVOWL tool. The following links can be used to browse the ontologies through WebVOWL:

* [cd01p](http://visualdataweb.de/webvowl/#iri=http://w3id.org/phuse/cd01p#)
* [cdiscpilot01](http://visualdataweb.de/webvowl/#iri=<http://w3id.org/phuse/cdiscpilot01#)
* [code](http://visualdataweb.de/webvowl/#iri=<http://w3id.org/phuse/code#)
* [sdtm](http://visualdataweb.de/webvowl/#iri=http://w3id.org/phuse/sdtm#)
* [sdtmterm](http://visualdataweb.de/webvowl/#iri=http://w3id.org/phuse/sdtmterm#)
* [study](http://visualdataweb.de/webvowl/#iri=http://w3id.org/phuse/study#)

If you want more information on the Visualization with VOWL, you might read this paper where WebVOWL is explained very well: "[Visualizing Ontologies with VOWL](http://www.semantic-web-journal.net/system/files/swj1114.pdf)".

When you load for example the study.ttl file, you might get some warnings that not all ontologies can be loaded - ignore them. Then you see light blue and dark blue bubbles with relationshipts. The light blue ones are the one from the current ontology, so you might want to explore them first. You can see the most important classes from the study.ttl ontology at the first glance.

![Figure: Study.ttl Ontology - first glance](./doc/images/web_vowl_small.PNG)

You might wonder, why you miss quite some classes like the "Human Study Subject". This is because the tool filters classes out to allow an overview display of the ontologies. On the bottom "Filter" menue, you might want to remove the Degree collapsing and shift this to zero. Then you can see all the relationships and sub classes. This might be the starting point to look into one class of interest and figure out how this is connected to other things.

![Figure: Study.ttl Ontology - full glance](./doc/images/web_vowl_huge.PNG)

You can use the "Pick and Pin" option from the bottom "Mode" menu, to get a deeper view of classes and connections of interest. You might for example start with a "StudyActivity" where there is a "Study" which "hasStudyActivity" connected. And then there are "HumanStudySubjects" which participates in the study. The subgroup "EnrolledSubjects" has also an "Arm" connected which is also a "StudyActivity".

![Figure: Study.ttl Ontology - zoomed & pinned](./doc/images/web_vowl_zoomed.PNG)

These connections are the ontologies and does not display the actual data. So these things define the structure of the relationships and classes which are used in our project.

## View SMS (Stardog Mapping Syntax) TTL Files

Expected later

## Get Hands on triple store in Stardog

### Setup the Database
Make sure you installed Stardog and do not have any issues (like wrong Java version) including the correct setting of pathes. Then you can run the Stardog user web interface through <http://localhost:5820>. If you have not done so far, you need to create the CTDasRDFSMS database.

* Databases (top navigation)
* New DB
* Database name: CTDasRDFSMS
* Keep the rest as it is, and click Finish

### Load Data and Triples to Stardog Database
All required data is located in the data/source file folder:

* original XPT files
* converted and upated data content as CSV files
* Stardog Mapping Syntax TTL files
* StarDogUpload.bat file to upload data into Stardog

You might want to update StarDogUpload.bat, as the source location is defined as "C:\\_gitHub\\CTDasRDF\\data\\source" which you might want to change. Execute this .bat file to import
the data into the linked data graph database.

***Issues?*** If you get an error, make sure you have your stardog binary in the PATH location. If you cannot store
the path information permanently (administration options), you might want to include the following line in the beginning of the .bat file to set the path temporarily:

```
SET PATH=%PATH%;<path>\stardog-5.3.2\bin
```

***Additional Information:*** You can see in detail which files are imported together. To import DM, the following line is included in the file:

```
call stardog-admin virtual import CTDasRDFSMS DM_mappings.TTL DM_subset.csv
```

The import is done into the database called CTDasRDFSMS. It uses the DM_mappings.TTL as a template and filles the bracket parts multiple times with the corresponding observations from the DM_subset.csv file. By inspecting the *.TTL files you can have a closer look how the triples will be loaded.

Example - for each observation in the DM_subset.csv the studyid is linked to a "hasStudyParticipant" person.
```
# Study Partipants
cd01p:Study_{studyid}
  study:hasStudyParticipant cdiscpilot01:Person_{usubjid}
```

As everything is available after clone/download the repository, you could immediately import the data to stardog with the StarDogUpload.bat file without running an R scripts. Just make sure to exchange the location (right-click, edit) and have stardog running (stardog-admin.bat server start). 

If the import does not work and you want to see details, you might want to start the program in the windows console (cmd). 

* Open the console "cmd"
* Go to the path of the bat file, e.g. cd "C:\\_gitHub\\CTDasRDF\\data\\source"
* start the program by enter StarDogUpload.bat
* Check the log for hints

Your triples should be imported now into Stardog. You should be able to browse and send queries which you can do within the Stardog interface <http://localhost:5820/CTDasRDFSMS#!/schema> or other tools. 

### Browse & Query instance data in Stardog

When you have uploaded your data into Stardog, you can browse and query instance data. 

In the "Browse" area you see the different "Classes" and "Properties" and you can click along to see for example that there is a "AgeDataCollection" has three instances. You might want to check the one for usubjid = "01-701-1015" which is named "AgeDataCollection_01-701-1015". You can see different classes which are attached through properties. For example is the class "AgeOutcome_63" connected through the "outcome" property. And when clicking on this class you finally see that is "hasUnit" which is linked to the W3-Standard unitYear, a "hasValue" of 63 and also a "prefLabel" which is 63 YEARS.

You can  query results using the SPARQL language. If you want to see all links from a specific person instance, you can for example query the following:
```
SELECT ?p ?o
WHERE
{
    cdiscpilot01:Person_01-701-1015  ?p ?o .
} ORDER BY ?p ?o
```

To see all connections, simply use the following, but it might be wise to limit the results when you database is growing
```
SELECT ?s ?p ?o
WHERE
{
    ?s ?p ?o .
}
```

### Enhance Stardog Database

You might not like the long prefixes which are displayed on every query result. During triple creation also shortcuts has been used. To have a look what prefixes are used in this project, open the data/config/prefixes.csv file. Checkout which ones you would like to have available as shortcut in your database. You might for example select the following:

* cd01p=http://w3id.org/phuse/cd01p#
* cdiscpilot01=http://w3id.org/phuse/cdiscpilot01#
* code=http://w3id.org/phuse/code#
* sdtm=http://w3id.org/phuse/sdtm#
* sdtmterm=http://w3id.org/phuse/sdtmterm#
* study=http://w3id.org/phuse/study#
* custom=http://w3id.org/phuse/custom#

To include these shortcuts into your database, you need to update the database. Manage your stardog databases through the web interface <http://localhost:5820/#/databases> and select your "http://localhost:5820/#/databases" database. Turn the database "OFF" and "Edit". Now you are able to "Add namespace" as you like. Remember to "Save" and turn the database "ON".

Alternatively, you can set the namespaces from the commandline by pasting the following commands into the terminal:
```
stardog namespace add CTDasRDFSMS --prefix cd01p --uri http://w3id.org/phuse/cd01p#
stardog namespace add CTDasRDFSMS --prefix cdiscpilot01 --uri <http://w3id.org/phuse/cdiscpilot01#
stardog namespace add CTDasRDFSMS --prefix code --uri <http://w3id.org/phuse/code#
stardog namespace add CTDasRDFSMS --prefix sdtm --uri http://w3id.org/phuse/sdtm#
stardog namespace add CTDasRDFSMS --prefix sdtmterm --uri http://w3id.org/phuse/sdtmterm#
stardog namespace add CTDasRDFSMS --prefix study --uri http://w3id.org/phuse/study#
stardog namespace add CTDasRDFSMS --prefix custom --uri http://w3id.org/phuse/custom#
```

When you now perform any queries, you will see the namespace abbreviations nicely in the result:
```
SELECT *
WHERE {
	?s ?p ?o
} LIMIT 20
```

s (subject)               |	p (predicate)                 |	o (object)
------------------------- | ----------------------------- | -------------------------------
cdiscpilot01:stdm-graph	  | rdfs:label	                  | Clinical Trials data as an RDF graph.
cdiscpilot01:Date_2014-07-02	| skos:prefLabel |	2014-07-02
cdiscpilot01:Date_2014-07-02	| study:dateTimeInXSDString	| 2014-07-02
cdiscpilot01:Date_2014-07-02	| rdf:type	| study:CumulativeDrugAdministrationEnd
cdiscpilot01:Date_2014-07-02	| rdf:type	| study:ReferenceEnd
cdiscpilot01:DemographicDataCollection_01-701-1015	| study:hasSubActivity	| cdiscpilot01:EthnicityDataCollection_01-701-1015


## Get Hands on triple store outside Stardog

The main goal for having a triple store is to be able to develop and use tools which are powerful and performant to access and evaluate data. For this a triple store has been setup and filled and now can finally be accessed to create these tools. When you have your Stardog server running, you have a SPARQL endpoint which can be used by various programming languages including R, SAS, Java and nearly any other.

Within the described setup, the endpoint is running locally on your machine <http://localhost:5820/CTDasRDFSMS/query>. But you can also setup a triple store on a server. You could export the triples from Stardog and import this into another triple store available. Then the data would be accessable through the network.

### SPARQL and SAS

When you want to use SPARQL from SAS, there are ways to do so. You might want to check out the SPARQLwrapper which is located in Github by Marc J. Andersen: <https://github.com/MarcJAndersen/SAS-SPARQLwrapper>. 

Depending on your SAS environment you might not have access to the internet, in such cases you might expect issues.

### SPARQL and R

There is a R library called SPARQL where you can easily access an SPARQL endpoint like the one from localhost of stardog. You find an R program where you can run some SPARQL queries here:

* r/query/Stardog-SPARQL-examples.R

So you could read in the data in R and display this in any kind of format including a ShinyApp. The final programs are the ones that

=======
---
title: "Getting hands on CTDasRDF Project"
output: 
  html_document:
    toc: true
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Revision

Date         | Comment
------------ | ----------------------------
2018-08-23   | Documentation creation (KG)
2018-10-12   | Enhance documentation (KG)
2018-10-13   | Ontology viz and namespace cmds (NN)
2018-10-17   | Enhance WebVOWL and Prot�g� documentation (KG)

## Overview

To get start your hands on the project you can perform the following steps:

- Install software (R, RStudio, Stardog)
- Setup stardog (create database, start stardog)
- Then you can create the data in R via the scripts from the repository or skikp this as the data is also available
- Loading the data into stardog
- Now you are ready to explore either in Stardog or in R

![Figure: Screenshot to download .zip](./doc/images/compiled_overview.png)

## Installation Hints (Windows)

- Install R (https://cran.r-project.org/bin/windows/base/)
- Install RStudio (https://www.rstudio.com/products/rstudio/download/)
- Install Stardog (https://www.stardog.com/docs/)

You can install packages in R/RStudio easily through the install.packages("[name]") command.

### Working with Proxy in R / RStudio

You can use proxy settings for RStudio:  
- run file.edit('~/.Renviron') in RStudio console, include:	 
```
http_proxy=http://<proxy-adress>:<proxy-port>  
http_proxy_user=<Domain>%5C<ID>:<password>  
https_proxy=https://<proxy-adress>:<proxy-port>  
https_proxy_user=<Domain>%5C<ID>:<password>  
```
Be aware that the DEVTOOLS package does unluckily not work with an authentification proxy, but you can download the packages manually and install them through load_all("[path]"). For the R rrdf package you could do the following for example:
```
#1) If not behind a PROXY, use this simple way
install.packages("rJava") # if not present already
install.packages("devtools") # if not present already
library(devtools)
install_github("egonw/rrdf", subdir="rrdflibs")
install_github("egonw/rrdf", subdir="rrdf", build_vignettes = FALSE)
#2) If behind PROXY: download rrdf from github and unzip it into <path>
#https://github.com/egonw/rrdf
library(devtools)
load_all('C:/<path>/rrdflibs')
load_all('C:/<path>/rrdf')
library(rrdf)
```

### Stardog installation / execution hints

The windows installation is a bit complex like explained in their [documentation](https://www.stardog.com/docs/?utm_campaign=Stardog%3A%20Product%20Download&utm_source=hs_automation&utm_medium=email&utm_content=57254532&_hsenc=p2ANqtz-8zVpYrKT0H7p1ZHG_8vJD5zs7QE0-M7RhBS4K0DvJ1ar0XrbyTNlxmpgZf8b0gFG-s9Bt7V5BwBrlH9ROZt4rdhXKDyA&_hsmi=57254532#_quick_start_guide).  

Make sure you set the environment variables in your environment - in the console do for example (windows->"cmd"):
```
SET STARDOG_HOME=C:\Temp\Programs\stardog-5.3.2
SET PATH=%PATH%;C:\Temp\Programs\stardog-5.3.2\bin
```

Then you can start the server - in the console (windows->"cmd"):
```
stardog-admin.bat server start
```

Now you are hopefully ready to start the graphical user web interface through <http://localhost:5820>. The initial username and password might be "admin".  
  
  
**Issues with Java**:  
You might have issues with JAVA when stardog is not working. Make sure you have Java installed and it should be not 9 or 10 (so likely it will be 8). You can check the version in the console (windows -> "cmd"):
```
java -version
```
You could install multiple JAVA version on the PC. Make sure that when using Stardog, you have, e.g. the Java binaries from Java 8 in the PATH variable. You can investigate the content of %PATH% in the commando line through 
```
echo %PATH%
```
You could change the content to exclude the wrong JAVA binaries and include the JAVA 8 binaries through the SET PATH comment.

## Download Repository

The project files are available on Github <https://github.com/phuse-org/CTDasRDF> and are regularily updated. It is recommended to clone the repository and update this regularily with the git functionality easily. If you are not familar with git, you might want to just download the complete repository and unzip it a any location. Use the green button to "Clone or Download".

![Figure: Screenshot to download .zip](./doc/images/screen_download.png)

You can read the documentation in the github repository by clicking the *.rmd or *.md files. You might want to read the following documentations in the following order:
* CTDasRDF.rmd - project overview
* DataMappingAndConversion.md - content details
* HandsOnGuidance.rmd - guidance to get hands on experiences based on this project

## Get Hands on Data Preparation Programming (R)

Details on the general processes can be found in DataMappingAndConversion.md

* _im are derived or computed variables
* _en are encoded variables (special character replacement)

You can run the XPTtoCSV.R Program and run all lines together or single execute the commands and the included files to check what's going on. The XPT files are used as basis. Data processing took place which is needed for encoding and similar. Also some data is made up to have a better playground. Finally CSV files are created which are used to import to Stardog.

### XPTtoCSV

Creates the content CSV files which will be read together with the Stardoc SMS mapping to directly load the triples to the Stardoc triple store

Processing Step      | Description
-------------------- | ------------------------------------
initialization       | Initialize environment <br>Read Packages, Functions.R <br>Set Working directory <br>Set Selection number (first 3 subject) and usubjid list
Traceability - update date | update data/source/ctdasrdf_graphmeta.csv to include current date/time
DM Processing        | Read and subset XPT file <br>Impute & Encode variables <br>Create dmDrugInt for cummulative Drug Administration<br>Save DM_subset.csv
EX Processing        | Read and subset XPT file <br>Impute & Encode variables <br>Merge dmDrugInt from DM for cummulative Drug Administration  <br>Save EX_subset.csv                       
VS Processing        | Read XPT file <br>Subset XPT file  <br>Impute & Encode variables <br>Save VS_subset.csv 

## Get Hands on Ontologies 

The core of the linked data is the Ontologies which define the links, object types and for this the structure of the data. To get a first overview, have a look into the corresponding documentation which is available:

* doc/Ontology Roadmap.docx - A short overview of available created/maintained ontology files
* doc/StudyOntologyUserGuide.docx - Detailed information about the study ontology which is the base for this project

### Browse Ontologies with Prot�g�
Prot�g� is an open source tool where you can develop and manage OWLs, so define the data structure and concept for the data linkage. It is used in this project by some members to create and maintain the OWL.

![Figure: Screenshot of Prot�g�](./doc/images/protege_overview.PNG)

On the picture you see the study.ttl file. The left pane displays the class hierarchy. Everything is a subclass of "Thing". What ever is in bold, this is defined in the currently opened owl file (so in study.ttl). All other items come from other referenced owl files. What you can see in the screenshot is that "Enrolled subject" is a subclass from "Human study subject" which is a subclass from "Human subject" and so on. This class hierarchy does not dipslay other relationships, so to investigate the connections using Prot�g� is a bit difficult.

The relations you can see in the "Object properties" tab. In the "Description" window you see next to hierarchies also the "Domain" and "Range". The domain is the relationship-from and range is the relationship-to. When you checkout the "participates in" property which is a subclass of "has activity", you see that this comes from Person (domain, subject) and goes to Activity (range, object).

The following terminology is used for the triples

Subject      | Predicate       | Object
-------------| --------------- | ----------------
Domain       | Object Property | Range
Person       | participates in | Activity

If you follow the "Person" link, the person is displayed in the Classes tab. There is no indicator - neither in "Annotations" view nor in the "Description" view, that there is a relationship available.

To build an OWL using Prot�g� is the typical process. To figure out the structure when you have an available OWL is difficult with this tool. If you have any tips, please add them or let the the project members know, so they can add this.

### Browse Ontologies with WebVOWL
If you want to explore the ontologies (OWL) used, you might want to use the graphical display of the OWLs with the WebVOWL tool. The following links can be used to browse the ontologies through WebVOWL:

* [cd01p](http://visualdataweb.de/webvowl/#iri=https://w3id.org/phuse/cd01p#)
* [cdiscpilot01](http://visualdataweb.de/webvowl/#iri=<https://w3id.org/phuse/cdiscpilot01#)
* [code](http://visualdataweb.de/webvowl/#iri=<https://w3id.org/phuse/code#)
* [sdtm](http://visualdataweb.de/webvowl/#iri=https://w3id.org/phuse/sdtm#)
* [sdtmterm](http://visualdataweb.de/webvowl/#iri=https://w3id.org/phuse/sdtmterm#)
* [study](http://visualdataweb.de/webvowl/#iri=https://w3id.org/phuse/study#)

If you want more information on the Visualization with VOWL, you might read this paper where WebVOWL is explained very well: "[Visualizing Ontologies with VOWL](http://www.semantic-web-journal.net/system/files/swj1114.pdf)".

When you load for example the study.ttl file, you might get some warnings that not all ontologies can be loaded - ignore them. Then you see light blue and dark blue bubbles with relationshipts. The light blue ones are the one from the current ontology, so you might want to explore them first. You can see the most important classes from the study.ttl ontology at the first glance.

![Figure: Study.ttl Ontology - first glance](./doc/images/web_vowl_small.PNG)

You might wonder, why you miss quite some classes like the "Human Study Subject". This is because the tool filters classes out to allow an overview display of the ontologies. On the bottom "Filter" menue, you might want to remove the Degree collapsing and shift this to zero. Then you can see all the relationships and sub classes. This might be the starting point to look into one class of interest and figure out how this is connected to other things.

![Figure: Study.ttl Ontology - full glance](./doc/images/web_vowl_huge.PNG)

You can use the "Pick and Pin" option from the bottom "Mode" menu, to get a deeper view of classes and connections of interest. You might for example start with a "StudyActivity" where there is a "Study" which "hasStudyActivity" connected. And then there are "HumanStudySubjects" which participates in the study. The subgroup "EnrolledSubjects" has also an "Arm" connected which is also a "StudyActivity".

![Figure: Study.ttl Ontology - zoomed & pinned](./doc/images/web_vowl_zoomed.PNG)

These connections are the ontologies and does not display the actual data. So these things define the structure of the relationships and classes which are used in our project.

## View SMS (Stardog Mapping Syntax) TTL Files

Expected later

## Get Hands on triple store in Stardog

### Setup the Database
Make sure you installed Stardog and do not have any issues (like wrong Java version) including the correct setting of pathes. Then you can run the Stardog user web interface through <http://localhost:5820>. If you have not done so far, you need to create the CTDasRDFSMS database.

* Databases (top navigation)
* New DB
* Database name: CTDasRDFSMS
* Keep the rest as it is, and click Finish

### Load Data and Triples to Stardog Database
All you required data is located in the data/source file folder:

* original XPT files
* converted and upated data content as CSV files
* Stardog Mapping Syntax TTL files
* StarDogUpload.bat file to upload data into Stardog

You might want to update StarDogUpload.bat, as the source location is defined as "C:\\_gitHub\\CTDasRDF\\data\\source" which you might want to change. You can see in detail which files are imported together. To import DM, the following line is included in the file:

```
call stardog-admin virtual import CTDasRDFSMS DM_mappings.TTL DM_subset.csv
```

The import is done into the database called CTDasRDFSMS. It uses the DM_mappings.TTL as a template and filles the bracket parts multiple times with the corresponding observations from the DM_subset.csv file. By inspecting the *.TTL files you can have a closer look how the triples will be loaded.

Example - for each observation in the DM_subset.csv the studyid is linked to a "hasStudyParticipant" person.
```
# Study Partipants
cd01p:Study_{studyid}
  study:hasStudyParticipant cdiscpilot01:Person_{usubjid}
```

As everything is available after clone/download the repository, you could immediately import the data to stardog with the StarDogUpload.bat file without running an R scripts. Just make sure to exchange the location (right-click, edit) and have stardog running (stardog-admin.bat server start). 

If the import does not work and you want to see details, you might want to start the program in the windows console (cmd). 

* Open the console "cmd"
* Go to the path of the bat file, e.g. cd "C:\\_gitHub\\CTDasRDF\\data\\source"
* start the program by enter StarDogUpload.bat
* Check the log for hints

Your triples should be imported now into Stardog. You should be able to browse and send queries which you can do within the Stardog interface <http://localhost:5820/CTDasRDFSMS#!/schema> or other tools. 

### Browse & Query instance data in Stardog

When you have uploaded your data into Stardog, you can browse and query instance data. 

In the "Browse" area you see the different "Classes" and "Properties" and you can click along to see for example that there is a "AgeDataCollection" has three instances. You might want to check the one for usubjid = "01-701-1015" which is named "AgeDataCollection_01-701-1015". You can see different classes which are attached through properties. For example is the class "AgeOutcome_63" connected through the "outcome" property. And when clicking on this class you finally see that is "hasUnit" which is linked to the W3-Standard unitYear, a "hasValue" of 63 and also a "prefLabel" which is 63 YEARS.

You can  query results using the SPARQL language. If you want to see all links from a specific person instance, you can for example query the following:
```
SELECT ?p ?o
WHERE
{
    cdiscpilot01:Person_01-701-1015  ?p ?o .
} ORDER BY ?p ?o
```

To see all connections, simply use the following, but it might be wise to limit the results when you database is growing
```
SELECT ?s ?p ?o
WHERE
{
    ?s ?p ?o .
}
```

### Enhance Stardog Database

You might not like the long prefixes which are displayed on every query result. During triple creation also shortcuts has been used. To have a look what prefixes are used in this project, open the data/config/prefixes.csv file. Checkout which ones you would like to have available as shortcut in your database. You might for example select the following:

* cd01p=https://w3id.org/phuse/cd01p#
* cdiscpilot01=<https://w3id.org/phuse/cdiscpilot01#
* code=<https://w3id.org/phuse/code#
* sdtm=https://w3id.org/phuse/sdtm#
* sdtmterm=https://w3id.org/phuse/sdtmterm#
* study=https://w3id.org/phuse/study#

To include these shortcuts into your database, you need to update the database. Manage your stardog databases through the web interface <http://localhost:5820/#/databases> and select your "http://localhost:5820/#/databases" database. Turn the database "OFF" and "Edit". Now you are able to "Add namespace" as you like. Remember to "Save" and turn the database "ON".

Alternatively, you can set the namespaces from the commandline by pasting the following commands into the terminal:
```
stardog namespace add CTDasRDFSMS --prefix cd01p --uri https://w3id.org/phuse/cd01p#
stardog namespace add CTDasRDFSMS --prefix cdiscpilot01 --uri <https://w3id.org/phuse/cdiscpilot01#
stardog namespace add CTDasRDFSMS --prefix code --uri <https://w3id.org/phuse/code#
stardog namespace add CTDasRDFSMS --prefix sdtm --uri https://w3id.org/phuse/sdtm#
stardog namespace add CTDasRDFSMS --prefix sdtmterm --uri https://w3id.org/phuse/sdtmterm#
stardog namespace add CTDasRDFSMS --prefix study --uri https://w3id.org/phuse/study#
```

When you now perform any queries, you will see the namespace abbreviations nicely in the result:
```
SELECT *
WHERE {
	?s ?p ?o
} LIMIT 20
```

s (subject)               |	p (predicate)                 |	o (object)
------------------------- | ----------------------------- | -------------------------------
cdiscpilot01:stdm-graph	  | rdfs:label	                  | Clinical Trials data as an RDF graph.
cdiscpilot01:Date_2014-07-02	| skos:prefLabel |	2014-07-02
cdiscpilot01:Date_2014-07-02	| study:dateTimeInXSDString	| 2014-07-02
cdiscpilot01:Date_2014-07-02	| rdf:type	| study:CumulativeDrugAdministrationEnd
cdiscpilot01:Date_2014-07-02	| rdf:type	| study:ReferenceEnd
cdiscpilot01:DemographicDataCollection_01-701-1015	| study:hasSubActivity	| cdiscpilot01:EthnicityDataCollection_01-701-1015


## Get Hands on triple store outside Stardog

The main goal for having a triple store is to be able to develop and use tools which are powerful and performant to access and evaluate data. For this a triple store has been setup and filled and now can finally be accessed to create these tools. When you have your Stardog server running, you have a SPARQL endpoint which can be used by various programming languages including R, SAS, Java and nearly any other.

Within the described setup, the endpoint is running locally on your machine <http://localhost:5820/CTDasRDFSMS/query>. But you can also setup a triple store on a server. You could export the triples from Stardog and import this into another triple store available. Then the data would be accessable through the network.

### SPARQL and SAS

When you want to use SPARQL from SAS, there are ways to do so. You might want to check out the SPARQLwrapper which is located in Github by Marc J. Andersen: <https://github.com/MarcJAndersen/SAS-SPARQLwrapper>. 

Depending on your SAS environment you might not have access to the internet, in such cases you might expect issues.

### SPARQL and R

There is a R library called SPARQL where you can easily access an SPARQL endpoint like the one from localhost of stardog. You find an R program where you can run some SPARQL queries here:

* r/query/Stardog-SPARQL-examples.R

So you could read in the data in R and display this in any kind of format including a ShinyApp. The final programs are the ones that

>>>>>>> Stashed changes:HandsOnCTDasRDF.rmd
