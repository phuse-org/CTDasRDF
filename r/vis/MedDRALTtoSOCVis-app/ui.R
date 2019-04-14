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
      h4("MedDRA Tracing from Lowest Level Term (LLT) to System Organ Class(SOC)"),
      # textInput('rootNode', "LT value", value = "M10003047")
      selectInput("rootNode", "LLT :",
                  c("M10003047" = "M10003047",
                    "M10003058" = "M10003058",
                    "M10003851" = "M10003851",
                    "M10012727" = "M10012727"),
                  selected = "M10003047")
    )
  ),
  # Tree Diagram
  fluidRow(
    column(12, 
      wellPanel(
        collapsibleTreeOutput("medTree", width="100%", height="400px")
      )
    )
  )
)