@echo off
REM ---------------------------------------------------------------------------
REM StarDogUpload.bat
REM Batch upload to Stardog using SMS files.
REM ---------------------------------------------------------------------------
@echo on
cd C:\temp\git\CTDasRDF\data\source
SET PATH=%PATH%;C:\Temp\Programs\stardog-5.3.2\bin


@echo.
@echo Importing DM
call stardog-admin virtual import CTDasRDFSMS DM_map.TTL DM_subset.csv

@echo.
@echo Importing SUPPDM
call stardog-admin virtual import CTDasRDFSMS SUPPDM_map.TTL SUPPDM_subset.csv

@echo.
@echo Importing EX
call stardog-admin virtual import CTDasRDFSMS EX_map.TTL EX_subset.csv

@echo.
@echo Importing VS
call stardog-admin virtual import CTDasRDFSMS VS_map.TTL VS_subset.csv

@echo.
@echo Importing Investigator and Site (Imputed)
call stardog-admin virtual import CTDasRDFSMS Invest_map.TTL Invest.csv

@echo.
@echo Importing graph metadata
call stardog-admin virtual import CTDasRDFSMS Graphmeta_map.TTL Graphmeta.csv

@echo.
@pause
@echo.
