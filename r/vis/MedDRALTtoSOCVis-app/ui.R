#______________________________________________________________________________
# FILE: r/vis/MedDRALTtoSOCVis-app/server.R
# DESC: MedDRA visualization from LT to SOC 
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# REF:  
# TODO: 
#______________________________________________________________________________
fluidPage(

  # Node selection
  fluidRow(
    column(6, 
      h4("MedDRA tracing from LT to SOC"),
      textInput('rootNode', "LT value", value = "M10003047")
    )
  ),
  # Tree Diagram
  fluidRow(
    column(12, 
      wellPanel(
        collapsibleTreeOutput("medTree", width="100%", height="800px")
      )
    )
  )
)