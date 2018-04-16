@echo off
REM ---------------------------------------------------------------------------
REM StarDogUpload.bat
REM Batch upload to Stardog using SMS files.
REM ---------------------------------------------------------------------------
@echo on
cd C:\_gitHub\CTDasRDF\data\source

@echo Importing  graph metadata
call stardog-admin virtual import CTDasRDF ctdasrdf_graphmeta_mappings.TTL ctdasrdf_graphmeta.csv


REM @echo Importing DM 
REM call stardog-admin virtual import CTDasRDF DM_mappings.TTL DM_subset.csv
REM 
REM REM @echo Importing Investigator and Site (Imputed)
REM REM call stardog-admin virtual import CTDasRDF ctdasrdf_invest_mappings.TTL ctdasrdf_invest.csv
REM 
REM @echo Importing SUPPDM 
REM call stardog-admin virtual import CTDasRDF SUPPDM_mappings.TTL SUPPDM_subset.csv
REM 
REM @echo Importing EX
REM call stardog-admin virtual import CTDasRDF EX_mappings.TTL EX_subset.csv
REM 
REM 
REM @echo Importing VS 
REM call stardog-admin virtual import CTDasRDF VS_mappings.TTL VS_subset.csv
REM 
@pause