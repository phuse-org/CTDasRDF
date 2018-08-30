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
* FILE: dm_imputecsv.sas
* DESC: Creates data values required for prototyping and ontology develeopment analog to dm_inputeCSV.R
* REQ : Prior import of the DM domain by driver script XPTtoCSV.SAS
* SRC : N/A
* IN  : dm dataset
* OUT : modified dm dataset
*       dmDrugInt  dataset for use in EX mapping.
* NOTE: Column names with _im, _im_en, _en are imputed, encoded from orig vals.
* TODO:
* ENV : HP-UX SAS 9.4 UTF8
* DATE: 2018-08-30
* BY  : KG
*________________________________________________________________________________________________________;


%MACRO impute_dm();

    %LOCAL vars i;

    DATA dm;
        ATTRIB rficdtc FORMAT=$10. LENGTH=$10;
        SET dm;
        ATTRIB actarmcd_im FORMAT=$200.;
        ATTRIB brthdate FORMAT=$10.;


        IF      actarmcd = "Pbo"    THEN actarmcd_im = "Pbo";
        ELSE IF actarmcd = "Xan_Hi" THEN actarmcd_im = "XanomelineHigh";

        * calculate a rough birth date, absent in source data;
        brthdate = PUT(INPUT(rfstdtc,?? YYMMDD10.) - (age*365.25),YYMMDD10.);
        *Informed Consent  (column present with missing values in DM source);
        rficdtc = dmdtc;
        *-- Death Date and Flag ----;
        * Set for Person 1 for testing purposes & will not match original data.;
        IF usubjid = '01-701-1015'
        THEN DO;
            dthdtc = "2013-12-26";
            dthfl = "Y";
        END;

        * Intervals;
        cumudrugadmin_im  = catt("", rfxstdtc, "_", rfxendtc);
        lifespan_im       = catt("", brthdate, "_", dthdtc);
        lifespan_label_im = catx(" ", brthdate, "to", dthdtc);
        refint_im         = catt("", rfstdtc,  "_", rfendtc);
        refint_label_im   = catx(" ", rfstdtc,  "to", rfendtc);

        * No end date to informed consent interval so end in _;
        * infConsInt_im later deleted after being used to create other fields;
        infconsint_im          = catt("", rficdtc,  "_");
        infconsint_label_im    = catx(" ", rficdtc,  " to ");
        cumudrugadmin_label_im = catx(" ", rfxstdtc, " to ", rfxendtc);
        cumudrugadmin_label_im = catx(" ", rfxstdtc, " to ", rfxendtc);
        studypartint_label_im  = catx(" ", dmdtc,    " to ", rfpendtc);

        *  Dependencies between rfpendtc_en, studyPartInt_im to create studyPartInt_im_en;
        studyPartInt_im = catt("", dmdtc,  "_", rfpendtc);

        * -- URL encoding ----;
        * Encode fields  that may potentially have values that violate valid IRI format;
        %LET vars = age brthdate cumuDrugAdmin_im dmdtc dthdtc ethnic infConsInt_im lifeSpan_im
                    race rfpendtc rficdtc rfstdtc rfxstdtc rfxendtc refInt_im
                    rfendtc studyPartInt_im;
        %DO i = 1 %TO %SYSFUNC(COUNTW(&vars));
            %SCAN(&vars,&i)_en = STRIP(TRANSLATE(STRIP(%SCAN(&vars,&i)),"___", " |:"));
        %END;

        * drop unnecessary temporary variables;
        DROP infConsInt_im lifeSpan_im refInt_im studyPartInt_im;
    RUN;

    DATA dmDrugInt;
        SET dm(KEEP=usubjid cumuDrugAdmin_im rfxstdtc rfxendtc);
    RUN;
%MEND;

%impute_dm();
