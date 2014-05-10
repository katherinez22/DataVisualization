library(ggplot2)
library(shiny)
library(GGally)


#create a function for loading and transforming data
loadData <- function(){
  df <- data.frame(state.x77,
                   State = state.name,
                   Abbrev = state.abb,
                   Region = state.region,
                   Division = state.division)
  return(df)
} # end_loadData

# Plot Bubble Plot
getBubble <- function(localFrame, reaction, region) {
  population = reaction$population
  income = reaction$income
  illiteracy = reaction$illiteracy
  lifeExp = reaction$lifeExp
  murder = reaction$murder
  hsGrad = reaction$hsGrad
  alpha = reaction$alpha
  palette = reaction$palette
  
  indices <- which(
    (localFrame$Population >= population[1] & localFrame$Population <= population[2]) &
      (localFrame$Income >= income[1] & localFrame$Income <= income[2]) &
      (localFrame$Illiteracy >= illiteracy[1] & localFrame$Illiteracy <= illiteracy[2]) & 
      (localFrame$Life.Exp >= lifeExp[1] & localFrame$Life.Exp <= lifeExp[2]) &
      (localFrame$Murder >= murder[1] & localFrame$Murder <= murder[2]) &
      (localFrame$HS.Grad >= hsGrad[1] & localFrame$HS.Grad <= hsGrad[2]) &
      (localFrame$Region %in% region)
  )
  # Create two subsets
  localFrameSub <- localFrame[indices,]
  localFrameUnsub <- localFrame[-indices,]
  
  if (length(indices) == 0) {
    localFrameUnsub <- localFrame
  }
  
  # Create basic plot
  p_bubble <- ggplot(localFrameSub, aes(x = Income,
                                        y = Life.Exp,
                                        color = Region,
                                        size = Population)
  ) #end_p_bubble
  
  # Add more layers for customization
  # Add labels and limits.
  p_bubble <- p_bubble + scale_x_continuous(name="Income per capita (dollars)", limits=c(3000, 6500))
  p_bubble <- p_bubble + scale_y_continuous(name="life expectancy (years)", limits=c(65, 75))
  p_bubble <- p_bubble + ggtitle("The Wealth & Health of United States")
  p_bubble <- p_bubble + labs(color = "Region")
  # Adjust plot title.
  p_bubble <- p_bubble + theme(plot.title = element_text(size = rel(1.5), face = "bold"))
  # Adjust panel.
  p_bubble <- p_bubble + theme(panel.background = element_rect(fill = NA))
  p_bubble <- p_bubble + theme(panel.border = element_blank())
  p_bubble <- p_bubble + theme(panel.grid.major = element_line(color = "grey90", linetype = 3))
  p_bubble <- p_bubble + theme(panel.grid.minor = element_blank())
  # Adjust legend.
  p_bubble <- p_bubble + theme(legend.title = element_text(face = "italic")) 
  p_bubble <- p_bubble + theme(legend.text = element_text(face = "italic")) 
  p_bubble <- p_bubble + theme(legend.key = element_rect(fill = NA))
  p_bubble <- p_bubble + theme(legend.direction = "vertical") 
  p_bubble <- p_bubble + theme(legend.background = element_blank()) 
  p_bubble <- p_bubble + scale_size_area(breaks=c(500, 5000, 10000, 20000), "Population", max_size=20)
  p_bubble <- p_bubble + guides(color = guide_legend(override.aes = list(size = 5)))
  
  # ggplot2 default scheme
  ggColor <- function(n) {
    hcl(h=seq(15, 375, length=colorLevels+1), l=65, c=100)[1:n]
  }
  
  # Create the color palettes
  colorLevels <- length(levels(localFrame$Region))
  if (palette == "Default") {
    cols <- ggColor(colorLevels)
  } else {
    cols <- brewer_pal(type="qual", palette=palette)(colorLevels)
  }
  
  # Subset palette for those data points to be reactioned
  cols <- cols[which(levels(localFrame$Region) %in% region)]
  # Draw the greyed points
  if (nrow(localFrameUnsub) != 0) { 
    p_bubble <- p_bubble + geom_point(data=localFrameUnsub, position = "jitter", color='grey80', alpha=alpha)
  }
  if (nrow(localFrameSub) != 0) {
    p_bubble <- p_bubble + geom_point(position = "jitter", alpha=alpha) +
      scale_colour_manual(values = cols)
  }  
  return(p_bubble) 
} # end_getBubble

