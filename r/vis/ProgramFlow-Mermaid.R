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

    idPrefixes(prefixes.csv)
    idMeta(graphMeta.R)
    idImport(dataImportFnts.R)
    idDMxpt((DM.xpt))
    idVSxpt((VS.xpt))

    idFrag(createFrag.R)
    idPDM(processDM.R)
    idPSDM(processSUPPDM.R)
    idPVS(processVS.R)

    idOutMain(CDISCPILOT01-R.TTL)
    idOutCustom(CUSTOM-R.TTL)
    idOutCode(CODE-R.TTL)
    idFin>Fin]


    idStart-->idMain1
    idPrefixes--READ_BY-->idMain1
    idMain1-->idMain2
    idMeta--SOURCED_BY-->idMain2
    idImport--SOURCED_BY-->idMain2

    idMain2-->idMain3
    idDMxpt--READ_BY-->idMain3
    idVSxpt--READ_BY-->idMain3

    idMain3-->idMain4
    idFrag--SOURCED_BY-->idMain4

    idMain4-->idMain5
    idPDM--SOURCED_BY-->idMain5
    idPSDM--SOURCED_BY-->idMain5
    idPVS--SOURCED_BY-->idMain5


    idMain5-->idMain6
    idMain6--CREATES-->idOutMain
    idMain6--CREATES-->idOutCustom
    idMain6--CREATES-->idOutCode
    

    idMain6-->idMain7
    idMain7-->idFin

  classDef main     fill:#ffff1a, stroke:#000000,stroke-width:3px;
  classDef sourced  fill:#ffff99, stroke:#666600,stroke-width:3px;
  classDef xpt      fill:#b3b3ff, stroke:#0000cc,stroke-width:3px;
  classDef outTTL   fill:#ff6666, stroke:#000000,stroke-width:3px;
  
  classDef terminus fill:lightgreen,stroke:#000000,stroke-width:3px;

  class idMain1,idMain2,idMain3,idMain4,idMain5,idMain6,idMain7 main;
  class idMeta,idImport,idFrag,idPDM,idPSDM,idPVS sourced;
  class idDMxpt,idVSxpt xpt;
  class idOutMain,idOutCustom,idOutCode outTTL;
  class idPrefixes terminus;

")

# nodes to create
# 




#OLDE CODE EXAMPLE

#mermaid("
#graph TB
#	IDea86bba7(spath)-->IDd556d63d(centerv_PS0010_201702_2)
#	IDd556d63d(centerv_PS0010_201702_2)-->IDf3b61b38(4.compare)
#	IDf3b61b38(4.compare)-->ID98389409>End]
#	ID792369be((dva_mahap_datvs))-->IDf3b61b38(4.compare)
#	IDf77f28ca((dva_mahap_datvs))-->IDf3b61b38(4.compare)
#	IDf3b61b38(4.compare)-- creates -->ID16ab1491((dva_mahap_datvs))
#	ID98389409>End]-->NA
#
#	classDef macro      fill:#ffffb3,stroke:#e6e600,stroke-width:3px;
#	classDef dataset    fill:#9999ff,stroke:#3333ff,stroke-width:3px;
#	classDef valDataset fill:#9999ff,stroke:#b32d00,stroke-width:2px,stroke-dasharray: 5, 5;
#	classDef text       fill:#ccffcc,stroke:#00b300,stroke-width:3px;
#	classDef terminus   fill:#ccffcc,stroke:#00b300,stroke-width:3px;
#
#	class IDea86bba7,IDd556d63d,IDf3b61b38 macro;
#	class ID792369be dataset;
#	class IDf77f28ca valDataset;
#	class ID16ab1491 text;
#	class ID98389409 terminus;
#
#")
