# server.R
library(shiny)
library(ggplot2)
library(Rmisc)


testWords <- read.csv("data/testWords.csv")
test2Words <- read.csv("data/test2Words.csv")

shinyServer(function(input, output) {
  plot1 <- reactive({
    ggplot(subset(testWords, freq >= input$freq1), aes(word, freq)) +
      geom_bar(stat="identity", alpha=0.8, aes(fill=colour)) +
      ggtitle("Snap Circuit Reviews Keywords") + ylab("Frequency") +
      theme(plot.title = element_text(lineheight=.8, face="bold",size=16)) +
      theme(axis.text.x=element_text(angle=45, hjust=1, size=16), axis.title.x = element_blank()) +
      theme(legend.position="none")
  })
  
  plot2 <- reactive({
    ggplot(subset(test2Words, freq >= input$freq2), aes(word, freq)) +
      geom_bar(stat="identity", alpha=0.8, aes(fill=colour)) +
      ggtitle("Science Kit Reviews Keywords") + ylab("Frequency") +
      theme(plot.title = element_text(lineheight=.8, face="bold",size=16)) +
      theme(axis.text.x=element_text(angle=45, hjust=1, size=16), axis.title.x = element_blank()) +
      theme(legend.position="none")
  })
  
  output$wordPlot <- renderPlot({  
    multiplot(plot1(),plot2(),cols=2)
  })
})