# Plot Small Multiples Plot
getMultiples <- function(localFrame, reaction, region) {
  population = reaction$population
  income = reaction$income
  illiteracy = reaction$illiteracy
  lifeExp = reaction$lifeExp
  murder = reaction$murder
  hsGrad = reaction$hsGrad
  alpha = reaction$alpha
  palette = reaction$palette
  
  indices <- which(
    (localFrame$Population >= population[1] & localFrame$Population <= population[2]) &
      (localFrame$Income >= income[1] & localFrame$Income <= income[2]) &
      (localFrame$Illiteracy >= illiteracy[1] & localFrame$Illiteracy <= illiteracy[2]) & 
      (localFrame$Life.Exp >= lifeExp[1] & localFrame$Life.Exp <= lifeExp[2]) &
      (localFrame$Murder >= murder[1] & localFrame$Murder <= murder[2]) &
      (localFrame$HS.Grad >= hsGrad[1] & localFrame$HS.Grad <= hsGrad[2]) &
      (localFrame$Region %in% region)
  )
  localFrameSub <- localFrame[indices,]
  localFrameUnsub <- localFrame[-indices,]
  
  if (length(indices) == 0) {
    localFrameUnsub <- localFrame
  }
  
  # ggplot2 default scheme
  ggColor <- function(n) {
    hcl(h=seq(15, 375, length=colorLevels+1), l=65, c=100)[1:n]
  }
  
  # Create the color palettes
  colorLevels <- length(levels(localFrame$Region))
  if (palette == "Default") {
    cols <- ggColor(colorLevels)
  } else {
    cols <- brewer_pal(type="qual", palette=palette)(colorLevels)
  }
  
  # Subset palette for those data points to be reactioned
  cols <- cols[which(levels(localFrame$Region) %in% region)]
  
  if (nrow(localFrameUnsub) != 0) {
    p_multiples <- ggpairs(localFrameUnsub, 
                           # Columns to include in the matrix
                           columns = 1:6,
                           # What to include above diagonal
                           # list(continuous = "points") to mirror
                           # "blank" to turn off
                           upper = "blank",
                           # What to include below diagonal
                           lower = list(continuous = "points"),
                           # What to include in the diagonal
                           diag = list(continuous = "density"),
                           # How to label inner plots
                           # internal, none, show
                           axisLabels = "none",
                           # Other aes() parameters
                           colour = "Region"
    ) # end_p_multiples
    # Remove grid from plots along diagonal
    for (i in 1:6) {
      # Get plot out of matrix
      inner = getPlot(p_multiples, i, i);
      # Add any ggplot2 settings you want
      inner = inner + theme(panel.grid = element_blank()) + scale_colour_manual(values = cols);   
      # Put it back into the matrix
      p_multiples <- putPlot(p_multiples, inner, i, i);
    }  # end_for
  } # end_if
  if (nrow(localFrameSub) != 0) {
    p_multiples <- ggpairs(localFrameSub, 
                           # Columns to include in the matrix
                           columns = 1:6,
                           # What to include above diagonal
                           # list(continuous = "points") to mirror
                           # "blank" to turn off
                           upper = "blank",
                           # What to include below diagonal
                           lower = list(continuous = "points"),
                           # What to include in the diagonal
                           diag = list(continuous = "density"),
                           # How to label inner plots
                           # internal, none, show
                           axisLabels = "none",
                           # Other aes() parameters
                           colour = "Region"
    ) # end_p_multiples
    # Remove grid from plots along diagonal
    for (i in 1:6) {
      # Get plot out of matrix
      inner = getPlot(p_multiples, i, i);
      # Add any ggplot2 settings you want
      inner = inner + theme(panel.grid = element_blank()) + scale_colour_manual(values = cols);   
      # Put it back into the matrix
      p_multiples <- putPlot(p_multiples, inner, i, i);
    }  # end_for
  } # end_if
  
  return(p_multiples) 
} # end_getMultiples


