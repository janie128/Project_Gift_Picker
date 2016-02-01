# server.R
library(shiny)
library(ggplot2)

reviewCount <- read.csv("data/reviewCount.csv")
reviewCount <- reviewCount[(reviewCount$n < 300),]

shinyServer(function(input, output) {
  
  dataInput <- reactive({  
    boxoffice[1:input$range,]
  })

  output$histPlot <- renderPlot({
    qplot(reviewCount$n, geom="histogram",
          fill=I("blue"), col=I("red"), alpha = I(.3),
          binwidth=input$bins,
          xlab="Review Count", ylab="Frequency", xlim=c(0,300))
    
  })
})