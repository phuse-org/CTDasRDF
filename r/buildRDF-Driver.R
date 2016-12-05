###############################################################################
# $HeadURL: file:///C:/SVNLocalRepos/PhUSE/Projects/SDTM2RDF/r/buildRDF-Driver.R $
# $Rev: 86 $
# $Date: 2016-12-05 10:31:14 -0500 (Mon, 05 Dec 2016) $
# $Author: U041939 $
# -----------------------------------------------------------------------------
# DSCR : Master program for building the TTL file for the DM domain from 
#            the CDISCPILOT01 example data.
# SRC  : Code:Adapted from approach used in KMD project, TreatFlow Projects.
#      : Data Source: https://github.com/phuse-org/phuse-scripts/blob/master/data/sdtm/
# NOTES: Validation of the resulting TTL file with Apache Jenna riot
#         Coded values cannot have spaces or special characters.
# IN  :   prefixes.csv - prefixes and their namespaces
#         dmSub.csv  - Subset of the CSV data source file.
# OUT : data/rdf/DM.TTL
# REQ : Apache Jena 3.0.1: For riot, installed and avail at system path if 
#           valdiation called
# TODO: ARM codes to include URI's to graphs that contain descriptions of the arm
#
###############################################################################
library(rrdf)
library(Hmisc)
library(car)   # Recoding of values

# Set working directory to the root of the work area
setwd("C:/_github/SDTM2RDF")

sourcePrefix<-"data/prefixesCSV.csv"  # List of prefixes for the resulting TTL file
sourceData<-"data/source/dmSub.csv"  # Subset of DM data for development purposes.
sourceData<-head(sourceData,1)       #DEV - Keep only first row for development purposes.
sourceCodelist<-"data/source/codelist.csv"  # Codelist triples 
outFile='data/rdf/DM.TTL'

# Bring in the data source. Will be used in codeLists.R and triples.R
masterData <- read.csv(sourceData,
                       header=T,
                       sep=',')

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

#-- Codelist creation
source('R/codelistsCSV.R')

#-- Data triples creation
source('R/triples.R')

##########
# Output #
###############################################################################
store = save.rdf(store, filename=outFile, format="TURTLE")

# Validate TTL file.
#system(paste('riot --validate ', outFile),
#             show.output.on.console = TRUE)