#______________________________________________________________________________
# FILE: r/vis/SMSMapVis-app/ui.r
# DESC: UI for visualization of SMS maps 
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
#______________________________________________________________________________

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
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    #DEBUG,
    #DEBUG  textOutput("nsCond")
    ),
  titlePanel(HTML("<font class='appTitle'>SMS Map Visualization, PhUSE CTDasRDF Project</font>")),
  sidebarLayout(
    sidebarPanel(
      width=2,
      checkboxGroupInput("maps", HTML("<font class='include'>Include</font> Maps:"),
        c("DM"       = "DM",
          "SUPPDM"   = "SUPPDM",
          "EX"       = "EX",
          "VS"       = "VS",
          "Invest"   = "Invest",
          "Metadata" = "Graphmeta"),
          selected   = 'DM'),
      checkboxGroupInput("namespaces", HTML("<font class='exclude'>Exclude</font> Name Spaces:"),
        c("cdiscpilot01 (blue)" = "cdiscpilot01:",
          "cd01p (green)"       = "cd01p:",
          "code (dk green)"     = "code:",
          "study (orange)"      = "study:",
          "custom (red)"        = "custom:",
          "other IRI (yel)"     = "time:|owl:",
          "literal (white)"     = "xsd:")
        )
    ),
    mainPanel(
      tabsetPanel( type = "tabs",
        tabPanel( "Plot",
          width=10,
          visNetworkOutput("path_vis", height = '800px', width='800px')
        ),
        tabPanel("Triples",
          width=10,
          DT::dataTableOutput("triplesTable")
          
        ),
        tabPanel("Nodes",
          DT::dataTableOutput("nodesTable")
        ),  
        tabPanel("Edges",
          DT::dataTableOutput("edgesTable")
        )
      )
    )  
  )
)
