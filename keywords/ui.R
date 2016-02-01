# ui.R
# To deploy:
# library(shinyapps)
# shinyapps::deployApp('path/to/your/app')
# https://janiec.shinyapps.io/keywords/

library(shiny)

shinyUI(fluidPage(
  titlePanel("Amazon Toys Product Keyword Features"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Customize for \"Snap Circuits\""),
      sliderInput("freq1",
                  "Frequency threshold:",
                  min = 150, max = 400,
                  value = 200, step = 10),
      helpText("Customize for \"Science Kit\""),
      sliderInput("freq2",
                  "Frequency threshold:",
                  min = 30, max = 200,
                  value = 48, step = 5)
    ),
    
    mainPanel(h3("Keywords for two example cases"),
              plotOutput("wordPlot"),
              p("This plot shows the keywords extracted from product reviews for two test cases."),
              p("The keyword \"learning\" as discussed in the preliminary analysis is highlighted."))
  )
))