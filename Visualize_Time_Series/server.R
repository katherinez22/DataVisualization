require(ggplot2)
require(shiny)
require(RColorBrewer)
require(scales)
require(reshape2) # melt

# Load the dataset
loadData <- function() {
  df <- Seatbelts
  times <- melt(time(df))  # creates x-axis for time series
  years <- floor(times)  # extract years for grouping later
  months <- melt(cycle(df))  # 1 through 12 for each year
  df <- cbind(times, years, months, data.frame(df))
  colnames(df)[1:3] <- c("time","year","month")
  # df <- data.frame(as.matrix(df))
  df$year <- factor(df$year,ordered=TRUE)
  return(df)
}

# Customize the theme
theme_legend <- function() {
  return(
    theme(
      legend.direction = "horizontal",
      legend.position = c(1, 1),
      legend.justification = c(1, 1),
      legend.title = element_blank(),
      legend.background = element_blank(),
      legend.key = element_blank(),
      legend.text = element_text(size=12,face = "italic"),
      text = element_text(size=14,face = "italic"),
      panel.border = element_blank(),
      panel.background = element_rect(fill = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey80", linetype = 3),
      #       panel.grid.major = element_blank(),
      axis.ticks.x = element_blank()
    )
  )
}

# Scale the year to remove the space between 1984 and 1985.
scale_year <- function() {
  return(
    scale_x_continuous(
      name = "Year",
      # using 1980 will result in gap
      limits = c(1969, 1984.917),
      expand = c(0, 0),
      # still want 1980 at end of scale
      breaks = c(seq(1969, 1984, 1), 1984.917),
      labels = function(x) {ceiling(x)}
    )
  )
}


# Create line and stacked area chart
getPlot <- function(localFrame, reaction) {
  yearRange = reaction$yearRange
  chartType = reaction$chartType
  deathType = reaction$deathType
  colorScheme = reaction$colorScheme
  # Recreate data frame to extract useful data
  df1 <- data.frame(localFrame[, c("year","drivers")], "Drivers killed")
  df2 <- data.frame(localFrame[, c("year","front")], "Front-seat passengers killed")
  df3 <- data.frame(localFrame[, c("year","rear")], "Rear-seat passengers killed")
  colnames(df1) <- c("year", "value", "label")
  colnames(df2) <- c("year", "value", "label")
  colnames(df3) <- c("year", "value", "label")
  df <- rbind(df1, df2, df3)
  time <- data.frame(rep(localFrame[,"time"], 3))
  df <- cbind(df, time)
  colnames(df) <- c("year", "value", "label", "time")
  indices <- which(
    (df$year >= yearRange[1] & df$year <= yearRange[2]) &
      (df$label %in% deathType)
  ) #indices
  df1 <- df[indices, ]
  
  if(dim(df1)[1]==0){
    empty<-data.frame(year=0,value=0,label="no data",time=0)
    g<-ggplot(empty)+geom_text(aes(x=time,y=value,label=label),size=20)+
      theme_legend()
  }
  else {
    if (chartType == "Line Chart"){
      p <- ggplot(df)
      p <- p+geom_line(aes(x=time, y=value, group=label), size=1.15, color="grey90")
      p <- p+geom_line(data=df1, aes(x=time, y=value, col=label), size=1.15)
      p <- p+scale_y_continuous(labels=comma, limits=c(0, 2700))
      # Select color palette.
      if(colorScheme != "Default") {
        p <- p+scale_color_brewer(type = "qual", palette = colorScheme, limits = levels(df$label))
      }#if
    } #if
    else if (chartType == "Stacked Area Plot"){
      p <- ggplot(df)
      p <- p+geom_area(aes(x=time, y=value, group=label), position="stack", fill="grey90", color="grey90")
      p <- p+geom_area(data=df1, aes(x=time, y=value, fill=label, color=label), position="stack")
      p <- p+scale_y_continuous(labels=comma, limits=c(0, 4500))
      # Select color palette.
      if(colorScheme != "Default") {
        p <- p+scale_fill_brewer(type = "qual", palette = colorScheme, limits = levels(df$label))
        p <- p+scale_color_brewer(type = "qual", palette = colorScheme, limits = levels(df$label))
      } # if
    } #else if
    # make it pretty
    p <- p + xlab("Time")
    p <- p + ylab("Death")
    p <- p + theme_legend()
    p <- p + scale_year()
    p <- p + coord_fixed(ratio = 1 / 600)
  }
  return(p)
} # getLine


##### GLOBAL OBJECTS #####

# Shared data
globalData <- loadData()

##### SHINY SERVER #####
# Create shiny server.
shinyServer(function(input, output) {
  cat("Press \"ESC\" to exit...\n")
  # Copy the data frame 
  localFrame <- globalData
  
  getReaction <- reactive({
    return(list(yearRange = input$yearRange, 
                chartType = input$chartType,
                deathType = input$deathType,
                colorScheme = input$colorScheme
    ))
  }) # getReaction
  
  # Output Plots.
  output$Plot <- renderPlot({print(getPlot(localFrame, getReaction()))}) # output
}) # shinyServer