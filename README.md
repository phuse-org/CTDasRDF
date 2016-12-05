# SDTM2RDF
This repository holds the scripts and data for the PhUSE project "SDTM Data to RDF."  This file will be updated as the project progresses.

# Installation
## The Download Method
Ensure you are on the DEV branch (https://github.com/NovasTaylor/SDTM2RDF/tree/DEV)
Click "Clone or Download" and select "Download Zip"
Extract the file to a location like  C:\_github
This will create the folder C:\_github\SDTM2RDF-DEV and subfolders.
Edit the file \r\buildRDF-Driver.R  to change have set setwd() point to the path where you installed the file.
      setwd("C:/_github/SDTM2RDF-DEV")

Ensure you have all the required R packages installed. Currently this includes:
library(rrdf)
library(Hmisc)
library(car)

Note on installing rrdf from github:
  install.packages("rJava") # if not present already
  install.packages("devtools") # if not present already
  library(devtools)

The following two steps may be needed on some systems: 
  library(httr)
  set_config(config(ssl_verifypeer = 0L))

Then: 
  install_github("egonw/rrdf", subdir="rrdflibs")
  install_github("egonw/rrdf", subdir="rrdf", build_vignettes = FALSE)

Now run \r\buildRDF-Driver.R  to recreate the file:  \data\rdf\DM.TTL
