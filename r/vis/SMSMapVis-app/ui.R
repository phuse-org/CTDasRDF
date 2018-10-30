#______________________________________________________________________________
# $HeadURL: http://brasvnap001/prod-gsp/oaa/LinkedData/RBMProgramFlow/r/vis/MacroImpactKRI-app/ui.R $
# $Rev: 393 $
# $Date: 2018-10-02 16:36:05 -0400 (Tue, 02 Oct 2018) $
# $Author: U041939 $
# _____________________________________________________________________________
# DESC: UI for SMS Map visualizatoin
#       User can choose: 
#        1. The map file(s) to display
#        2. The namespaces within map files (NOT YET IMPLMENTED)
# SRC : 
# IN  :
# OUT :
# REQ :
# NOTE: 
# REF:  Here for late formating of checkbox group inputs to include HTML and images
#        https://stackoverflow.com/questions/46354705/html-formatting-of-checkboxs-icons-and-text-for-shiny
# TODO: 
# _____________________________________________________________________________
fluidPage(
  
  
  tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
      textOutput("selectedMaps")
    ),
  titlePanel(HTML("SMS Map Visualization, PhUSE CTDasRDF Project")),
  sidebarLayout(
    sidebarPanel(
      width=2,
      checkboxGroupInput("maps", "Maps:",
        c("DM"       = "DM",
          "SUPPDM"   = "SUPPDM",
          "EX"       = "EX",
          "VS"       = "VS",
          "Invest"   = "Invest",
          "Metadata" = "Graphmeta"),
          selected   = 'DM'),
      checkboxGroupInput("namespaces", "Name Space: NOT YET IMPLEMENTED",
        c("cdiscpilot01 (blue)" = "cdiscpilot01",
          "cd01p (green)"       = "cd01p",
          "code (dk green)"      = "code",
          "study (orange)"      = "study",
          "custom (red)"        = "custom",
          "literal (white)"     = "literal"),
           selected = c('cdiscpilot01','cd01p', 'code', 'study', 'custom', 'literal'))
    ),
    mainPanel(
      width=10,
      visNetworkOutput("path_vis", height = '800px')
    )
  )
)
