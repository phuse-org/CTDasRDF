###############################################################################
# Name : buildRDF-Driver.R
# AUTH : Tim W. 
# DSCR : Master program for building the TTL file for the DM domain from 
#            the CDISCPILOT01 example data.
# NOTES: Validation of the resulting TTL file with Apache Jenna riot
#         Coded values cannot have spaces or special characters.
# IN  :   prefixes.csv - prefixes and their namespaces
#         dmSub.csv  - Subset of the CSV data source file.
# OUT : data/rdf/cdiscpilot01.TTL
# REQ : Apache Jena 3.0.1: For riot, installed and avail at system path if 
#           valdiation called
# TODO: ARM codes to include URI's to graphs that contain descriptions of the arm
#       SDTM terminology codes in triples.R currently hard coded. Move to a query
#           within a new fnt().
#
###############################################################################
library(rrdf)
library(Hmisc)
library(car)   # Recoding of values for SDTM codes, etc.


# Version
#    Used to identify the version of the code and data. Is part of the TTL
#    metadata
version <- "0.0.1"

# Set working directory to the root of the work area
setwd("C:/_github/SDTM2RDF")


sourcePrefix<-"data/config/prefixes.csv"  # List of prefixes for the resulting TTL file
inFilename <- "dm.xpt"
sourceData<-paste0("data/source/", inFilename)  # Subset of DM data for development purposes.
sourceData<-head(sourceData,1)       #DEV - Keep only first row for development purposes.
# sourceCodelist<-"data/config/codelist.csv"  # Codelist triples 
outFilename = "cdiscpilot01.TTL"
outFile=paste0("data/rdf/", outFilename)


# Bring in the data source. Will be used in codeLists.R and triples.R
#masterData <- read.csv(sourceData,
#                       header=T,
#                       sep=',')
masterData <- sasxport.get(sourceData)
masterData <- head(masterData, 6)   # Subset for testing purposes

#-- Massage the data as needed prior to building codelists and processing.
#   Add data where needed for proof of concept. Clean data, etc.
source('R/dataMassage.R')


# Initialize. Includes OWL, XSD, RDF by default.
store = new.rdf()  

#-- Build the Prefixes from the CSV file
prefixes <- as.data.frame( read.csv(sourcePrefix,
                                    header=T,
                                    sep=',' ,
                                    strip.white=TRUE))
for (i in 1:nrow(prefixes)) {
    add.prefix(store,
        prefix=as.character(prefixes[i,"prefix"]),
        namespace=as.character(prefixes[i, "namespace"])
    )
    # Create uppercase prefix names for use in add() in triples.R
    assign(paste0("prefix.",toupper(prefixes[i, "prefix"])), prefixes[i, "namespace"])
}

source('R/singleResources.R')


#-- Data triples creation
source('R/triples.R')

##########
# Output #
###############################################################################
store = save.rdf(store, filename=outFile, format="TURTLE")

# Validate TTL file.Always good to validate, friendo.
system(paste('riot --validate ', outFile),
    show.output.on.console = TRUE)