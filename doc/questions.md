---
title: "Questions related to the ontology"
output: 
  html_document:
    toc: true
    keep_md: true
---


## Revision

Date         | Comment
------------ | ----------------------------
2019-01-04   | Document creation (KG)


## Trial Summary - addOn/isAddOnStudy

We do have two triples in the study.ttl:

```
study:Study     study:addOn         code:NoYesResponse
study:Study     study:isAddOnStudy  code:NoYesResponse
```

**Question**: Where is the difference? In the TS domain there is only the TSPARMCD = ADDON.
**Answer**: