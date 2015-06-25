
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
                   
                   # the navigation bar to obtain data
                   navbarMenu("Prepare Data",                 
                              # load data by uploading csv files.
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
                                    h5("Please use the csv or csv.gz file downloaded from"),
                                    h5("http://cran-logs.rstudio.com/"),
                                    h5("and don't make any change to the data.")
                                       
                                  ),
                                  
                                    tableOutput("contents")
                                  
                                )
                              )
                     ),
                      # get data by downloading from CRAN-log
                     tabPanel("Download from CRAN",
                             
                                    dateInput("start_date","The starting date:",value = Sys.Date()),
                                    dateInput("end_date","The ending date:",value = Sys.Date()),
                                    br(),
                                    h5("The date range you selected is:"),
                                    textOutput("show_date_range"),
                                    actionButton("start_download", "Download")
                                )
                   ),
                   
                   # selecting the package name that we want to analyze. 
                   # May add other features in this part later
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
                   
                   # this part is to begin analysis
                   navbarMenu("Analysis",
                              tabPanel("Simple Analysis",
                                       plotOutput("pie_plot")),
                              tabPanel("See on Map",
                                       plotOutput("map_plot")),
                              tabPanel("Download Summary",
                                       h3("Key Numbers"),
                                       dataTableOutput("download_summary"),
                                       br(),
                                       h3("Country Distribution"),
                                       dataTableOutput("country_distribution"))
                              )
                   

))
