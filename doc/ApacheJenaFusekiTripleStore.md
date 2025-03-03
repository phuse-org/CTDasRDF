# Local Environment - Apache Jena Fuseki Triple Store

[Go to TOC](TableOfContents.md)

| Date       | Comment       |
| ---------- | ------------- |
| 2019-06-03 | Creation (KG) |


## Background

The project is using Stardog as triple store, which had been available as community version for non-commercial purposes for free. The community version is no longer available. For this alternatives should be provided.

[Apache Jena](https://jena.apache.org/) is a free open source framework for building linked data applications and use this as store. It is easy to setup and use.

## Prerequisite

Only JAVA is required to be installed on the machine. You can check whether JAVA is installed and available in the PATH by using the collowing command (Windows -> enter "CMD" -> press enter -> enter "java --version" in the console -> press enter).

```
java --version
```

## Download and Start Server

* Download "Apache Jena Fuseki" from the [Server](https://jena.apache.org/download/) (e.g. apache-jena-fuseki-3.11.0.zip)
* Unzip file, e.g. in C:\Temp\Programs
* Start the Server
  * Open the command line (Windows -> enter "CMD" -> enter)
  * Change to the unzip directory (cd C:\Temp\Programs\apache-jena-fuseki-3.11.0 -> enter)
  * Start the server (fuseki-server -> enter)
* Open your browser (e.g. Firefox, Chrome)
  * http://localhost:3030/

Now the triple store is running and can be used.

![Figure: Blank Apache Jena Fuseki Server"](./images/apache_jena_fuseki_01.png)

## Setup Database

When there is no dataset available, press the "Add one" on the home screen. Otherwise navigate to "manage datasets" and press "+ add new dataset".

![Figure: Setup Database"](./images/apache_jena_fuseki_02.png)

Select a database name, e.g. "PhUSE_Instances" to store and access the CDISC Pilot data instances and "PhUSE_Ontology" the underlying ontologies containing study.ttl and similar. Make sure to select "Persistent" to have the dataset available when restarting the server next time.

## Load instances

After setting the databases, data needs to be included. 

![Figure: Setup Database"](./images/apache_jena_fuseki_03.png)

With "upload data", data can be uploaded. The following files from the CTDasRDF repository should be uploaded (https://github.com/phuse-org/CTDasRDF/tree/master/data/rdf).

| Dataset         | File to upload   |
| --------------- | ---------------- |
| PhUSE_Ontology  | study.ttl        |
| PhUSE_Ontology  | code.ttl         |
| PhUSE_Ontology  | meddra.ttl       |
| PhUSE_Ontology  | time.ttl         |
| PhUSE_Instances | cdiscpilot01.ttl |
| PhUSE_Instances | code.ttl         |

![Figure: Upload Data"](./images/apache_jena_fuseki_05.png)

## Query Triples through Web GUI

Queries can be submitted in the "Query" tab. Any SPARQL query can be submitted to the server through the "play" button in the Query editing are.
In the top two example queries can be selected. 

"Selection of triples" fills the editing are with the following SPARQL query:

```
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix owl: <http://www.w3.org/2002/07/owl#>

SELECT ?subject ?predicate ?object
WHERE {
  ?subject ?predicate ?object
}
LIMIT 25
```

The result is displayed per default as table. The following prefixes might be included in the query to display prefixes instead of long URIs.

```
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix code: <https://w3id.org/phuse/code#>                          
prefix study: <https://w3id.org/phuse/study#> 
prefix sdtmterm: <https://w3id.org/phuse/sdtmterm#> 
prefix skos: <http://www.w3.org/2004/02/skos/core#>
# prefix ...

SELECT ?subject ?predicate ?object
WHERE {
  ?subject ?predicate ?object
}
LIMIT 300
```
![Figure: Prefix definitions"](./images/apache_jena_fuseki_06.png)

## Remove all triples

In case all triples should be removed, the following SPARQL query can be used:

```
DELETE{?s ?p ?o} WHERE{?s ?p ?o}
```
As this command is not valid for the "query" parameter, the "query" parameter has to be exchanged with "update":

![Figure: Update SPARQL Query"](./images/apache_jena_fuseki_04.png)