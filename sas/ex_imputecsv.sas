%************************************************************************************************************************;
%**                                                                                                                    **;
%** License: MIT                                                                                                       **;
%**                                                                                                                    **;
%** Copyright (c) 2018 PhUSE CTDasRDF Project                                                                          **;
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
* FILE: ex_imputecsv.sas
* DESC: Creates data values required for prototyping and ontology development analog to EX_imputCSV.R
* REQ : Prior import of the EX domain by driver script XPTtoCSV.SAS
* SRC : N/A
* IN  : ex dataset
* OUT : modified ex dataset
* NOTE:  Column names with _im, _im_en, _en are imputed, encoded from orig vals.
* TODO:
* ENV : HP-UX SAS 9.4 UTF8
* DATE: 2018-08-30
* BY  : KG
*________________________________________________________________________________________________________;



%MACRO impute_ex();

    %LOCAL vars i;

    PROC SORT DATA=dmdrugint; BY usubjid; RUN;
    PROC SORT DATA=ex;        BY usubjid; RUN;

    DATA ex;
        MERGE ex (IN=_actual) dmdrugint;
        BY usubjid;
        IF _actual;

        ATTRIB extrt_exdose_im FORMAT=$200.;

        * Imputations;
        fixDoseInt_im       = catt("", exstdtc,  "_", exendtc);
        fixDoseInt_label_im = catx(" ", exstdtc,  " to ", exendtc);

        * visit to Camel Case Short form for linking  IRIs to ontology;
        SELECT (UPCASE(visit));
            WHEN ('SCREENING 1'        )  visit_im_titleCSh = 'Screening1';
            WHEN ('SCREENING 2'        )  visit_im_titleCSh = 'Screening2';
            WHEN ('BASELINE'           )  visit_im_titleCSh = 'Baseline';
            WHEN ('AMBUL ECG PLACEMENT')  visit_im_titleCSh = 'AmbulECGPlacement';
            WHEN ('AMBUL ECG REMOVAL'  )  visit_im_titleCSh = 'AmbulECGRemoval';
            WHEN ('WEEK 2'             )  visit_im_titleCSh = 'Wk2';
            WHEN ('WEEK 4'             )  visit_im_titleCSh = 'Wk4';
            WHEN ('WEEK 6'             )  visit_im_titleCSh = 'Wk6';
            WHEN ('WEEK 8'             )  visit_im_titleCSh = 'Wk8';
            WHEN ('WEEK 12'            )  visit_im_titleCSh = 'Wk12';
            WHEN ('WEEK 16'            )  visit_im_titleCSh = 'Wk16';
            WHEN ('WEEK 20'            )  visit_im_titleCSh = 'Wk20';
            WHEN ('WEEK 24'            )  visit_im_titleCSh = 'Wk24';
            WHEN ('WEEK 26'            )  visit_im_titleCSh = 'Wk26';
            WHEN ('RETRIEVAL'          )  visit_im_titleCSh = 'Retrieval';
            WHEN ('UNSCHEDULED 3.1'    )  visit_im_titleCSh = 'Unscheduled31';
            OTHERWISE;
        END;

        * visit as Title case for use in skos:prefLabel;
        SELECT (UPCASE(visit));
            WHEN ('SCREENING 1'        )  visit_im_titleC = 'Screening 1';
            WHEN ('SCREENING 2'        )  visit_im_titleC = 'Screening 2';
            WHEN ('BASELINE'           )  visit_im_titleC = 'Baseline';
            WHEN ('AMBUL ECG PLACEMENT')  visit_im_titleC = 'Ambul ECG Placement';
            WHEN ('AMBUL ECG REMOVAL'  )  visit_im_titleC = 'Ambul ECG Removal';
            WHEN ('WEEK 2'             )  visit_im_titleC = 'Week 2';
            WHEN ('WEEK 4'             )  visit_im_titleC = 'Week 4';
            WHEN ('WEEK 6'             )  visit_im_titleC = 'Week 6';
            WHEN ('WEEK 8'             )  visit_im_titleC = 'Week 8';
            WHEN ('WEEK 12'            )  visit_im_titleC = 'Week 12';
            WHEN ('WEEK 16'            )  visit_im_titleC = 'Week 16';
            WHEN ('WEEK 20'            )  visit_im_titleC = 'Week 20';
            WHEN ('WEEK 24'            )  visit_im_titleC = 'Week 24';
            WHEN ('WEEK 26'            )  visit_im_titleC = 'Week 26';
            WHEN ('RETRIEVAL'          )  visit_im_titleC = 'Retrieval';
            WHEN ('UNSCHEDULED 3.1'    )  visit_im_titleC = 'Unscheduled 3.1';
            OTHERWISE;
        END;

        * URL encoding - Encode fields  that may potentially have values that violate valid IRI format;
        %LET vars = exstdtc exendtc exroute fixDoseInt_im;
        %DO i = 1 %TO %SYSFUNC(COUNTW(&vars));
            %SCAN(&vars,&i)_en = STRIP(TRANSLATE(STRIP(%SCAN(&vars,&i)),"___", " |:"));
        %END;

        * drop unnecessary temporary variables;
        DROP fixDoseInt_im;

        *Low/High dose assigned to Product_1/_2 as per AO 21JUN18;
        IF      UPCASE(extrt) = "PLACEBO"                    THEN extrt_exdose_im = "PlaceboDrug";
        ELSE IF UPCASE(extrt) = "XANOMELINE" AND exdose = 54 THEN extrt_exdose_im = "Product_1";
        ELSE IF UPCASE(extrt) = "XANOMELINE" AND exdose = 81 THEN extrt_exdose_im = "Product_2";
    RUN;

%MEND;

%impute_ex();
