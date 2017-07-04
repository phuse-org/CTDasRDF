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
    idMain1(buildRDF-Driver.R)
    idMain2(buildRDF-Driver.R)
    idMain3(buildRDF-Driver.R)
    idMain4(buildRDF-Driver.R)
    idMain5(buildRDF-Driver.R)
    idMain6(buildRDF-Driver.R)
    idMain7(buildRDF-Driver.R)
    idMain8(buildRDF-Driver.R)
    idMain9(buildRDF-Driver.R)


    idPrefixes(prefixes.csv)
    idMeta(graphMeta.R)
    miscF(misc_F.R)
    idFntreadXPT{readXPT}
    idFntaddPersonId{addPersonId}
    idFntassignDateType{assignDateType}
    idDMxpt((DM.xpt))
    idVSxpt((VS.xpt))

    IdCreateFrag(createFrag_F.R)
    idFntaddDateFrag{addDateFrag}
    idFntCreateDateDict{createDateDict}
    idFntcreateFragOneDomain{createFragOneDomain}

    idPDM(processDM.R)
    idPSDM(processSUPPDM.R)
    idPVS(processVS.R)
 
    idOutMain(CDISCPILOT01-R.TTL)
    idFin>Fin]

    idStart-->idMain1
    idPrefixes--READ_BY-->idMain1
    idMain1-->idMain2
    idMeta--SOURCED_BY-->idMain2
    miscF--SOURCED_BY-->idMain2
    idFntreadXPT-->miscF
    idFntaddPersonId-->miscF
    idFntassignDateType-->miscF

    idMain2-->idMain3
    
    idDMxpt--READ_BY-->idMain3
    idVSxpt--READ_BY-->idMain3

    idMain3-->idMain4
    idFntaddDateFrag-->IdCreateFrag
    idFntcreateFragOneDomain-->IdCreateFrag
    IdCreateFrag--SOURCED_BY-->idMain4

    idMain4-->idMain5
    idPDM--SOURCED_BY-->idMain5
    idPSDM--SOURCED_BY-->idMain5
    idPVS--SOURCED_BY-->idMain5

    idMain5-->idMain6
    idMain6--CREATES-->idOutMain

    idMain6-->idMain7
    idMain7-->idFin

  classDef main     fill:#ffff1a, stroke:#000000,stroke-width:3px;
  classDef sourced  fill:#ffff99, stroke:#666600,stroke-width:3px;
  classDef xpt      fill:#b3b3ff, stroke:#0000cc,stroke-width:3px;
  classDef outTTL   fill:#ff6666, stroke:#000000,stroke-width:3px;
  classDef fnt      fill:#ffe680, stroke:#ffd11a,stroke-width:3px;

  classDef terminus fill:lightgreen,stroke:#000000,stroke-width:3px;

  class idMain1,idMain2,idMain3,idMain4,idMain5,idMain6,idMain7 main;
  class idFntDataImport,idFntaddDateFrag fnt;
  class idMeta,miscF,IdCreateFrag,idPDM,idPSDM,idPVS sourced;
  class idDMxpt,idVSxpt xpt;
  class idOutMain, outTTL;
  class idPrefixes terminus;

")

