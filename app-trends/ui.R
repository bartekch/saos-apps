library("saos")
data(courts)

shinyUI(fluidPage(
  titlePanel("Obciążenie sądów powszechnych"),
  
  selectInput(inputId = "court",
              label = "Sąd:",
              choices = courts$name,
              selected = courts$name[1]),
  
  plotOutput(outputId = "main_plot", height = "300px")
  
))
