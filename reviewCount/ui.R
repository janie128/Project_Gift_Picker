# ui.R
# To deploy:
# library(shinyapps)
# shinyapps::deployApp('path/to/your/app')
# https://janiec.shinyapps.io/reviewCount/

library(shiny)

shinyUI(fluidPage(
  titlePanel("Amazon Toys Product Review Count"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Customize the binwidth"),
      sliderInput("bins",
                  "Binwidth:",
                  min = 1, max = 50,
                  value = 5, step = 1)
    ),
    
    mainPanel(h3("Distribution of Review Counts per Product"),
              plotOutput("histPlot"),
              p("This histogram shows the distribution of products and their review counts. 
                Products with review counts less than 5 have been omitted for clarity."),
              p("This plot shows that there is a large number of products with sufficient number of reviews 
                to extract keywords."))
  )
))