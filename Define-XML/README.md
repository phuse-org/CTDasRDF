# CTDasRDF define.xml generator

## Install Groovy Script Engine
This define.xml generator written in groovy language. To running this groovy script, it is necessary to install groovy script engine. [Official install document](http://groovy-lang.org/install.html "Install Document") is very helpful your installation work.   
Groovy script engine is distributed on [groovy website](http://groovy-lang.org/download.html "groovy website")  

## Directory Structure of CTDasRDF

```
├── Define-XML  
│    ├── template                               >>> including template files related sparql query and define.xml
│    │    ├── datasetMetadata.sparql.template   >>> sparql query for retrieving dataset level metadata
│    │    ├── define.xml.template               >>> define.xml template file
│    │    ├── prefixes.sparql.template          >>> rdf namespace prefixes
│    │    ├── studyMetadata.sparql.template     >>> sparql query for retrieving study level metadata
│    │    └── variableMetadata.sparql.template  >>> sparql query for retrieving variable level metadata
│    ├── README.md                              >>> this document
│    ├── define.xml                             >>> generated example define.xml
│    ├── define2-0-0.xsl                        >>> xml style sheet for define.xml v2.0
│    └── genDefineXML.groovy                    >>> groovy script generating define.xml
├── SPARQL  
├── data
│   ├── rdf
│   │   ├── CDISC
│   │   ├── DMFirstTriples.ttl
│   │   ├── catalog-v001.xml
│   │   ├── cdisc-schema.rdf
│   │   ├── cdiscpilot01-R.TTL
│   │   ├── cdiscpilot01-SMS.ttl
│   │   ├── cdiscpilot01-protocol.ttl
│   │   ├── cdiscpilot01.ttl
│   │   ├── code.ttl
│   │   ├── ct-schema.rdf
│   │   ├── meta-model-schema.rdf
│   │   ├── sdtm-1-3.ttl
│   │   ├── sdtm-cd01p.ttl
│   │   ├── sdtm-cdisc01.ttl
│   │   ├── sdtm-terminology.rdf
│   │   ├── sdtm.ttl
│   │   ├── sdtmig-3-1-3.ttl
│   │   ├── study.ttl
│   │   └── time.ttl
│   ├── sas
│   └── source
├── doc
├── r
├── sas
├── vis
├── LICENSE
├── README.md
└── directory.txt
```
Following listed files located under CTDasRDF/data/rdf directory are utilized by genDefineXML.groovy. GenDefineXML.groovy read these files, thus any sparql endpoint is not needed.
* cdisc-schema.rdf  
* cdiscpilot01-R.TTL
* cdiscpilot01-protocol.ttl
* cdiscpilot01.ttl
* code.ttl
* ct-schema.rdf
* meta-model-schema.rdf
* sdtm-1-3.ttl
* sdtm-cd01p.ttl
* sdtm-cdisc01.ttl
* sdtm-terminology.rdf
* sdtm.ttl
* sdtmig-3-1-3.ttl
* study.ttl
* time.ttl

## Template files
Template files are located under CTDasRDF/Define-XML/template and including two types template that are template of define.xml and sparql query.
Define.xml.template is the template file of define.xml.
And other template files are sparql query template.

## Groovy Script
GenDefineXML.groovy is the groovy script for generating define.xml. This script is defined as class and last 2 lenes in this script execute the instantiation and to call the method for generating define.xml.
```
define_generator = new genDefineXMLFile(["DM", "SUPPDM", "VS"])
define_generator.genDefineXML()
```




## Execute to generate define.xml
To run this tool, change directory to "CTDasRDF/Define-XML", and type "groovy genDefineXML.groovy" in your shell interface.   
Define.xml is generated into same directory in few seconds.  


## Limitation
The goal of this tool is proof of concept (POC) implementation that define.xml is generated from CTDasRDF via sparql query. Therefore, it is not recommended to utilize creating any deliverables for data submission to the regulatory agency.
This POC implementation can not generate value level metadata and codelist metadata, and include into a define.xml file. These are future work.
