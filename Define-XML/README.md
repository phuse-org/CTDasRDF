# CTDasRDF define.xml generator

## Install Groovy Script engine
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
Following listed files located under CTDasRDF/data/rdf directory are utilized by genDefineXML.groovy that directory read these files, thus any sparql endpoint is not needed.
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


## Execute to generate define.xml
Change directory to "CTDasRDF/Define-XML", and type "groovy genDefineXML.groovy"  
define.xml is generated into same directory.  


## Note
This tool is under developing, it is not enough as validated define.xml.
