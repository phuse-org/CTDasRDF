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
2019-01      | Document creation & Update (KG)


## Trial Summary - addOn/isAddOnStudy

We do have two triples in the study.ttl:

```
study:Study     study:addOn         code:NoYesResponse
study:Study     study:isAddOnStudy  code:NoYesResponse
```

**Question**: Where is the difference? In the TS domain there is only the TSPARMCD = ADDON.

**Answer**:

## Code.ttl - Prefix differences code: vs sdtmterm:

**Question**: I guess we use "code:" as prefix for cutstom code items and "sdtmterm:" for CDISC codelists? Extensible codelists are also maintained under "code:", even though the values might be CDISC Terminology for our pilot? Or should we include all CDISC terms with the "sdtmterm:" prefix instead? How would it look like for having CDISC code + extensions? These extensions are typically company specific.

Example: code:AgeGroup uses the code prefix but only CDISC terminology for the extended codelist.

**Answer**:

## Code.ttl - update with CDISC Controlled Terminology

**Question**: 1) Would it be ok to include additional CDISC Controlled Terminology using the same strategy as available in code.ttl and update code.ttl accordingly? For example include also other AgeGroup declarations which are available in CDISC controlled terminology? 2) Can we include altLabels where it make sense? "No" / "Yes" has already been included as alternative Labels for the response code.

**Answer**:
