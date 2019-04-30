Placeholder for Ontology documentation.

Some content likely to move here from the Data Sources documentation.

## Namesplace and Prefixes
To provide friendly IRIs that de-reference to the ontology files we are editing, we decided to use w3id.org to register namespaces and preferred prefixes for different ontology files.

The purpose of w3id.org is to provide a secure, permanent URL re-direction service for Web applications. This service is run by the W3C Permanent Identifier Community Group: https://w3id.org

Anyone can register a prefix by submitting a pull request to the w3id.org github repo located at: https://github.com/perma-id/w3id.org

Currently registered vocabularies:

```
https://w3id.org/phuse/cd01p (@prefix cd01p: https://w3id.org/phuse/cd01p#)
https://w3id.org/phuse/cdiscpilot01 (@prefix cd01p: https://w3id.org/phuse/cdiscpilot01#)
https://w3id.org/phuse/code (@prefix cd01p: https://w3id.org/phuse/code#)
https://w3id.org/phuse/sdtm (@prefix cd01p: https://w3id.org/phuse/sdtm#)
https://w3id.org/phuse/sdtmterm (@prefix cd01p: https://w3id.org/phuse/sdtmterm#)
https://w3id.org/phuse/study (@prefix cd01p: https://w3id.org/phuse/study#)
```

### Find the PhUSE Namespaces

Search
* Go to the [w3id Github repository](https://github.com/perma-id/w3id.org): 
* Search for "PhUSE" (upper left of page)

Direct Links
* https://github.com/perma-id/w3id.org/tree/master/phuse

### Updating the PHUSE Prefixes

* Open the [.htaccess](https://github.com/perma-id/w3id.org/blob/master/phuse/.htaccess)
* Edit to update or add anew redirect rule
* Submit a pull request to the [w3id Github repository](https://github.com/perma-id/w3id.org)

### Known Issues

Importing
* Topbraid - You must use *https* when importing these namespaces
* Protege - There is a know certificate issue https://github.com/perma-id/w3id.org/issues/1063 that requires downloading the files locally and loading from there. 

Please raise an issue if you run into this and need help.

[Back to TOC](TableOfContents.md)
