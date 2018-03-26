@echo off
REM ---------------------------------------------------------------------------
REM StarExportTTL.bat
REM Export entire CTDasRDF graph from Stardog to TTL file in /data/rdf folder
REM ---------------------------------------------------------------------------
REM @echo on
call stardog data export --format TURTLE CTDasRDF C:/_gitHub/CTDasRDF/data/rdf/cdiscpilot01-SMS.ttl


@pause