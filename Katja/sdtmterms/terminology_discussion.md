---
title: "SDTMTERMS generation"
---

## Purpuse

Discussion Area to create a code.ttl extension contain all CDISC controlled terminology

## Files

File  |  Description
----- | -----------
create_sdtmterms_ttl.sas | SAS program to create ttl file
sdtmterms_mini.ttl | mini ttl file containing only NoYes and TrialPhase
sdtmterms.ttl | full ttl file
sdtm-terminology.txt | Input file (from nci homepage)

## Convention

Codelist names use not manual assigned values but the "Name" and not the submission value, examples:

* ID = No_Yes_Response and not NY
* ID = Trial_Phase_Response and not TPHASE

This means the references to our current ontology would need quite some updates.

The "mms:PermissibleValue" information is not available in the input data. I would recommend to remove this information. Currently I set it always which is not correct.

## Question / Discussion

Should we go forward this approach? Should we change the structure somehow further? For example we do not have the permissibleValue information, but we do have additional inoformation, which are currently not in the triples. We might also consider puting the sysnoyms into single synonym triples.

## Available CDISC information in txt

CODE | CODELIST | EXTENSIBLE | NAME | SUB_VAL | SYNONYMS | DEF | NCI
--- |--- |--- |--- |--- |--- |--- |--- 
C66742 |  |No |No Yes Response |NY |No Yes Response |A term that is used to indicate a question with permissible ... |CDISC SDTM Yes No Unknown or Not Applicable Response Terminology
C49487 |C66742 |  |No Yes Response |N |No |The non-affirmative response to a question. (NCI)           ... |No
C48660 |C66742 |  |No Yes Response |NA |NA; Not Applicable |Determination of a value is not relevant in the current cont... |Not Applicable
C17998 |C66742 |  |No Yes Response |U |U; UNK; Unknown |Not known, not observed, not recorded, or refused. (NCI)    ... |Unknown
C49488 |C66742 |  |No Yes Response |Y |Yes |The affirmative response to a question. (NCI)               ... |Yes
C66737 |  |Yes |Trial Phase Response |TPHASE |Trial Phase Response |A terminology codelist relevant to the phase, or stage, of t... |CDISC SDTM Trial Phase Terminology
C48660 |C66737 |  |Trial Phase Response |NOT APPLICABLE |NA; Not Applicable |Determination of a value is not relevant in the current cont... |Not Applicable
C54721 |C66737 |  |Trial Phase Response |PHASE 0 TRIAL |0; Pre-clinical Trial; Trial Phase 0 |First-in-human trials, in a small number of subjects, that a... |Phase 0 Trial
C15600 |C66737 |  |Trial Phase Response |PHASE I TRIAL |1; Trial Phase 1 |The initial introduction of an investigational new drug into... |Phase I Trial
C15693 |C66737 |  |Trial Phase Response |PHASE I/II TRIAL |1-2; Trial Phase 1-2 |A class of clinical study that combines elements characteris... |Phase I/II Trial
C15601 |C66737 |  |Trial Phase Response |PHASE II TRIAL |2; Trial Phase 2 |Phase 2. Controlled clinical studies conducted to evaluate t... |Phase II Trial
C15694 |C66737 |  |Trial Phase Response |PHASE II/III TRIAL |2-3; Trial Phase 2-3 |A class of clinical study that combines elements characteris... |Phase II/III Trial
C49686 |C66737 |  |Trial Phase Response |PHASE IIA TRIAL |2A; Trial Phase 2A |A clinical research protocol generally referred to as a pilo... |Phase IIa Trial
C49688 |C66737 |  |Trial Phase Response |PHASE IIB TRIAL |2B; Trial Phase 2B |A clinical research protocol generally referred to as a well... |Phase IIb Trial
C15602 |C66737 |  |Trial Phase Response |PHASE III TRIAL |3; Trial Phase 3 |Phase 3. Studies are expanded controlled and uncontrolled tr... |Phase III Trial
C49687 |C66737 |  |Trial Phase Response |PHASE IIIA TRIAL |3A; Trial Phase 3A |A classification typically assigned retrospectively to a Pha... |Phase IIIa Trial
C49689 |C66737 |  |Trial Phase Response |PHASE IIIB TRIAL |3B; Trial Phase 3B |A subcategory of Phase III trials done near the time of appr... |Phase IIIb Trial
C15603 |C66737 |  |Trial Phase Response |PHASE IV TRIAL |4; Trial Phase 4 |Phase 4. Postmarketing (Phase 4) studies to delineate additi... |Phase IV Trial
C47865 |C66737 |  |Trial Phase Response |PHASE V TRIAL |5; Trial Phase 5 |Postmarketing surveillance is sometimes referred to as Phase... |Phase V Trial


