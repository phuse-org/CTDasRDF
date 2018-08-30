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
* FILE: zzz_compare_csvs.sas
* DESC: program to compare the SAS created CSV files with the R created CSV files
* SRC :
* IN  : *.csv files
* OUT : PROC COMPARE output
* REQ :
* SRC :
* NOTE:
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

%INCLUDE "&pgms_path/functions.sas";

****************************************************************************************************;
* read and compare files
****************************************************************************************************;

*DM;
%read_csv(data = dm_sas, file = "&out_path/DM_subset.csv");
%read_csv(data = dm_r, file = "&xpt_path/DM_subset.csv");
PROC COMPARE BASE=dm_sas COMP=dm_r;
RUN;


*EX;
%read_csv(data = ex_sas, file = "&out_path/EX_subset.csv");
%read_csv(data = ex_r, file = "&xpt_path/EX_subset.csv");
PROC COMPARE BASE=ex_sas COMP=ex_r;
RUN;


*VS;
%read_csv(data = vs_sas, file = "&out_path/VS_subset.csv");
%read_csv(data = vs_r, file = "&xpt_path/vs_subset.csv");
PROC SORT DATA=vs_sas; BY usubjid vsseq; RUN;
PROC SORT DATA=vs_r;   BY usubjid vsseq; RUN;
PROC COMPARE BASE=vs_sas COMP=vs_r;
RUN;







*********************;
* in case of issues, investigate different variables;
*********************

* investigate variables not in common;
PROC CONTENTS DATA=vs_sas out=var_sas NOPRINT; RUN;
PROC CONTENTS DATA=vs_r   out=var_r   NOPRINT; RUN;
DATA var_sas; SET var_sas; name=lowcase(name); RUN;
DATA var_r;   SET var_r;   name=lowcase(name); RUN;
PROC SORT DATA=var_sas; BY name; RUN;
PROC SORT DATA=var_r;   BY name; RUN;
DATA conflicts;
    MERGE var_sas (IN=_sas) var_r (IN = _r);
    BY name;
    IF NOT _sas AND _r THEN OUTPUT;
RUN;