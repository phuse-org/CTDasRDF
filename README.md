# SDTM2RDF
This repository holds the scripts and data for the PhUSE project "SDTM Data to RDF." All work is very early draft, contains errors, problems with the model, etc. 

See the Project Wiki https://github.com/phuse-org/SDTMasRDF/wiki  for detailed descriptions of the project components.

# Installation
## The Download Method
Click "Clone or Download" and select "Download Zip"
Extract the file to a location like  C:\\_github
This will create the folder C:\\_github\\SDTM2RDF-MASTER and subfolders.
Edit the file \\r\\buildRDF-Driver.R  to change have set setwd() point to the path where you installed the file.
 ```
 setwd("C:/_github/SDTM2RDF-MASTER")
```
Ensure you have all the required R packages installed. Currently this includes:
```
library(rrdf)
library(Hmisc)
library(car)
```
Now run \r\buildRDF-Driver.R  to recreate the file:  \data\rdf\DM.TTL

See the Wiki page https://github.com/phuse-org/SDTMasRDF/wiki/R-Scripts for how to install the required R package 'rrdf' which is not part of CRAN. 

