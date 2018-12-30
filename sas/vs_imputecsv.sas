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
* FILE: VS_imputeCSV.SAS
* DESC: Creates data values required for prototyping and ontology development analog to VS_imputCSV.R
* REQ : Prior import of the VS domain by driver script.
* SRC : N/A
* IN  : vs dataset
* OUT : modified vs dataset
* NOTE:  Column names with _im, _im_en, _en are imputed, encoded from orig vals.
* TODO:
* ENV : HP-UX SAS 9.4 UTF8
* DATE: 2018-08-30
* BY  : KG
*________________________________________________________________________________________________________;




%MACRO impute_vs();

    %LOCAL vars i;

    DATA vs;
        SET vs;
        ATTRIB vsreasnd        FORMAT = $200.;
        ATTRIB vsdrvfl         FORMAT = $10.;
        ATTRIB vsstat_im       FORMAT = $10.;
        ATTRIB vsgrpid_im      FORMAT = $10.;
        ATTRIB vsblfl          FORMAT = $10.;
        ATTRIB vsrftdtc        FORMAT = $50.;
        ATTRIB vslat_im        FORMAT = $50.;
        ATTRIB vsloc_im        FORMAT = $50.;
        ATTRIB startRule_im    FORMAT = $50.;
        ATTRIB vsorresu_im     FORMAT = $50.;
        ATTRIB visit_im_titleC FORMAT = $50.;
        ATTRIB vsspid_im       FORMAT = $50.;
        ATTRIB vspos_im_titleC FORMAT = $50.;
        ATTRIB vspos_im_lowerC FORMAT = $50.;
        ATTRIB vstpt_label_im  FORMAT = $50.;
        ATTRIB vstpt_AssumeBodyPosStartRule_im  FORMAT = $50.;
        ATTRIB vsdtc_en        FORMAT = $50.;
        ATTRIB vsspid_im       FORMAT = $50.;



        * StartRules based on vstpt;
        SELECT (UPCASE(STRIP(vstpt)));
            WHEN ('AFTER LYING DOWN FOR 5 MINUTES' ) startRule_im = 'StartRuleLying5';
            WHEN ('AFTER STANDING FOR 1 MINUTE'    ) startRule_im = 'StartRuleStanding1';
            WHEN ('AFTER STANDING FOR 3 MINUTES'   ) startRule_im = 'StartRuleStanding3';
            OTHERWISE;
        END;

        * vsdrvfl - Derived Flag Y/N, Reason not done, Activity Status;
        * vsgrpid_im - Group ID assignment, vsblfl - Baseline flag;
        IF vsseq IN (1,2,3,43,44,45,46,86,87,88,128,142) AND usubjid = "01-701-1015"
        THEN DO;
            vsreasnd    = "not applicable";
            vsdrvfl     = "N";
            vsstat_im   = "CO";
            vsgrpid_im  = "GRPID1";
            vsblfl      = "Y";
            *Create Vals [new Columns];
            vscat_im    = "Category_1";
            vssubcat_im = "Subcategory_1";

        END;

        *vsrftdtc - Added to match AO VS_imputed.xlsx;
        IF vsseq IN (1,2,3,86,87,88) AND  usubjid = "01-701-1015"
           THEN vsrftdtc = "2013-12-26";
        IF vsseq IN (1,3,44,46,86,88)  AND usubjid = "01-701-1015"
           THEN vslat_im = "RIGHT";
        IF vsseq IN (2,45,87) AND usubjid = "01-701-1015"
           THEN vslat_im = "LEFT";

        * vsloc_im - vstestcd location - Add value for ARM, recode ORAL CAVITY to allow use in IRI;
        IF vstestcd IN ('DIABP', 'SYSBP') THEN vsloc_im = "Arm";
        IF vsloc    IN ('ORAL CAVITY')    THEN vsloc_im = "Oral_Cavity";

        * vstest_outcome_im - labels for test type outcomes - Groups DIABP and SYSBP together into BP outcomes per email AO 11JUN18;
        SELECT (vstestcd);
            WHEN ("DIABP")  vstest_outcome_im = "BloodPressure";
            WHEN ("SYSBP")  vstest_outcome_im = "BloodPressure";
            WHEN ("HEIGHT") vstest_outcome_im = "Height";
            WHEN ("PULSE")  vstest_outcome_im = "Pulse";
            WHEN ("TEMP")   vstest_outcome_im = "Temperature";
            WHEN ("WEIGHT") vstest_outcome_im = "Weight";
            OTHERWISE PUT "Not catched vstest_outcome_im " vstestcd;
        END;

        * vstest_comp - Compressed values of vstest, also remove Rate from PulseRate;
        vstest_comp = TRANWRD(COMPRESS(vstest, " "),"Rate","");

        * Replace special characters with '_' to allow use as IRI;
        vsorres_en = STRIP(TRANSLATE(STRIP(vsorres),"_", "."));

        * vsorresu_im  units - For links to code.ttl. Only some values  change from original data.;
        SELECT (vsorresu);
            WHEN ("in")        vsorresu_im = "IN";
            WHEN ("mmHg")      vsorresu_im = "mmHG";
            WHEN ("beats/min") vsorresu_im = "BEATS_MIN";
            WHEN ("F")         vsorresu_im = "F";
            WHEN ("LB")        vsorresu_im = "LB";
            OTHERWISE PUT "Not catched vsorresu " vsorresu;
        END;

        * visit_im_titleC - Title Case (titleC) for RDF Labels.;
        visit_im_titleC = PROPCASE(visit);
        vspos_im_titleC = PROPCASE(vspos);
        vspos_im_lowerC = LOWCASE(vspos);
        vstpt_label_im  = LOWCASE(vstpt);

        * vstpt_AssumeBodyPosStartRule_im - Study protcol has the patient lying for 5 min before standing for 1 min.;
        *  The standing 1 min therefore has a previous 5 min start rule.;
        IF vstpt = "AFTER STANDING FOR 1 MINUTE" THEN vstpt_AssumeBodyPosStartRule_im = "StartRuleLying5";

        * URL encoding - Encode fields  that may potentially have values that violate valid IRI format;
        %LET vars = vsdtc;
        %DO i = 1 %TO %SYSFUNC(COUNTW(&vars));
            %SCAN(&vars,&i)_en = STRIP(TRANSLATE(STRIP(%SCAN(&vars,&i)),"___", " |:"));
        %END;

        * vsspid_im - Sponsor defined ID for various tests.;
        IF usubjid = "01-701-1015"
           THEN SELECT (vsseq);
                WHEN (1)   vsspid_im = "123";
                WHEN (2)   vsspid_im = "719";
                WHEN (3)   vsspid_im = "235";
                WHEN (43)  vsspid_im = "1000";
                WHEN (44)  vsspid_im = "125";
                WHEN (45)  vsspid_im = "721";
                WHEN (46)  vsspid_im = "237";
                WHEN (86)  vsspid_im = "124";
                WHEN (87)  vsspid_im = "720";
                WHEN (88)  vsspid_im = "236";
                WHEN (128) vsspid_im = "3000";
                WHEN (142) vsspid_im = "5000";
                OTHERWISE;
           END;
    RUN;
%MEND;

%impute_vs();
