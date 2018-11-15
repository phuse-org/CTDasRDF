Folder Structure
----------------

Project folder structure and content.

-   **/SPARQL**
    -   SPARQL scripts for working with the data in the triplestore. All scripts must contain a comment header describing their function and  should indicate SPARQL extensions specific to Stardog whenever used. Files like MiscQueries.rq contain multiple independent scripts.  

### Data

-   **/data/rdf**
    -   CDISC TTL/RDF source files
    -   Project ontology TTL files
    -   External ontology files (eg: time.ttl)
-   **/data/SAS**
    -   CSV Files created by SAS from source XPT files. Alternative to the R process.
-   **/data/source**
    -   Source XPT file for data conversion
    -   CSV files created by R from source XPT files. Also contains graph metadata CSV file created by R.
    -   Stardog SMS Map files that map their corresponding CSV files to the triplestore.
    -   .BAT files that drive the SMS to triplestore process
-   **/data/source/updated\_cdiscpilot**
    -   SDTM files updated to version 3.2 by the PhUSE data generation team.
    -   Copy individual flies into the parent /source when ready to start developing conversion of that file.
-   **/data/source/define content**
    -   Files related to DEFINE.

### Documentation

-   **/doc**
    -   Project documentation. Primary Github markdown.
-   **/doc/Pubs**
    -   Project Publications, with subfolders for various conferences and the Project White Paper \[not yet available 2018-10-25\]
-   **/doc/StudyDocs**
    -   Documents from the orginal study. Currently only contains the protocol as PDF.
-   **/doc/images**
    -   Images to be included in the project documentation, including the Github Markdown files.

### R

-   **/r/conversion-gRaveyaRd**
-   **/r/query**
    -   R scripts that query the triplestore.
-   **/r/utility**
    -   Utility/Example scripts. E.g.: Read XPT from R.
-   **/r/validation**
    -   Validate instance data between SMS conversion approach and instance data from ontology development.
    -   Not all scripts up to date
    -   /www folder for RShiny validation apps.
-   **/r/vis**
    -   Visualization scripts and RShiny apps.
    -   RShiny apps in subfolders named with "-app"
    -   /archive - Coode from previous work that is outdated/nonfunctional. May serve as a reference for future work before deletion.
    -   /doc - documentation that supports the R packages used to create visualization. Eg: visNetwork.
-   **/r/vis/support**
    -   Supports the development process. Eg: TS mapping

### SAS

-   **/sas**
    -   SAS scripts with function corresponding to those in /r

### Other

-   **/vis**
    -   Old visualization code using D3JS. Includes /d3 for D3 library. Also includes R scripts in /r that should be moved to /r/vis or deleted.
    -   **TODO:** Update/Delete this structure.

[Back to TOC](TableOfContent.md)
