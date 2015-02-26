library("dplyr")

count_by_month <- readRDS("count_by_month.RDS")

shinyServer(function(input, output) {
  
  output$main_plot <- renderPlot({
    id <- courts$id[courts$name == input$court]
    counts <- select(filter(count_by_month, court_id == id), month, count)
    
    plot(counts, type = "l",
         main = input$court)
    
  })
})
