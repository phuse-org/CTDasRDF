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
* FILE: xpttocsv.sas
* DESC: Convert XPT domains to CSV files for SMS mapping analog to XPTtoCSV.R
* SRC :
* IN  : 1. SAS Scripts for each domain, except SUPPDM which is subset and written out from this script.
*       2. functions.sas  - misc data processing functions
*       3. ctdasrdf_graphmeta.csv  - metadata for graph creation process.
*          written back out with new timestamp for which SAS scripts run.
* OUT : <domain name>_subset.csv  (created for DM, EX, VS)
*       ctdasrdf_graphmeta.csv (updated)
* REQ : Program must run in sequence
* SRC :
* NOTE: Some values are imputed  to match ontology development requirements.
* TODO:
* ENV : HP-UX SAS 9.4 UTF8
* DATE: 2018-08-30
* BY  : KG
*________________________________________________________________________________________________________;




****************************************************************************************************;
* initialize settings
****************************************************************************************************;

%LET base_path  = /ctd_as_rdf_path;                                                *basic path;
%LET xpt_path   = &base_path/data/source;                                          *xpt input path;
%LET out_path   = &base_path/data/sas;                                             *output path;
%LET pgms_path  = &base_path/sas;                                                  *program path;

%LET dm_n=3;                *The first n patients from the DM domain.;
%LET subset =;              *subject subset listing, e.g. '01-701-1015', '01-701-1023', '01-701-1028',
                             if empty, the first dm_n subjects from the DM domain are read;

%INCLUDE "&pgms_path/functions.sas";

****************************************************************************************************;
* Graph Metadata
* Read in the source CSV, insert time stamp, and write it back out
* Source file needed UTF-8 spec to import first column correctly. Could be artifact that needs later replacement.
****************************************************************************************************;

DATA _NULL_;
    INFILE "&xpt_path/ctdasrdf_graphmeta.csv" lrecl=20000 END=eof TRUNCOVER ENCODING="utf-8";
    FILE "&out_path/ctdasrdf_graphmeta.csv" lrecl=20000 ENCODING="utf-8";

    ATTRIB text FORMAT=$20000.;
    INPUT;
    text = _INFILE_;

    * update the last cell value containing the date with of the run (today);
    IF _N_ = 2
    THEN DO;
        text = SUBSTR(text,1,LENGTH(text) - LENGTH(SCAN(text,-1,","))) || """%SYSFUNC(date(),YYMMDD10.)T%SYSFUNC(time(),e8601lz.)""";
    END;

    PUT text;
RUN;

****************************************************************************************************;
* XPT Imports
****************************************************************************************************;

*******************;
* DM Domain;
*******************;
%readXPT(domain = DM);
%createsubsetvariable(dm_domain = DM, subsetvar = subset, subset_obs_num = &dm_n);
%PUT ### The following USUBJIDS are used: &subset;
%subset(domain = DM);
%INCLUDE "&pgms_path/dm_imputecsv.sas";
%write_csv(data=dm, file="&out_path/DM_subset.csv")

*******************;
* EX Domain;
*******************;
%readXPT(domain = EX);
%subset(domain = EX);
%* derive values, add Drug Administration interval from DM;
%INCLUDE "&pgms_path/ex_imputecsv.sas";
%write_csv(data=ex, file="&out_path/EX_subset.csv")

*******************;
* VS Domain;
*******************;
%readXPT(domain = VS);
* Subset for development                                              ;
* Subset to match ontology data. Expand to all of subjid 1015 later.  ;
* VS is also used to get performed dates for patients 1023, 1028      ;
*  for Baseline, screening, Wk2 and Wk24 dates.                       ;
*   1023 : 153,159, 165                                               ;
*   1028 : 228, 234, 242, 264                                         ;
DATA vs;
    SET vs;
    IF _N_ IN (1,2,3,86,87,88,43,44,45,46,128,142, 7, 13, 37, 153,159, 165, 228, 234, 242, 264);
RUN;
%* derive values;
%INCLUDE "&pgms_path/vs_imputecsv.sas";
%write_csv(data=vs, file="&out_path/VS_subset.csv")
