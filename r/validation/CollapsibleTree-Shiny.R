###############################################################################
# FILE: CollapsibleTree-Shiny.R
# DESC: Collapsible node tree to compare ontology and derived nodes
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: Early dev with bogus data
#       Notes on Shiny bindings
#       https://www.rdocumentation.org/packages/collapsibleTree/versions/0.1.5/topics/collapsibleTree-shiny
# TODO: 
###############################################################################

library(shiny)
library(collapsibleTree)
library(DT)

org <- data.frame(
    Manager = c(
        NA, "Ana", "Ana", "Bill", "Bill", "Bill", "Claudette", "Claudette", "Danny",
        "Fred", "Fred", "Grace", "Larry", "Larry", "Nicholas", "Nicholas"
    ),
    Employee = c(
        "Ana", "Bill", "Larry", "Claudette", "Danny", "Erika", "Fred", "Grace",
        "Henri", "Ida", "Joaquin", "Kate", "Mindy", "Nicholas", "Odette", "Peter"
    ),
    Title = c(
        "President", "VP Operations", "VP Finance", "Director", "Director", "Scientist",
        "Manager", "Manager", "Jr Scientist", "Operator", "Operator", "Associate",
        "Analyst", "Director", "Accountant", "Accountant"
    )
)


ui <- fluidPage(
  # Select start node row
  fluidRow(
    column(6, 
      h4("Ontology"),
      selectInput("ontRoot", "RootNode:",
              c("Person_1" = "Person_datdasfasdfasdsd",
                "RefInterval" = "RefInterval_xxxxx_xxxx",
                "DemogColl" = "DemographicDataCollecion_Xxxxxxx"))
    ),
    column(6, 
      h4("Derive"),
      selectInput("ontRoot", "RootNode:",
              c("Person_1" = "Person_datdasfasdfasdsd",
                "RefInterval" = "RefInterval_xxxxx_xxxx",
                "DemogColl" = "DemographicDataCollecion_Xxxxxxx"))
    )
  ),
  # Diagram row
  fluidRow(
    column(6, 
      wellPanel(
        collapsibleTreeOutput("tree1", width="100%", height="200px")
      )
    ),
    column(6, 
      wellPanel(
        collapsibleTreeOutput("tree2" , width="100%", height="200px")
      )
    )
  ),

  # Data tables row
  fluidRow(
    column(6, 
      DT::dataTableOutput("ontData")
    ),
    column(6, 
      DT::dataTableOutput("derData")
    )
  )
)

server <- function(input, output, session) {

  output$tree1 <- renderCollapsibleTree({
    collapsibleTreeNetwork(
      org,
      c("Manager", "Employee"),
      width = "100%"
    )
  })
  output$tree2 <- renderCollapsibleTree({
    collapsibleTreeNetwork(
      org,
      c("Manager", "Employee"),
      width = "100%"
    )
  })
  output$ontData = DT::renderDataTable({org})
  
  output$derData = DT::renderDataTable({org})

}

shinyApp(ui = ui, server = server)