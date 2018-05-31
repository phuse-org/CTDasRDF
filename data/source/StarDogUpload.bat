@echo off
REM ---------------------------------------------------------------------------
REM StarDogUpload.bat
REM Batch upload to Stardog using SMS files.
REM ---------------------------------------------------------------------------
@echo on
cd C:\_gitHub\CTDasRDF\data\source

@echo.
@echo Importing graph metadata
call stardog-admin virtual import CTDasRDFSMS ctdasrdf_graphmeta_mappings.TTL ctdasrdf_graphmeta.csv

@echo.
@echo Importing DM
call stardog-admin virtual import CTDasRDFSMS DM_mappings.TTL DM_subset.csv

@echo.
@echo Importing Investigator and Site (Imputed)
call stardog-admin virtual import CTDasRDFSMS ctdasrdf_invest_mappings.TTL ctdasrdf_invest.csv

@echo.
@echo Importing SUPPDM
call stardog-admin virtual import CTDasRDFSMS SUPPDM_mappings.TTL SUPPDM_subset.csv

@echo.
@echo Importing EX
call stardog-admin virtual import CTDasRDFSMS EX_mappings.TTL EX_subset.csv

@echo.
@echo Importing VS
call stardog-admin virtual import CTDasRDFSMS VS_mappings.TTL VS_subset.csv

@echo.
@pause