## Example triple file

```
###############################################################################
# FILE: sdtmterms.ttl                                                          
# DESC: triples containing CDISC sdtm terminology for PhUSE project            
# REQ :                                                                        
# SRC :                                                                        
# IN  :                                                                        
# OUT :                                                                        
# NOTE: origin: https://evs.nci.nih.gov/ftp1/CDISC/SDTM/CDASH%20Terminology.txt
#        - 2018-01-08                                                          
# TODO:                                                                        
# DATE: 2019-01                                                                
# BY  : KG                                                                     
###############################################################################

@prefix sdtmterms: <https://w3id.org/phuse/sdtmterms#> .              
@prefix code: <https://w3id.org/phuse/code#> .                        
@prefix owl: <http://www.w3.org/2002/07/owl#> .                       
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .               
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .                    


sdtmterms:No_Yes_Response
   rdf:type                  owl:Class;
   rdfs:subClassOf           code:DefinedConcept;
   rdfs:subClassOf [
       rdf:type        owl:Restriction;
       owl:hasValue    code:CodeSystem_CDISCTerminology;
       owl:onProperty  code:hasCodeSystem;
     ];
   skos:prefLabel            'No Yes Response';
.

sdtmterms:No_Yes_Response_N
   rdf:type                                      sdtmterms:No_Yes_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "N";
   code:hasCode                                  "C49487";
   schema:cdiscDefinition                        "The non-affirmative response to a question. (NCI)";
   schema:cdiscSubmissionValue                   "N";
   schema:cdiscSynonyms                          "No";
   schema:nciCode                                "C49487";
   schema:nciPreferredTerm                       "No";
   mms:inValueDomain                             "sdtmterm:C66742";
.

sdtmterms:No_Yes_Response_NA
   rdf:type                                      sdtmterms:No_Yes_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "NA";
   code:hasCode                                  "C48660";
   schema:cdiscDefinition                        "Determination of a value is not relevant in the current context. (NCI)";
   schema:cdiscSubmissionValue                   "NA";
   schema:cdiscSynonyms                          "NA; Not Applicable";
   schema:nciCode                                "C48660";
   schema:nciPreferredTerm                       "Not Applicable";
   mms:inValueDomain                             "sdtmterm:C66742";
.

sdtmterms:No_Yes_Response_U
   rdf:type                                      sdtmterms:No_Yes_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "U";
   code:hasCode                                  "C17998";
   schema:cdiscDefinition                        "Not known, not observed, not recorded, or refused. (NCI)";
   schema:cdiscSubmissionValue                   "U";
   schema:cdiscSynonyms                          "U; UNK; Unknown";
   schema:nciCode                                "C17998";
   schema:nciPreferredTerm                       "Unknown";
   mms:inValueDomain                             "sdtmterm:C66742";
.

sdtmterms:No_Yes_Response_Y
   rdf:type                                      sdtmterms:No_Yes_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "Y";
   code:hasCode                                  "C49488";
   schema:cdiscDefinition                        "The affirmative response to a question. (NCI)";
   schema:cdiscSubmissionValue                   "Y";
   schema:cdiscSynonyms                          "Yes";
   schema:nciCode                                "C49488";
   schema:nciPreferredTerm                       "Yes";
   mms:inValueDomain                             "sdtmterm:C66742";
.

sdtmterms:Trial_Phase_Response
   rdf:type                  owl:Class;
   rdfs:subClassOf           code:DefinedConcept;
   rdfs:subClassOf [
       rdf:type        owl:Restriction;
       owl:hasValue    code:CodeSystem_CDISCTerminology;
       owl:onProperty  code:hasCodeSystem;
     ];
   skos:prefLabel            'Trial Phase Response';
.

sdtmterms:Trial_Phase_Response_NOT_APPLICABLE
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "NOT APPLICABLE";
   code:hasCode                                  "C48660";
   schema:cdiscDefinition                        "Determination of a value is not relevant in the current context. (NCI)";
   schema:cdiscSubmissionValue                   "NOT APPLICABLE";
   schema:cdiscSynonyms                          "NA; Not Applicable";
   schema:nciCode                                "C48660";
   schema:nciPreferredTerm                       "Not Applicable";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_0_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE 0 TRIAL";
   code:hasCode                                  "C54721";
   schema:cdiscDefinition                        "First-in-human trials, in a small number of subjects, that are conducted before Phase 1 trials and are intended to assess new candidate therapeutic and imaging agents. The study agent is administered at a low dose for a limited time, and there is no therapeutic or diagnostic intent. NOTE: FDA Guidance for Industry, Investigators, and Reviewers: Exploratory IND Studies, January 2006 classifies such studies as Phase 1. NOTE: A Phase 0 study might not include any drug delivery but may be an exploration of human material from a study (e.g., tissue samples or biomarker determinations). [Improving the Quality of Cancer Clinical Trials: Workshop summary-Proceedings of the National Cancer Policy Forum Workshop, improving the Quality of Cancer Clinical Trials (Washington, DC, Oct 2007)] (CDISC glossary)";
   schema:cdiscSubmissionValue                   "PHASE 0 TRIAL";
   schema:cdiscSynonyms                          "0; Pre-clinical Trial; Trial Phase 0";
   schema:nciCode                                "C54721";
   schema:nciPreferredTerm                       "Phase 0 Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_I_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE I TRIAL";
   code:hasCode                                  "C15600";
   schema:cdiscDefinition                        "The initial introduction of an investigational new drug into humans. Phase 1 studies are typically closely monitored and may be conducted in patients or normal volunteer subjects. NOTE: These studies are designed to determine the metabolism and pharmacologic actions of the drug in humans, the side effects associated with increasing doses, and, if possible, to gain early evidence on effectiveness. During Phase 1, sufficient information about the drug's pharmacokinetics and pharmacological effects should be obtained to permit the design of well-controlled, scientifically valid, Phase 2 studies. The total number of subjects and patients included in Phase I studies varies with the drug, but is generally in the range of 20 to 80. Phase 1 studies also include studies of drug metabolism, structure-activity relationships, and mechanism of action in humans, as well as studies in which investigational drugs are used as research tools to explore biological phenomena or disease processes. [After FDA CDER Handbook, ICH E8] (CDISC glossary)";
   schema:cdiscSubmissionValue                   "PHASE I TRIAL";
   schema:cdiscSynonyms                          "1; Trial Phase 1";
   schema:nciCode                                "C15600";
   schema:nciPreferredTerm                       "Phase I Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_I_II_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE I/II TRIAL";
   code:hasCode                                  "C15693";
   schema:cdiscDefinition                        "A class of clinical study that combines elements characteristic of traditional Phase I and Phase II trials. See also Phase I, Phase II.";
   schema:cdiscSubmissionValue                   "PHASE I/II TRIAL";
   schema:cdiscSynonyms                          "1-2; Trial Phase 1-2";
   schema:nciCode                                "C15693";
   schema:nciPreferredTerm                       "Phase I/II Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_II_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE II TRIAL";
   code:hasCode                                  "C15601";
   schema:cdiscDefinition                        "Phase 2. Controlled clinical studies conducted to evaluate the effectiveness of the drug for a particular indication or indications in patients with the disease or condition under study and to determine the common short-term side effects and risks associated with the drug. NOTE: Phase 2 studies are typically well controlled, closely monitored, and conducted in a relatively small number of patients, usually involving no more than several hundred subjects. [After FDA CDER Handbook, ICH E8] (CDISC glossary)";
   schema:cdiscSubmissionValue                   "PHASE II TRIAL";
   schema:cdiscSynonyms                          "2; Trial Phase 2";
   schema:nciCode                                "C15601";
   schema:nciPreferredTerm                       "Phase II Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_II_III_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE II/III TRIAL";
   code:hasCode                                  "C15694";
   schema:cdiscDefinition                        "A class of clinical study that combines elements characteristic of traditional Phase II and Phase III trials.";
   schema:cdiscSubmissionValue                   "PHASE II/III TRIAL";
   schema:cdiscSynonyms                          "2-3; Trial Phase 2-3";
   schema:nciCode                                "C15694";
   schema:nciPreferredTerm                       "Phase II/III Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_IIA_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE IIA TRIAL";
   code:hasCode                                  "C49686";
   schema:cdiscDefinition                        "A clinical research protocol generally referred to as a pilot or feasibility trial that aims to prove the concept of the new intervention in question. (NCI)";
   schema:cdiscSubmissionValue                   "PHASE IIA TRIAL";
   schema:cdiscSynonyms                          "2A; Trial Phase 2A";
   schema:nciCode                                "C49686";
   schema:nciPreferredTerm                       "Phase IIa Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_IIB_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE IIB TRIAL";
   code:hasCode                                  "C49688";
   schema:cdiscDefinition                        "A clinical research protocol generally referred to as a well-controlled and pivotal trial that aims to prove the mechanism of action of the new intervention in question. A pivotal study will generally be well-controlled, randomized, of adequate size, and whenever possible, double-blind. (NCI)";
   schema:cdiscSubmissionValue                   "PHASE IIB TRIAL";
   schema:cdiscSynonyms                          "2B; Trial Phase 2B";
   schema:nciCode                                "C49688";
   schema:nciPreferredTerm                       "Phase IIb Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_III_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE III TRIAL";
   code:hasCode                                  "C15602";
   schema:cdiscDefinition                        "Phase 3. Studies are expanded controlled and uncontrolled trials. They are performed after preliminary evidence suggesting effectiveness of the drug has been obtained, and are intended to gather the additional information about effectiveness and safety that is needed to confirm efficacy and evaluate the overall benefit-risk relationship of the drug and to provide an adequate basis for physician labeling. NOTE: Phase 3 studies usually include from several hundred to several thousand subjects. [After FDA CDER Handbook, ICH E8] (CDISC glossary)";
   schema:cdiscSubmissionValue                   "PHASE III TRIAL";
   schema:cdiscSynonyms                          "3; Trial Phase 3";
   schema:nciCode                                "C15602";
   schema:nciPreferredTerm                       "Phase III Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_IIIA_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE IIIA TRIAL";
   code:hasCode                                  "C49687";
   schema:cdiscDefinition                        "A classification typically assigned retrospectively to a Phase III trial upon determination by regulatory authorities of a need for a Phase III B trial. (NCI)";
   schema:cdiscSubmissionValue                   "PHASE IIIA TRIAL";
   schema:cdiscSynonyms                          "3A; Trial Phase 3A";
   schema:nciCode                                "C49687";
   schema:nciPreferredTerm                       "Phase IIIa Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_IIIB_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE IIIB TRIAL";
   code:hasCode                                  "C49689";
   schema:cdiscDefinition                        "A subcategory of Phase III trials done near the time of approval to elicit additional findings. NOTE: Dossier review may continue while associated Phase IIIB trials are conducted. These trials may be required as a condition of regulatory authority approval.";
   schema:cdiscSubmissionValue                   "PHASE IIIB TRIAL";
   schema:cdiscSynonyms                          "3B; Trial Phase 3B";
   schema:nciCode                                "C49689";
   schema:nciPreferredTerm                       "Phase IIIb Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_IV_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE IV TRIAL";
   code:hasCode                                  "C15603";
   schema:cdiscDefinition                        "Phase 4. Postmarketing (Phase 4) studies to delineate additional information about the drug's risks, benefits, and optimal use that may be requested by regulatory authorities in conjunction with marketing approval. NOTE: These studies could include, but would not be limited to, studying different doses or schedules of administration than were used in Phase 2 studies, use of the drug in other patient populations or other stages of the disease, or use of the drug over a longer period of time. [After FDA CDER Handbook, ICH E8] (CDISC glossary)";
   schema:cdiscSubmissionValue                   "PHASE IV TRIAL";
   schema:cdiscSynonyms                          "4; Trial Phase 4";
   schema:nciCode                                "C15603";
   schema:nciPreferredTerm                       "Phase IV Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.

sdtmterms:Trial_Phase_Response_PHASE_V_TRIAL
   rdf:type                                      sdtmterms:Trial_Phase_Response ;
   rdf:type                                      mms:PermissibleValue;
   skos:prefLabel                                "PHASE V TRIAL";
   code:hasCode                                  "C47865";
   schema:cdiscDefinition                        "Postmarketing surveillance is sometimes referred to as Phase V.";
   schema:cdiscSubmissionValue                   "PHASE V TRIAL";
   schema:cdiscSynonyms                          "5; Trial Phase 5";
   schema:nciCode                                "C47865";
   schema:nciPreferredTerm                       "Phase V Trial";
   mms:inValueDomain                             "sdtmterm:C66737";
.
```
