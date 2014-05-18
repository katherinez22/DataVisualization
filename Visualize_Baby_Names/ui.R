library(shiny)

shinyUI(navbarPage("Baby Names of 50 States", 
         tabPanel("Word Cloud",sidebarLayout(
                    sidebarPanel(width=3,
                     selectInput("stateName1","State Abbreviation: ",
                                c("All", "AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD",
                                  "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD",
                                  "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"),
                                  selected="All"),
                     br(), 
                     selectInput("year1","Year: ",
                                 c(2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012),
                                 selected=2012),
                     br(), 
                     sliderInput("wordNumber1", "Number of Words in the Cloud: ", min=50, max=150, value=100, step=1),
                     br(),
                     radioButtons("sexChoose1", "Gender:", c("Female", "Male"),
                                  selected = c("Female")),
                     br(),
                     HTML("<p align=\"center\">[ <a href=\"https://github.com/katherinez22/msan622/tree/master/final-project\">download source</a> ]</p>")             
                    ), #end sidebarPanel
                    mainPanel(
                      plotOutput("wordCloud",width="100%",height="100%")
                    ) # end main panel
                  ) # end sidebarLayout 
         ), # end tabpanel
         tabPanel("Map",sidebarLayout(
           sidebarPanel(width=3,
                        textInput("nameSearch2", "Baby Name Search: ", ""),
                        p("Please search a specific name or find one in the Raw Data Panel."),
                        br(),
                        selectInput("year2","Year: ",
                                    c(2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012),
                                    selected=2012),
                        br(), 
                        radioButtons("sexChoose2", "Gender:", c("Female", "Male"),
                                     selected = c("Female")),
                        br(),
                        selectInput("colorScheme2", "Color Scheme:", 
                                    c("RdPu", "BuGn", "PuRd", "OrRd", "PuBu", "YlGn"),
                                    selected = "RdPu"),
                        # Add a download link
                        HTML("<p align=\"center\">[ <a href=\"https://github.com/katherinez22/msan622/tree/master/final-project\">download source</a> ]</p>")
           ), #end of sidebarPanel
           mainPanel(
             plotOutput("map",width="100%",height="100%")
           ) # end of main panel
         ) # end of sidebarLayout 
         ), # end tabpanel  
         tabPanel("Small Multiples",sidebarLayout(
           sidebarPanel(width=3,
                        selectInput("division3", "State Division:", 
                                     c("All","New England","Middle Atlantic","South Atlantic","East South Central",
                                       "West South Central","East North Central","West North Central","Mountain","Pacific"),
                                      selected = c("All")),
                        br(),
                        checkboxGroupInput("sexChoose3", "Gender:", c("Female", "Male"),
                                     selected = c("Female", "Male")),
                        br(),
                        # Add a download link
                        HTML("<p align=\"center\">[ <a href=\"https://github.com/katherinez22/msan622/tree/master/final-project\">download source</a> ]</p>")
           ), #end of sidebarPanel
           mainPanel(
             plotOutput("small",width="100%",height="100%")
           ) # end of main panel
         ) # end of sidebarLayout 
         ), # end tabpanel
         tabPanel("Bar Chart",sidebarLayout(
           sidebarPanel(width=3,
                        selectInput("year5", "Year: ", 
                                    c(2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012),
                                    selected = 2012),
                        br(),
                        radioButtons("sort5", "Sort Order:", c("Alphabetical", "Name Frequency"),
                                     selected = c("Alphabetical")),
                        br(),
                        # Add a download link
                        HTML("<p align=\"center\">[ <a href=\"https://github.com/katherinez22/msan622/tree/master/final-project\">download source</a> ]</p>")
           ), #end of sidebarPanel
           mainPanel(
             plotOutput("bar",width="100%",height="100%")
           ) # end of main panel
         ) # end of sidebarLayout 
         ), # end tabpanel
         tabPanel("Raw Data", sidebarLayout(
           sidebarPanel(width=3,
                        textInput("nameSearch4", "Baby Name Search: ", ""),
                        p("Please search baby names starting with certain characters. "),
                        br(),
                        sliderInput("year4", "Year Range:  ", min=2002, max=2012, value=c(2002,2012), step=1, format='####'),
                        br(), 
                        # Add a download link
                        HTML("<p align=\"center\">[ <a href=\"https://github.com/katherinez22/msan622/tree/master/final-project\">download source</a> ]</p>")
           ), #end of sidebarPanel
           mainPanel(
             dataTableOutput("table")
           ) # end of main panel
         ) # end of sidebarLayout 
         ) # end tabpanel
)# end navbar page
) #end shiny UI
