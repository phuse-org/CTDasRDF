
install.packages("DiagrammeR")
install.packages("reshape")
install.packages("collapsibleTree")

install.packages("rJava") # if not present already
install.packages("devtools") # if not present already

# devtools usage does unluckily not work as proxys are not supported
library(devtools)
install_github("egonw/rrdf", subdir="rrdflibs")
install_github("egonw/rrdf", subdir="rrdf", build_vignettes = FALSE)
install_github("rrdf", "egonw", subdir="rrdf", build_vignettes = FALSE)


#1) download rrdf from github
#https://github.com/egonw/rrdf
library(devtools)
load_all('C:/Users/sgqyq.AD-BAYER-CNB/Downloads/rrdf-master/rrdflibs')
load_all('C:/Users/sgqyq.AD-BAYER-CNB/Downloads/rrdf-master/rrdf')
load_all('C:/Users/sgqyq/Downloads/rrdf-master/rrdflibs')
load_all('C:/Users/sgqyq/Downloads/rrdf-master/rrdf')
library(rrdf)


install.packages("testthat")
load_all('C:/Users/sgqyq/Downloads/rrdf-master/rrdflibs')
load_all('C:/Users/sgqyq/Downloads/rrdf-master/rrdf')


#install.packages("redland")
#install.packages("stringr")
#install.packages("plyr")
#install.packages("jsonlite")
install.packages("reshape")
install.packages("visNetwork")



library(rrdflib)
install.packages('C:/Users/sgqyq/Downloads/rrdf-master/rrdf.zip',repos = NULL)
install.packages('C:/Users/sgqyq/Downloads/rrdf-master/rrdflibs.zip',repos = NULL)
install.packages('C:/Users/sgqyq/Downloads/rrdf-master/rrdf_2.0.2.tar.gz',repos = NULL)


installed.packages()
#C:\Program Files\Java\jre1.8.0_181\bin
Sys.getenv("JAVA_HOME") 
#Sys.setenv(JAVA_HOME='/jdk1.8.0_60/') 
#Sys.setenv(JAVA_HOME='C:/Program Files/Java/jre1.8.0_181/bin;C:/Program Files/Java/jre1.8.0_181/bin/server') 
#Sys.getenv("PATH") 
Sys.setenv(JAVA_HOME="") 

library(rJava)
.jinit('.')
s <- .jnew('java/lang/String', 'Hello World!')
.jcall(s, 'I', 'length')
print(s)

print(.jclassPath())

library(devtools)
load_all('C:/Users/sgqyq/Downloads/rrdf-master/rrdflibs')
load_all('C:/Users/sgqyq/Downloads/rrdf-master/rrdf')


.jinit();.jcall("java/lang/System", "S", "getProperty", "java.runtime.version")


# Install package
install.packages(pkgs="C:/Users/sgqyq/Downloads/rrdflibs_1.3.0.tar.gz", type="source", repos=NULL)
install.packages(pkgs="H:/My Documents/#RProgramming/documents/rrdf_1.9.2.tar.gz", type="source", repos=NULL)


install.packages("Hmisc")
install.packages("car")



# not needed for project, but otherwise needed
install.packages("psych")
install.packages("data.tree")
install.packages("DiagrammeR")
install.packages("gridExtra")

install.packages("SASxport")



setwd("H:/My Documents/#RProgramming/CTDasRDF-master")