# Plot Parallel Coordinates Plot
getParallel <- function(localFrame, reaction, region) {
  population = reaction$population
  income = reaction$income
  illiteracy = reaction$illiteracy
  lifeExp = reaction$lifeExp
  murder = reaction$murder
  hsGrad = reaction$hsGrad
  alpha = reaction$alpha
  palette = reaction$palette
  
  indices <- which((localFrame$Population >= population[1] & localFrame$Population <= population[2]) &
                     (localFrame$Income >= income[1] & localFrame$Income <= income[2]) &
                     (localFrame$Illiteracy >= illiteracy[1] & localFrame$Illiteracy <= illiteracy[2]) & 
                     (localFrame$Life.Exp >= lifeExp[1] & localFrame$Life.Exp <= lifeExp[2]) &
                     (localFrame$Murder >= murder[1] & localFrame$Murder <= murder[2]) &
                     (localFrame$HS.Grad >= hsGrad[1] & localFrame$HS.Grad <= hsGrad[2]) &
                     (localFrame$Region %in% region)
  ) # end_indices
  
  # Create two subsets
  localFrameSub <- localFrame[indices,]
  localFrameUnsub <- localFrame[-indices,]
  
  if (length(indices) == 0) {
    localFrameUnsub <- localFrame
  }
  
  # ggplot2 default scheme
  ggColor <- function(n) {
    hcl(h=seq(15, 375, length=colorLevels+1), l=65, c=100)[1:n]
  }
  
  # Create the color palettes
  colorLevels <- length(levels(localFrame$Region))
  if (palette == "Default") {
    cols <- ggColor(colorLevels)
  } else {
    cols <- brewer_pal(type="qual", palette=palette)(colorLevels)
  }
  
  # Subset palette for those data points to be reactioned
  cols <- cols[which(levels(localFrame$Region) %in% region)]
  if (nrow(localFrameUnsub) != 0) {
    p_parallel <- ggparcoord(data = localFrameUnsub,         
                             # Which columns to use in the plot
                             columns = 1:6, 
                             # Which column to use for coloring data
                             groupColumn = "Region", 
                             # Do not show points
                             showPoints = FALSE,
                             # Turn on alpha blending for dense plots
                             alphaLines = alpha,
                             # Turn off box shading range
                             shadeBox = NULL, 
                             # Will normalize each column's values to [0, 1]
                             scale = "uniminmax" # try "std" also
    )
  }
  if (nrow(localFrameSub) != 0) {
    p_parallel <- ggparcoord(data = localFrameSub,         
                             # Which columns to use in the plot
                             columns = 1:6, 
                             # Which column to use for coloring data
                             groupColumn = "Region", 
                             # Do not show points
                             showPoints = FALSE,
                             # Turn on alpha blending for dense plots
                             alphaLines = alpha,
                             # Turn off box shading range
                             shadeBox = NULL, 
                             # Will normalize each column's values to [0, 1]
                             scale = "uniminmax" # try "std" also
    )
    p_parallel <- p_parallel + scale_colour_manual(values = cols)
  }
  
  # Add more layers for customization
  # Start with a basic theme
  p_parallel <- p_parallel + theme_minimal()
  # Decrease amount of margin around x, y values
  p_parallel <- p_parallel + scale_y_continuous(expand = c(0.02, 0.02))
  p_parallel <- p_parallel + scale_x_discrete(expand = c(0.02, 0.02))
  # Remove axis ticks and labels
  p_parallel <- p_parallel + theme(axis.ticks = element_blank())
  p_parallel <- p_parallel + theme(axis.title = element_blank())
  p_parallel <- p_parallel + theme(axis.text.y = element_blank())
  # Clear axis lines
  p_parallel <- p_parallel + theme(panel.grid.minor = element_blank())
  p_parallel <- p_parallel + theme(panel.grid.major.y = element_blank())
  # Darken vertical lines
  p_parallel <- p_parallel + theme(panel.grid.major.x = element_line(color = "#bbbbbb"))
  # Move label to bottom
  p_parallel <- p_parallel + theme(legend.position = "bottom")
  # Figure out y-axis range after GGally scales the data
  min_y <- min(p_parallel$data$value)
  max_y <- max(p_parallel$data$value)
  pad_y <- (max_y - min_y) * 0.1
  # Calculate label positions for each veritcal bar
  lab_x <- rep(1:6, times = 2) # 2 times, 1 for min 1 for max
  lab_y <- rep(c(min_y - pad_y, max_y + pad_y), each = 6)
  # Get min and max values from original dataset
  lab_z <- c(sapply(localFrame[, 1:6], min), sapply(localFrame[, 1:6], max))
  # Convert to character for use as labels
  lab_z <- as.character(lab_z)
  # Add labels to plot
  p_parallel <- p_parallel + annotate("text", x = lab_x, y = lab_y, label = lab_z, size = 3)
  
  return(p_parallel) 
} # end_getParallel





##### GLOBAL OBJECTS #####

# Shared data
globalData <- loadData()

##### SHINY SERVER #####

# Create shiny server.
shinyServer(function(input, output) {
  cat("Press \"ESC\" to exit...\n")
  
  # Copy the data frame (don't want to change the data
  # frame for other viewers)
  localFrame <- globalData
  
  getReaction <- reactive({
    return(list(population = input$population,
                income = input$income, 
                illiteracy = input$illiteracy,
                lifeExp = input$lifeExp,
                murder = input$murder,
                hsGrad = input$hsGrad,
                alpha = input$alpha,
                palette = input$palette
    ))
  }) # end_getReaction
  
  getRegion <- reactive({
    result <- levels(localFrame$Region)
    if(input$region == "All") {
      return(result)
    }
    else {
      return(input$region)
    }
  }) # end_getRegion
  
  
  # Output Bubble Plot.
  output$bubblePlot <- renderPlot(
{
  # Use the function to generate the plot.
  bubblePlot <- getBubble(localFrame, getReaction(), getRegion())
  # Output the plot.
  print(bubblePlot)
}
  ) # end_output

# Output Bubble Plot.
output$multiplesPlot <- renderPlot(
{
  # Use the function to generate the plot.
  multiplesPlot <- getMultiples(localFrame, getReaction(), getRegion())
  # Output the plot.
  print(multiplesPlot)
}
) # end_output

# Output Bubble Plot.
output$parallelPlot <- renderPlot(
{
  # Use the function to generate the plot.
  parallelPlot <- getParallel(localFrame, getReaction(), getRegion())
  # Output the plot.
  print(parallelPlot)
}
) # end_output

}) # end_shinyServer
