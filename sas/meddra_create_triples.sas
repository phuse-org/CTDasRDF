%************************************************************************************************************************;
%**                                                                                                                    **;
%** License: MIT                                                                                                       **;
%**                                                                                                                    **;
%** Copyright (c) 2019 PhUSE CTDasRDF Project                                                                          **;
%**                                                                                                                    **;
%** Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated       **;
%** documentation files (the "Software"), to deal in the Software without restriction, including without limitation    **;
%** the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and   **;
%** to permit persons to whom the Software is furnished to do so, subject to the following conditions:                 **;
%**                                                                                                                    **;
%** The above copyright notice and this permission notice shall be included in all copies or substantial portions of   **;
%** the Software.                                                                                                      **;
%**                                                                                                                    **;
%** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO   **;
%** THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     **;
%** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,**;
%** TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE     **;
%** SOFTWARE.                                                                                                          **;
%************************************************************************************************************************;

*________________________________________________________________________________________________________
* FILE: meddra_create_triples.sas
* DESC: Program to create triples out of MedDRA ASCII files
* SRC :
* IN  : meddra ascii files named llt.asc, pt.asc, hlt.asc, hlgt.asc, soc.asc, hlt_pt.asc, hlgt_hlt.asc, soc_hlgt.asc
*       all in same location &meddra_path
*
* OUT : &outfile containing the MedDRA triples, should be a ttl file
*
* REQ : meddra files must be available
*       OUTDIR and MEDDRA_PATH has to be set appropriately
* SRC :
* NOTE:
* TODO:
* ENV : HP-UX SAS 9.4
* DATE: 2019-05-03
* BY  : KG
*________________________________________________________________________________________________________;


******************************************************************************;
* define inputs, sub selection and prefixes;
******************************************************************************;

* Define output file;
%LET outfile = <ENTER_PATH_HERE>/meddra221-sas.ttl;

* Define path of MedDRA ASCII files;
%LET meddra_path = <ENTER_PATH_HERE>;

* Define whether sub setting should be performed or not;
%LET subsetting = Y;
* Define Sub Setting Items;
%LET ptOntSubset = ('10003041', '10003053', '10003677', '10012735', '10015150');
%LET ltOntSubset = ('10003047', '10003058', '10003851', '10012727', '10024781');
%LET hltOntSubset = ( '10000032', '10003057', '10012736', '10015151', '10049293');
%LET hlgtOntSubset = ( '10001316', '10007521', '10014982', '10017977');
%LET socOntSubset = ('10007541', '10017947', '10018065', '10022117', '10040785');

* create prefix variables;
%LET meddra = <https://w3id.org/phuse/meddra#>;
%LET xsd = <http://www.w3.org/2001/XMLSchema#>;
%LET rdf = <http://www.w3.org/1999/02/22-rdf-syntax-ns#>;
%LET skos = <http://www.w3.org/2004/02/skos/core#>;
%LET rdfs = <http://www.w3.org/2000/01/rdf-schema#>;


******************************************************************************;
* read MedDRA data;
******************************************************************************;

* Read meddra ascii files, create dataset as "name" from file as "name.asc", column names to be defined and sub setting is applied;
* when the corresponding variable "subsetting" is set to Y;
%MACRO read_meddra_file(name=, columns=, subsetting_where=);
    %LOCAL _i;

    DATA &name (COMPRESS=CHAR);
        %DO _i = 1 %TO %SYSFUNC(COUNTW(&columns%STR( )));
            ATTRIB %SCAN(&columns,&_i) FORMAT=$200.;
        %END;
        INFILE "&meddra_path./&name..asc" DELIMITER='$';
        INPUT
            %DO _i = 1 %TO %SYSFUNC(COUNTW(&columns%STR( )));
               %SCAN(&columns,&_i) $
            %END;
            ;
        %IF &subsetting = Y
        %THEN %DO;
            IF &subsetting_where;
        %END;
        * mask quotes;
        label = TRANWRD(label,'"','\"');
    RUN;

%MEND;

* read all required meddra files;
%read_meddra_file(name=llt, columns=code label pt_code, subsetting_where=code IN &ltOntSubset);
%read_meddra_file(name=pt, columns=code label soc_code, subsetting_where=code IN &ptOntSubset);
%read_meddra_file(name=hlt, columns=code label, subsetting_where=code IN &hltOntSubset);
%read_meddra_file(name=hlgt, columns=code label, subsetting_where=code IN &hlgtOntSubset);
%read_meddra_file(name=soc, columns=code label short, subsetting_where=code IN &socOntSubset);

%read_meddra_file(name=hlt_pt, columns=hlt_code pt_code, subsetting_where=pt_code IN &ptOntSubset);
%read_meddra_file(name=hlgt_hlt, columns=hlgt_code hlt_code, subsetting_where=hlt_code IN &hltOntSubset);
%read_meddra_file(name=soc_hlgt, columns=soc_code hlgt_code, subsetting_where=hlgt_code IN &hlgtOntSubset);

