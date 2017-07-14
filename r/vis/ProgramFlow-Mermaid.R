###############################################################################
# FILE: 
# DESC: 
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
#   To install DiagrammeR:   
#      devtools::install_github('rich-iannone/DiagrammeR')
# TODO: 
###############################################################################
## @knitr processFlow
library(DiagrammeR)
# Example submitted on Github as issue: Flag nodes not receiving styles.
mermaid("
graph TB
    idStart>Start]
    idMain1(1. buildRDF-Driver.R)
    idMain2(2. buildRDF-Driver.R)
    idMain3(3. buildRDF-Driver.R)
    idMain4(4. buildRDF-Driver.R)
    idMain5(5. buildRDF-Driver.R)
    idMain6(6. buildRDF-Driver.R)
    idMain7(7. buildRDF-Driver.R)
    idMain8(8. buildRDF-Driver.R)
    idMain9(9. buildRDF-Driver.R)
    idMain10(10. buildRDF-Driver.R)
    idMain11(11. buildRDF-Driver.R)
    idMain12(12. buildRDF-Driver.R)
    idMain13(13. buildRDF-Driver.R)
    idMain14(14. buildRDF-Driver.R)


    idPrefixes(prefixes.csv)
    idMeta(graphMeta.R)
    idMiscF(misc_F.R)
    idFntreadXPT((readXPT))
    idFntaddPersonId((addPersonId))
    idFntassignDateType((assignDateType))
    idDMxpt((DM.xpt))
    idDMImpute(DM_impute.R)
    idVSxpt((VS.xpt))
    idVSImpute(VS_impute.R)

    idCreateFrag(createFrag_F.R)
    idFntaddDateFrag((addDateFrag))
    idFntCreateDateDict((createDateDict))
    idFntcreateFragOneDomain((createFragOneDomain))

    idDMFrag(DM_Frag.R)
    idVSFrag(VS_Frag.R)

    idDMProcess(DM_process.R)
    idSUPPDMProcess(SUPPDM_process.R)
    idSUPPDMImpute(SUPPDM_impute.R)
    idVSProcess(VS_process.R)
 
    idOutMain(CDISCPILOT01-R.TTL)
    idRiot(Apache RIOT)
    idFin>Fin]

    idStart-->idMain1
    idPrefixes--READ_BY-->idMain1
    idMain1-->idMain2
    idMeta--SOURCED_BY-->idMain2
    idMiscF--SOURCED_BY-->idMain2
    idFntreadXPT--DEFINED_IN-->idMiscF
    idFntaddPersonId--DEFINED_IN-->idMiscF
    idFntassignDateType--DEFINED_IN-->idMiscF

    idMain2-->idMain3
    
    idMain3-->idMain4
    idFntaddDateFrag--DEFINED_IN-->idCreateFrag
    idFntcreateFragOneDomain--DEFINED_IN-->idCreateFrag
    idFntCreateDateDict--DEFINED_IN-->idCreateFrag
    idCreateFrag--SOURCED_BY-->idMain3

    idMain4-->idMain5
    idDMxpt--READ_BY-->idMain5

    idMain5-->idMain6
    idDMImpute--SOURCED_BY-->idMain6

    idMain6-->idMain7
    idVSxpt--READ_BY-->idMain7

    idMain7-->idMain8
    idVSImpute--SOURCED_BY-->idMain8

    idMain8-->idMain9
    idDMFrag--SOURCED_BY-->idMain9

    idMain9-->idMain10
    idDMProcess--SOURCED_BY-->idMain10

    idMain10-->idMain11
    idSUPPDMProcess--SOURCED_BY-->idMain11

    idSUPPDMImpute--SOURCED_BY-->idSUPPDMProcess

    idMain11-->idMain12
    idVSFrag--SOURCED_BY-->idMain12

    idMain12-->idMain13
    idVSProcess--SOURCED_BY-->idMain13

    idMain13-->idMain14
    idMain14--WRITES-->idOutMain
    idRiot--VALIDATES-->idOutMain
    idOutMain-->idFin


  classDef csv      fill:white,stroke:#8282ee,stroke-width:3px;
  classDef xpt      fill:#bed6d0, stroke:#003263,stroke-width:3px, font-color:white;


  classDef main     fill:#7aeb7a,stroke:#000000,stroke-width:3px;
  classDef sourced  fill:#bdf5bd,stroke:#666600,stroke-width:3px;
  classDef outTTL   fill:#4ba6ff,stroke:#80aea3,stroke-width:3px;
  classDef fnt      fill:white,  stroke:#38e138,stroke-width:3px,stroke-dasharray: 5, 5;;
  classDef validate fill:#ff8080,stroke:black,stroke-width:3px;

  classDef RImpute  fill:#bdf5bd,stroke:#ff0000,stroke-width:4px;
  classDef RFrag    fill:#bdf5bd,stroke:#ffa500,stroke-width:4px;
  classDef RProcess fill:#bdf5bd,stroke:#0000ff,stroke-width:4px;

  classDef start fill:lightgreen,stroke:#000000,stroke-width:3px;
  
  class idStart, start;
  class idMain1,idMain2,idMain3,idMain4,idMain5,idMain6,idMain7,idMain7,idMain8,idMain9,idMain10,idMain11,idMain12,idMain13,idMain14 main;
  class idFntreadXPT,idFntaddPersonId,idFntassignDateType,idFntaddDateFrag,idFntcreateFragOneDomain,idFntCreateDateDict fnt;
  class idMeta,idMiscF,idDMProcess,idPSDM,idVSProcess sourced;
  class idDMxpt,idVSxpt xpt;
  class idDMImpute,idVSImpute,idSUPPDMImpute RImpute;
  class idCreateFrag,idDMFrag,idVSFrag RFrag;
  class idDMProcess,idSUPPDMProcess,idVSProcess RProcess;
  class idOutMain outTTL;
  class idPrefixes csv;
  class idRiot validate;

")

