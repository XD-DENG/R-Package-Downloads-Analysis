
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(navbarPage("R Package Download Analysis",
                   tabPanel("Welcome",
                            h5("This tool helps analyze the downloads of R packages on the CRAN mirror site (http://cran.rstudio.com/)"),
                            br(),
                            br(),
                            img(src="blacksmith.png", height = 100, width = 100),
                            "By Xiaodong"),
                   
                   navbarMenu("Prepare Data",

                     tabPanel("Load data",
                              fluidPage(
                                sidebarLayout(
                                  sidebarPanel(
                                    fileInput('file1', 'Choose file to upload',
                                              accept = c(
                                                'text/csv',
                                                'text/comma-separated-values',
                                                'text/tab-separated-values',
                                                'text/plain',
                                                '.csv',
                                                '.tsv'
                                              )
                                    ),
                                    tags$hr(),
                                    checkboxInput('header', 'Header', TRUE),
                                    radioButtons('sep', 'Separator',
                                                 c(Comma=',',
                                                   Semicolon=';',
                                                   Tab='\t'),
                                                 ','),
                                    radioButtons('quote', 'Quote',
                                                 c(None='',
                                                   'Double Quote'='"',
                                                   'Single Quote'="'"),
                                                 '"')
                                  ),
                                  
                                    tableOutput("contents")
                                  
                                )
                              )
                     ),

                     tabPanel("Download from CRAN",
                             
                                    dateInput("start_date","The starting date:",value = Sys.Date()),
                                    dateInput("end_date","The ending date:",value = Sys.Date()),
                                    br(),
                                    h5("The date range you selected is:"),
                                    textOutput("show_date_range")
                                )
                   ),
                   navbarMenu("Selecting & Setting",
                              
                              tabPanel("Select the package",
                                       textInput("package_name",
                                                 label = "Please enter the name of the package that you're interested in:"),
                                       br(),
                                       h4("The package you're going to analyze is:"),
                                       h3(textOutput("package_name")),
                                       br(),
                                       textOutput("package_name_check"),
                                       br(),
                                       h5("Please note that the capitalization is important"),
                                       h5("For example, 'rtts' while real name is 'Rtts' will cause error.")
                                       )
                              
                              
                              ),
                   navbarMenu("Analysis",
                              tabPanel("Simple Analysis",
                                       plotOutput("pie_plot")),
                              tabPanel("See on Map",
                                       plotOutput("map_plot"))
                              )
                   

))
