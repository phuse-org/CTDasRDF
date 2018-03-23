@echo off
REM ---------------------------------------------------------------------------
REM StarDogUpload.bat
REM Batch upload to Stardog using SMS files.
REM ---------------------------------------------------------------------------
REM @echo on
call stardog data export --format TURTLE CTDasRDF C:/temp/cdiscpilot01-SMS.ttl


@pause