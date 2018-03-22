@echo off
REM ---------------------------------------------------------------------------
REM StarDogUpload.bat
REM Batch upload to Stardog using SMS files.
REM ---------------------------------------------------------------------------
@echo on
cd C:\_gitHub\CTDasRDF\data\source
@echo Importing DM 
call stardog-admin virtual import CTDasRDF DM_mappings.TTL DM_subset.csv
@echo Importing Investigator and Site (Imputed)
call stardog-admin virtual import CTDasRDF invest_mappings.TTL invest_imputed.csv
@echo Importing SUPPDM 
call stardog-admin virtual import CTDasRDF SUPPDM_mappings.TTL SUPPDM_subset.csv
@pause