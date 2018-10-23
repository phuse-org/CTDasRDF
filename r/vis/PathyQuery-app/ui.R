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
  titlePanel(HTML("Path Queries, CTDasRDF Project")),
  fluidRow(
    column(4, textInput('startNode', label=h4("Start Node"),  width = '400px', value = "cdiscpilot01:Person_01-701-1015")),
    column(3, selectInput('hops',label = h4("Hops"), width= '100px', choices = list('1' = 1, '2' = 2, '3' = 3),
      selected = 1))
  ),
  fluidRow(
    column = 12,
    offset = 0, 
    style='padding:5px;',
    visNetworkOutput("path_vis", height = '800px')
  )
)

