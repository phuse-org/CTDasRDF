# CTDasRDF define.xml generator

This define.xml generator written by groovy script. To running it, it is necessary to install groovy script engine.
Groovy script engine is distributed on [groovy website](http://groovy-lang.org/download.html "groovy website")  

## Preparing Sparql Endpoint
This define.xml generator retrieves metadata from Sparql Endpoint through Sparql query. Therefore the Sparql Endpoint have to include following RDFs.
* sdtm-1-3.ttl  
* sdtmig-3-1-3.ttl  
* study.ttl  
* cdiscpilot01-protocol.ttl  
* meta-model-schema.rdf  
* ct-schema.rdf  
* sdtm-terminology.rdf  

## Execute to generate define.xml
Change directory to "CTDasRDF/Define-XML", and type "groovy genDefineXML.groovy"  
define.xml is generated into same directory.  


## Note
This tool is under developing, it is not enough as validated define.xml.
