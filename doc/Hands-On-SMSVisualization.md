# Introduction
SMS files are used to map from the CSV data sources to the Stardog triplestore.
A map file exists for each SDTM domain file, with additional files for the 
Investigator and graph metadata. A visual representation of the maps is vital 
in the design phase to ensure correct mapping and it also aids 
query construction for the triplestore. 

# Running the App

## Preparation and Configuration
The app is run using R on your local machine. Install the following software 
as needed:

1. R
2. RStudio 

RShiny Installation:

  i. Start RStudio. 
  ii. In the RStudio Console:
  
    `install.packages("shiny")`
    
  iii. Install packages required by the app. Run this command in the RStudio Console:

    `install.packages(c("stringr", "visNetwork", "reshape", "dplyr", "DT"))`

## App Files
Clone/download the CTDasRDF repository if not already present on your local drive. 
If you previously cloned the repository, execute a `git pull` to ensure you have the
latest version of the files.

The app files are located here:
/CTDasRDF/r/vis/SMSMapVis-app

## Run the App
1. Load any one of these files into RStudio:  global.r, server.r, ui.r
2. Run the app using the "Run App" button in RStudio
3. The graph is quite large, so maximize the screen or select "Open in Browser". 
Chrome is the preferred browser.


# Notes
The source TTL files are located in the folder CTDasRDF/data/source. Their names
are hard-coded into the app so the code must be changed when new file are added 
to the project.

All map files are selected at the start. De-select map files using the checkboxes.
Exclude namespaces using the checkboxes.
Select Nodes using your mouse or the drop-down box in the upper left.
View the triples, nodes, edges using the tabs at the top of the app.


