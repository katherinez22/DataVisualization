library(shiny)

# Create a simple shiny page.
shinyUI(
  pageWithSidebar(
    headerPanel("US State Facts and Figures"),
    # Setup sidebar widgets.
    sidebarPanel(
      # Set the width of side bar panel.
      width = 3,
      
      # Add a slider input that controls the subset of the data.
      sliderInput("population", "Population Range:", min=350, max=22000, value=c(350, 22000), step=1000),
      sliderInput("income", "Income Range:", min=3000, max=6400, value=c(3000, 6400), step=100, format="$#,###"),
      sliderInput("illiteracy", "Illiteracy Date:", min=0.5, max=3.0, value=c(0.5, 3.0), step=0.1, format='#.#'),
      sliderInput("lifeExp", "Life Expectancy Range:", min=65, max=75, value=c(65, 75), step=1, format='##'),
      sliderInput("murder", "Murder Rate:", min=1.0, max=15.5, value=c(1.0, 15.5), step=0.5, format='##.#'),
      sliderInput("hsGrad", "High-school Graduates Rate:", min=37.5, max=67.5, value=c(37.5, 67.5), step=0.5, format='##.#'),      
      
      br(), 
      
      fluidRow(
         # Add radio buttons that allows users to filter which region to view.
         radioButtons("region", "Region:", c("All", "Northeast", "South", "North Central", "West"),
                      selected = c("All"))
      ), # fluidRow
      br(),
      
      # Add a slider input that controls the dot/line size, transparency and color palette of the plots.
      sliderInput("alpha", "Transparency:", min=0.1, max=1, value=0.5, step=0.1),
      selectInput("palette", "Colour Scheme:", c("Default","Accent","Set1","Set2","Set3","Dark2","Pastel1","Pastel2"))
    ), # sidebarPanel
    
    mainPanel(
      tabsetPanel(
        tabPanel("Bubble Plot", plotOutput("bubblePlot", width = "750px", height = "600px")),
        tabPanel("Scatterplot Matrix", plotOutput("multiplesPlot", width = "750px", height = "600px")),
        tabPanel("Parallel Coordinates Plot", plotOutput("parallelPlot", width = "750px", height = "600px"))
      ) # tabsetPanel
    ) # mainPanel
  ) # pageWithSidebar
) # shinyUI