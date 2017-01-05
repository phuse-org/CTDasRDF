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

# Configuration: List of prefixes
sourcePrefix<-"data/config/prefixes.csv"  # List of prefixes for the resulting TTL file

# Output file
outFilename = "cdiscpilot01.TTL"
outFile=paste0("data/rdf/", outFilename)


#------------------------------------------------------------------------------
# FNT: readXPT
#      Read the requested domains into dataframes for processing.
# TODO: Consider placing in separate Import.R script called by this driver.
readXPT<-function(domains)
{
    resultList <- vector("list", length(domains)) # initialize vector to hold dataframes
    for (i in seq(1, length(domains))) {
        sourceFile <- paste0("data/source/", domains[i], ".XPT")
        # resultList[[i]]<-sasxport.get(sourceFile)
        # Each domain assembled into resultList by name "dm", "vs" etc.
        resultList[[domains[i]]]<-sasxport.get(sourceFile)
    }
    resultList # return the dataframes from the function
    #TODO Merge the multiple SDTM Domains into a single Master dataframe.
}


# Access individual dataframes based on name:  domainsDF["vs"], etc.
domainsDF<-readXPT(c("dm", "vs")) 

# Consider the utility of having the domain prefix (dm.usubjid, vs.usubjid) vs. stripping it as done here.
# No name overlap due to SDTM naming conventions that add vs to vsdtc, dm to dmdtc, etc.
# If keeping, make it a function to process the list of domains.
dm <- data.frame(domainsDF["dm"])
names(dm) <- gsub( "^dm.",  "", names(dm), perl = TRUE)
dm <- dm[, !(names(dm) %in% c("domain"))]  # drop unnecessary columns

# vs domain
vs <- data.frame(domainsDF["vs"])
names(vs) <- gsub( "^vs.",  "", names(vs), perl = TRUE)
vs <- vs[, !(names(vs) %in% c("studyid", "domain"))]  # drop unnecessary columns

# For testing, keep only the first 6 patients in DM
dm <- head(dm, 6)

# Merge dm with vs, keeping on the data for the DM testing subset
# merge two data frames by ID and Country
test <- merge(dm, vs, by=c("usubjid"))



# Rename as masterData, the proceed with processing.
#-------------------------------------------------



masterData <- head(masterData, 6) # subset for testing. CHange to later keep only first 6 patients by patient ID




## DEVELOPMENT ABOVE HERE! 




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