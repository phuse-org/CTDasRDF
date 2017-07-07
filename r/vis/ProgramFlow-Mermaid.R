###############################################################################
# FILE: 
# DESC: 
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
###############################################################################
library(DiagrammeR)
# Example submitted on Github as issue: Flag nodes not receiving styles.
mermaid("
graph TB
    idStart>Start]
    idMain1(buildRDF-Driver.R1)
    idMain2(buildRDF-Driver.R2)
    idMain3(buildRDF-Driver.R3)
    idMain4(buildRDF-Driver.R4)
    idMain5(buildRDF-Driver.R5)
    idMain6(buildRDF-Driver.R6)
    idMain7(buildRDF-Driver.R7)
    idMain8(buildRDF-Driver.R8)
    idMain9(buildRDF-Driver.R9)
    idMain10(buildRDF-Driver.R10)
    idMain11(buildRDF-Driver.R11)
    idMain12(buildRDF-Driver.R12)
    idMain13(buildRDF-Driver.R13)
    idMain14(buildRDF-Driver.R14)


    idPrefixes(prefixes.csv)
    idMeta(graphMeta.R)
    idMiscF(misc_F.R)
    idFntreadXPT{readXPT}
    idFntaddPersonId{addPersonId}
    idFntassignDateType{assignDateType}
    idDMxpt((DM.xpt))
    idDMImpute(DM_impute.R)
    idVSxpt((VS.xpt))
    idVSImpute(VS_impute.R)

    idCreateFrag(createFrag_F.R)
    idFntaddDateFrag{addDateFrag}
    idFntCreateDateDict{createDateDict}
    idFntcreateFragOneDomain{createFragOneDomain}

    idDMProcess(processDM.R)
    idPSDM(processSUPPDM.R)
    idVSProcess(processVS.R)
 
    idOutMain(CDISCPILOT01-R.TTL)
    idFin>Fin]

    idStart-->idMain1
    idPrefixes--READ_BY-->idMain1
    idMain1-->idMain2
    idMeta--SOURCED_BY-->idMain2
    idMiscF--SOURCED_BY-->idMain2
    idFntreadXPT-->idMiscF
    idFntaddPersonId-->idMiscF
    idFntassignDateType-->idMiscF

    idMain2-->idMain3
    
    idMain3-->idMain4
    idFntaddDateFrag-->idCreateFrag
    idFntcreateFragOneDomain-->idCreateFrag
    idFntCreateDateDict-->idCreateFrag
    idCreateFrag--SOURCED_BY-->idMain3

    idMain4-->idMain5
    idDMXpt--READ_BY-->idMain5


    idMain5-->idMain6
    idDMImpute-->idMain6


    idMain6-->idMain7
    
    
    idMain7-->idMain8


    idMain8-->idMain9

    idMain9-->idMain10


    idMain10-->idMain11


    idMain11-->idMain12


    idMain12-->idMain13


    idMain13-->idMain14


    idMain14-->idFin



  classDef main     fill:#ffff1a, stroke:#000000,stroke-width:3px;
  classDef sourced  fill:#ffff99, stroke:#666600,stroke-width:3px;
  classDef xpt      fill:#b3b3ff, stroke:#0000cc,stroke-width:3px;
  classDef outTTL   fill:#ff6666, stroke:#000000,stroke-width:3px;
  classDef fnt      fill:#ffe680, stroke:#ffd11a,stroke-width:3px;

  classDef terminus fill:lightgreen,stroke:#000000,stroke-width:3px;

  class idMain1,idMain2,idMain3,idMain4,idMain5,idMain6,idMain7,idMain7,idMain8,idMain9,idMain10,idMain11,idMain12,idMain13,idMain14 main;
  class idFntDataImport,idFntaddDateFrag fnt;
  class idMeta,idMiscF,idCreateFrag,idDMProcess,idPSDM,idVSProcess sourced;
  class idDMxpt,idVSxpt xpt;
  class idOutMain outTTL;
  class idPrefixes terminus;

")

