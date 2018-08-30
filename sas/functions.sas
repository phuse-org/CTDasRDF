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
* FILE: functions.sas
* DESC: Functions called during the data conversion from XPT to CSV and supporting
* SRC :
* IN  :
* OUT : The following macros are available after include
*       readXPT              - to read XPT files into dataset for a specific domain
*       createSubsetVariable - to create a subset variable list based on the first X number of subjects in the DM domain
*       subset               - to subset a domain to only include subjects for a subset variable list
*       write_csv            - to create CSV file
*       read_csv             - to read CSV file in all character format
*
* REQ :
* SRC :
* NOTE:
* TODO:
* ENV : HP-UX SAS 9.4 UTF8
* DATE: 2018-08-30
* BY  : KG
*________________________________________________________________________________________________________;

%MACRO readXPT(domain     = ,                /* domain abbreviation & input dataset name */
               path       = &xpt_path,       /* path name of xpt file locations */
);

    %* check that file exist;
    %IF %SYSFUNC(FILEEXIST(&path/%LOWCASE(&domain..xpt))) != 1
        %THEN %PUT %STR(ERR)OR: readXPT - file does not exist: &path/%LOWCASE(&domain..xpt);

    LIBNAME xptFile xport "&path/%LOWCASE(&domain..xpt)";
    PROC COPY INLIB=xptfile outlib=work;
    RUN;

    %* check that the domain is created as dataset in work;
    %IF %SYSFUNC(EXIST(&domain)) != 1
        %THEN %PUT %STR(ERR)OR: readXPT - xpt file did not create expected domain dataset: &domain;
%MEND;

%MACRO createSubsetVariable(dm_domain       = DM,
                            subsetvar       = subset,
                            subset_obs_num  =
);

    %IF %LENGTH(%SYSFUNC(TRANSLATE(&dm_n,%STR(          ),0123456789))) > 0
    %THEN %DO;
        %PUT %STR(ERR)OR: createSubsetVariable - DM_N must be numeric when SET_SUBSET is specified;
    %END;

    %IF %SYSFUNC(EXIST(&dm_domain)) != 1 OR %LENGTH(&dm_domain) = 0
        %THEN %PUT %STR(ERR)OR: createSubsetVariable - DM domain dataset does not exist / is not provided: &dm_domain;

    %LET &subsetvar = ;

    PROC SQL NOPRINT;
        SELECT DISTINCT("'" || USUBJID || "'")
               INTO :&&subsetvar SEPARATED BY ","
               FROM &dm_domain
               %IF %LENGTH(&subset_obs_num) > 0
               %THEN %DO;
                   (OBS = &subset_obs_num)
               %END;
               ;
    QUIT;
%MEND;

%MACRO subset(domain    = ,
              subsetvar = subset
);

    %IF %SYSFUNC(EXIST(&domain)) != 1 OR %LENGTH(&domain) = 0
        %THEN %PUT %STR(ERR)OR: subset - Domain dataset does not exist / is not provided: &domain;

    %IF %LENGTH(&subsetvar) = 0
        %THEN %PUT %STR(ERR)OR: subset - the SUBSETVAR must not be provided;

    %IF %LENGTH(&&subsetvar) = 0
    %THEN %DO;
        %PUT %STR(WAR)NING: subset - the content of the SUBSETVAR does not contain content - sub setting is not performed;
        %RETURN;
    %END;

    DATA &domain;
        SET &domain (WHERE=(usubjid IN (&&&subsetvar)));
    RUN;
%MEND;

%MACRO write_csv(data=, file=);
    PROC EXPORT DATA=&data
       OUTFILE=&file
       DBMS=csv
       REPLACE;
    RUN;
%MEND;

%MACRO read_csv(data=, file=);
    * when mixing unix and windows, you might have issues, so remove windows carriage return;
    FILENAME _no_cr TEMP;
    DATA _NULL_;
        INFILE &file lrecl=32000 END=eof;
        FILE _no_cr lrecl=32000;

        INPUT;
        temp = TRANSLATE(_INFILE_,' ' ,'0D'x);
        PUT temp;
    RUN;

    * Read data, but all as character variables;
    PROC IMPORT DATAFILE=_no_cr
         OUT=&data DBMS=csv REPLACE;
         GETNAMES = NO;
    RUN;

    PROC TRANSPOSE DATA=&data(OBS=1) OUT=_temp;
        VAR _all_;
    RUN;

    PROC SQL NOPRINT;
        SELECT catx('=',_name_,col1)
            INTO :rename SEPARATED BY ' '
            FROM _temp;
    QUIT;

    DATA &data;
      SET &data(FIRSTOBS=2 RENAME=(&rename));
    RUN;


    * cleanup;
    PROC DATASETS NOLIST;
       DELETE _temp / MEMTYPE = DATA;
    RUN;
    QUIT;

    FILENAME _no_cr
%MEND;