PROC SQL NOPRINT;
    CREATE TABLE pt_2   AS SELECT a.code, a.label, a.soc_code, b.hlt_code FROM pt as a, hlt_pt as b WHERE a.code = b.pt_code ORDER BY a.code;
    CREATE TABLE hlgt_2 AS SELECT a.code, a.label, b.soc_code  FROM hlgt as a, soc_hlgt as b WHERE a.code = b.hlgt_code ORDER BY a.code;
    CREATE TABLE hlt_2  AS SELECT a.code, a.label, b.hlgt_code FROM hlt as a, hlgt_hlt as b WHERE a.code = b.hlt_code ORDER BY a.code;
QUIT;

******************************************************************************;
* create triples;
******************************************************************************;

* general header;
DATA _NULL_;
    FILE "&outfile" lrecl=2000;
    PUT "###############################################################################";
    PUT "# FILE: %SCAN(&outfile,-1,/)";
    PUT "# DESC: triples containing MedDRA                                              ";
    PUT "# REQ :                                                                        ";
    PUT "# SRC :                                                                        ";
    PUT "# IN  :                                                                        ";
    PUT "# OUT :                                                                        ";
    PUT "# NOTE:                                                                        ";
    PUT "# TODO:                                                                        ";
    PUT "# DATE: 2019-05                                                                ";
    PUT "# BY  : KG                                                                     ";
    PUT "###############################################################################";
    PUT ;
    PUT "@prefix rdf: &rdf .       ";
    PUT "@prefix meddra: &meddra . ";
    PUT "@prefix rdfs: &rdfs .     ";
    PUT "@prefix skos: &skos .     ";
    PUT "@prefix xsd: &xsd .       ";
    PUT ;
RUN;

* 1. LLT Creation;
DATA _NULL_;
    FILE "&outfile" MOD lrecl=2000;
    SET llt;
    PUT "meddra:m" code;
    PUT @5 "a rdfs:Resource, skos:Concept, meddra:LowLevelConcept, meddra:MeddraConcept ;";
    PUT @5 "rdfs:label """ label  +(-1)  """^^xsd:string;";
    PUT @5 "skos:prefLabel """ label  +(-1)  """^^xsd:string;";
    PUT @5 "meddra:hasIdentifier """ code  +(-1)  """^^xsd:string;";
    PUT @5 "meddra:hasPT meddra:m" pt_code   +(-1) ".";
    PUT ;
RUN;

* 2. PT Creation;
DATA _NULL_;
    FILE "&outfile" MOD lrecl=2000;
    SET pt_2;
    BY code;
    IF FIRST.code
    THEN DO;
        PUT "meddra:m" code;
        PUT @5 "a skos:Concept, meddra:PreferredConcept ;";
        PUT @5 "skos:prefLabel """ label  +(-1)  """^^xsd:string;";
        PUT @5 "meddra:hasIdentifier """ code  +(-1)  """^^xsd:string;";
    END;
    PUT @5 "meddra:hasHLT meddra:m" hlt_code   +(-1) ";";
    IF LAST.code
    THEN DO;
        PUT @5 ".";
        PUT ;
    END;
RUN;

* 3. HLT Creation;
DATA _NULL_;
    FILE "&outfile" MOD lrecl=2000;
    SET hlt_2;
    BY code;
    IF FIRST.code
    THEN DO;
        PUT "meddra:m" code;
        PUT @5 "a skos:Concept, meddra:HighLevelConcept ;";
        PUT @5 "skos:prefLabel """ label  +(-1)  """^^xsd:string;";
        PUT @5 "meddra:hasIdentifier """ code  +(-1)  """^^xsd:string;";
    END;
    PUT @5 "meddra:hasHLGT meddra:m" hlgt_code  +(-1)  ";";
    IF LAST.code
    THEN DO;
        PUT @5 ".";
        PUT ;
    END;
RUN;

* 4. HLTG Creation;
DATA _NULL_;
    FILE "&outfile" MOD lrecl=2000;
    SET hlgt_2;
    BY code;
    IF FIRST.code
    THEN DO;
        PUT "meddra:m" code;
        PUT @5 "a skos:Concept, meddra:HighLevelGroupConcept ;";
        PUT @5 "skos:prefLabel """ label  +(-1)  """^^xsd:string;";
        PUT @5 "meddra:hasIdentifier """ code  +(-1)  """^^xsd:string;";
    END;
    PUT @5 "meddra:hasSOC meddra:m" soc_code   +(-1) ";";
    IF LAST.code
    THEN DO;
        PUT @5 ".";
        PUT ;
    END;
RUN;

* 5. SOC Creation;
DATA _NULL_;
    FILE "&outfile" MOD lrecl=2000;
    SET soc;
    PUT "meddra:m" code;
    PUT @5 "a skos:Concept, meddra:SystemOrganClassConcept ;";
    PUT @5 "skos:topConceptOf meddra:MedDRA ;";
    PUT @5 "skos:prefLabel """ label  +(-1)  """^^xsd:string;";
    PUT @5 "meddra:hasIdentifier """ code  +(-1)  """^^xsd:string;";
    PUT @5 ".";
    PUT ;
RUN;

