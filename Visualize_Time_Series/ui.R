library(shiny)

# Create a simple shiny page.
shinyUI(
  pageWithSidebar(
    titlePanel("Time Series Plots of Deaths in Car Accidents"),
    # Setup sidebar widgets.
    sidebarPanel(
      # Set the width of side bar panel.
      width = 3,
      
      # Add a slider input that controls the subset of the data.
      sliderInput("yearRange", "Year Range:", min=1969, max=1984, value=c(1969, 1984), step=1, format='####'),
      br(), 
      # Add radio buttons to view different plots.
      radioButtons("chartType", "Chart Type:", c("Line Chart", "Stacked Area Plot"),
                   selected = c("Line Chart")),
      br(),
      # Add a checkbox group that allows the user to filter which death to view. 
      checkboxGroupInput("deathType", "Death Type:", 
                         c("Drivers killed", "Front-seat passengers killed", 
                           "Rear-seat passengers killed"),
        selected = c("Drivers killed", "Front-seat passengers killed", 
                     "Rear-seat passengers killed")
      ),
      br(),
      # Add a drop-down box that allows the user to change color schemes
      selectInput("colorScheme", "Color Scheme:", 
        c("Default", "Accent", "Set1", "Set2", "Set3", "Dark2", "Pastel1", "Pastel2"),
        selected = "Default"
      ),
      # Add a download link
      HTML("<p align=\"center\">[ <a href=\"https://github.com/katherinez22/msan622/tree/master/homework5\">download source</a> ]</p>")
  ), # sidebarPanel
    
  mainPanel(
    plotOutput("Plot",width = "900px", height = "500px")
  ) # mainPanel
  ) # pageWithSidebar
) # shinyUI