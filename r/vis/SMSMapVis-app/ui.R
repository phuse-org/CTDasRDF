#______________________________________________________________________________
# $HeadURL: http://brasvnap001/prod-gsp/oaa/LinkedData/RBMProgramFlow/r/vis/MacroImpactKRI-app/ui.R $
# $Rev: 393 $
# $Date: 2018-10-02 16:36:05 -0400 (Tue, 02 Oct 2018) $
# $Author: U041939 $
# _____________________________________________________________________________
# DESC: Left: Hierarchical network graph of KRI to Macro Relations
#       Right: Details of a selected node. Only visible when a node is selected
# SRC :
# IN  :
# OUT :
# REQ :
# NOTE: 
# TODO: 
# _____________________________________________________________________________
fluidPage(
  
  
  tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
  titlePanel(HTML("SMS Map Visualization, PhUSE CTDasRDF Project")),
  fluidRow(
    column(2,
           checkboxGroupInput("maps", "Maps:",
             c("DM" = "DM",
             "EX" = "EX",
             "VS" = "VS")),
           checkboxGroupInput("namespace", "Name Space:",
             c("cdiscpilot01" = "cdiscpilot01",
               "cd01p"        = "cd01p",
               "code"         = "code",
               "study"        = "study",
               "custom"       = "custom",
               "literal"      = "literal"),
           selected = c('cdiscpilot01','cd01p', 'code', 'study', 'custom', 'literal')
          )
    ),
    column(10,
           offset = 0, 
           style='padding:5px;',
           visNetworkOutput("path_vis", height = '800px'))
  )
)
