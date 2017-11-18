require(shiny)


# Define user interface
shinyUI(fluidPage(  
  tags$style(type="text/css",
             ".shiny-output-error { visibility: hidden; }",
             ".shiny-output-error:before { visibility: hidden; }"),
  tags$head(tags$style("#distPlot{height:1300px, !important;}")),
  tags$head(tags$style("#timePlot{height:300px; !important;}")),
  fluidRow(
    column(6, align = 'center', uiOutput("selectPlayer")), 
    column(6, align = 'center', uiOutput("selectMetric"))),
  fluidRow(
    h4('Performance over time', align = 'center'),
    plotOutput("timePlot")),
  fluidRow(
    h4('Performance summary', align = 'center'),
    plotOutput("distPlot", height = '800px')
      )
    )
  )

