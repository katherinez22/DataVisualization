require(ggplot2)
require(shiny)
require(RColorBrewer)
require(scales)
require(wordcloud)
require(Hmisc)
require(ggmap)
require(maptools)
require(plyr)
library(GGally)

# Load the dataset
loadData <- function() {
  df <- read.csv("NamesOf50States.csv")
  return(df)
}

# Customize the theme
theme_legend_map <- function() {
  return(
    theme(
      legend.background = element_blank(),
      legend.position = c(1, 0.3),
      legend.justification = c(1, 0.3),
      legend.title = element_text(size=15,face = "bold"),
      legend.text = element_text(size=13),
      panel.border = element_blank(),
      panel.background = element_rect(fill = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank(),
      axis.ticks.x = element_blank(),
      axis.ticks.y = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank()
    )
  )
}

theme_legend_small <- function() {
  return(
    theme(
      panel.border = element_blank(),
      panel.background = element_rect(fill = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey70", linetype = 3),
      axis.ticks.y = element_blank(),
      axis.title = element_text(size = rel(1.2), face = "bold"),
      strip.background=element_rect(fill="white", size = rel(1.2)),
      text=element_text(family="Georgia", face="italic")
    )
  )
}

theme_legend_bar <- function() {
  return(
    theme(
      panel.border = element_blank(),
      panel.background = element_rect(fill = NA),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_line(color = "grey70", linetype = 3),
      axis.ticks = element_blank(),
      axis.title = element_text(size = rel(1.2), face = "bold"),
      strip.background=element_rect(fill="white", size = rel(1.2)),
      text=element_text(family="Georgia", face="italic")
    )
  )
}

# Label formatter for numbers in thousands.
k_formatter <- function(x) {
  return(sprintf("%gk", round(x / 1000)))
}


# Plot the word cloud
getWordCloud <- function(df, reaction){
  stateName = reaction$stateName
  year = reaction$year
  wordNumber = reaction$wordNumber
  if (reaction$sexChoose == "Female"){
    sexChoose = "F"
  }
  else {sexChoose = "M"}
  if (stateName == "All"){
    indices <- which(df$Year == year & df$Sex == sexChoose)
    new_df <- df[indices, ]
    new_df <- aggregate(Number ~ Sex+Year+Name, new_df, sum)
    cloud_df <- head(new_df[sort.list(new_df$Number, decreasing=TRUE),], wordNumber)
  }
  else {
    indices <- which(df$State == stateName & df$Year == year & df$Sex == sexChoose)
    cloud_df <- head(df[indices, ][sort.list(df[indices, ]$Number, decreasing=TRUE),], wordNumber)
  }
  set.seed(375) # to make it reproducibles
  # plot the word cloud
  return(wordcloud(words = cloud_df$Name, freq = cloud_df$Number,
            scale = c(5, 0.3),
            random.order = FALSE,
            rot.per = 0.15,
            colors = brewer.pal(8, "Dark2"),
            random.color = TRUE,
            use.r.layout = FALSE
  )) # end return
} # end getWordCloud


# Plot the Map
getMap <- function(df, reaction){
  nameSearch = capitalize(tolower(reaction$nameSearch))
  year = reaction$year
  colorScheme = reaction$colorScheme
  if (reaction$sexChoose == "Female"){
    sexChoose = "F"
  }
  else {sexChoose = "M"}
  indices <- which(df$Name == nameSearch & df$Year == year & df$Sex == sexChoose)
  new_df <- df[indices,]
  us_state_map <- map_data('state')
  map_df <- merge(new_df, us_state_map, by = 'region')
  map_df <- arrange(map_df, order)
  states <- data.frame(state.center, state.abb)
  p <- ggplot(data = us_state_map, aes(x = long, y = lat, group = group))
  p <- p + geom_polygon(fill = "white")
  p <- p + geom_path(colour = 'grey', linestyle = 2)
  p <- p + geom_text(data=states, aes(x=x, y=y, label=state.abb, group = NULL), size = 5)
  p <- p + theme_legend_map()
  if (length(unique(map_df$Name)) > 0) {
    p <- p + geom_polygon(data = map_df, aes(fill = cut_number(Number, 5)))
    p <- p + geom_path(colour = 'grey', linestyle = 2)
    p <- p + scale_fill_brewer("Number of Names", type = "seq", palette=colorScheme)
    p <- p + geom_text(data=states, aes(x=x, y=y, label=state.abb, group = NULL), size = 5)
  }
  return(p)
}

# Get small multiples
getSmall <- function(df, reaction){
  division = reaction$division
  if (length(reaction$sexChoose) == 0){
    if (division == "All") {
      new_df <- df
    }
    else {
      indices <- which(df$Division == division)
      new_df <- df[indices, ]
    }
  }
  else {
    if (reaction$sexChoose == "Female"){
      sexChoose = "F"
    }
    else {sexChoose = "M"}
    if (division == "All") {
      indices <- which(df$Sex == sexChoose)
    }
    else {
      indices <- which(df$Division == division & df$Sex == sexChoose)
    }
    new_df <- df[indices, ]
  }
  new_df2 <- aggregate(Number ~ State+Year, new_df, sum)
  p <- ggplot(new_df2, aes(x=Year, y=Number))
  p <- p + geom_path(alpha=0.8, color="#386cb0", size=1.2)
  p <- p + geom_point(alpha=0.9, color="#984ea3", size=1.5)
  p <- p + scale_y_continuous(name="Number of Baby with Top Names", label = k_formatter)
  p <- p + facet_wrap(~ State)
  p <- p + coord_polar(theta = "x", direction = -1)
  p <- p + theme_legend_small()
  return(p)
}


# Get bar chart
getBar <- function(df, reaction){
  year <- reaction$year
  sort <- reaction$sort
  indices <- which(df$Year == year)
  new_df <- df[indices, ]
  new_df2 <- aggregate(Number ~ Division, new_df, sum)
  new_df3 <- new_df2[order(new_df2$Number, decreasing=TRUE), ]
  if (sort == "Alphabetical") {
    p <- ggplot(new_df2, aes(x=Division, y=Number))
    p <- p + scale_x_discrete(limits=new_df2$Division)
  }
  else {
    p <- ggplot(new_df3, aes(x=Division, y=Number))
    p <- p + scale_x_discrete(limits=new_df3$Division)
  }
  p <- p + geom_bar(stat="identity", width=0.7, fill="#CC79A7")
  p <- p + xlab("Division")
  p <- p + scale_y_continuous(name="Number of Baby with Top Names", label = k_formatter, expand = c(0,0))
  p <- p + theme_legend_bar()
  return(p)
}


# Get raw data
getTable <- function(df, reaction){
  nameSearch = capitalize(tolower(reaction$nameSearch))
  new_df <- subset(df, grepl(nameSearch, Name))
  year <- reaction$year
  indices <- which((new_df$Year >= year[1] & new_df$Year <= year[2]))
  new_df <- new_df[indices,-1]
  new_df$region <- toupper(new_df$region)
  colnames(new_df) <- c("State Abb.", "State Name", "Division", "Gender", "Year", "Baby Name", "Frequency")
  return(new_df)
}



##### GLOBAL OBJECTS #####

# Shared data
globalData <- loadData()

##### SHINY SERVER #####
# Create shiny server.
shinyServer(function(input, output) {
  cat("Press \"ESC\" to exit...\n")
  # Copy the data frame
  localFrame <- globalData

  getReaction1 <- reactive({
    return(list(stateName = input$stateName1,
                year = input$year1,
                sexChoose = input$sexChoose1,
                wordNumber = input$wordNumber1
    ))
  }) # getReaction1

  getReaction2 <- reactive({
    return(list(nameSearch = input$nameSearch2,
                year = input$year2,
                sexChoose = input$sexChoose2,
                colorScheme = input$colorScheme2
    ))
  }) # getReaction2

  getReaction3 <- reactive({
    return(list(nameSearch = input$nameSearch3,
                division = input$division3,
                sexChoose = input$sexChoose3
    ))
  }) # getReaction3

  getReaction4 <- reactive({
    return(list(nameSearch = input$nameSearch4,
                year = input$year4
    ))
  }) # getReaction4

  getReaction5 <- reactive({
    return(list(year = input$year5,
                sort = input$sort5
    ))
  }) # getReaction5

  # Output Plots.
  output$wordCloud <- renderPlot({print(getWordCloud(localFrame, getReaction1()))},width=1000,height=800) # output wordCloud
  output$map <- renderPlot({print(getMap(localFrame, getReaction2()))},width=1200,height=800) # output map
  output$small <- renderPlot({print(getSmall(localFrame, getReaction3()))},width=1000,height=800) # output small
  output$bar <- renderPlot({print(getBar(localFrame, getReaction5()))},width=900,height=700) # output bar
  output$table <- renderDataTable({print(getTable(localFrame, getReaction4()))})
#                                   options = list(sPaginationType = "two_button",
#                                                  sScrollY = "400px",
#                                                  bScrollCollapse = 'true')) # output table
  }) # shinyServer
