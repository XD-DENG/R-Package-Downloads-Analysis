
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
                              tabPanel("Upload data",
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
                                  
                                    dataTableOutput("contents")
                                  
                                )
                              )
                     ),
                      # get data by downloading from CRAN-log
                     tabPanel("Download from CRAN",
                              column(4,
                             
                                    dateInput("start_date","The starting date:",value = Sys.Date()),
                                    dateInput("end_date","The ending date:",value = Sys.Date()),
                                    br(),
                                    h5("The date range you selected is:"),
                                    textOutput("show_date_range"),
                                    br(),
                                    actionButton("start_download", "Download")),
                              column(6,
                                    h3("Data Downloaded:"),
                                    dataTableOutput("dat_downloaded_show")
                              )
                                ),
                     tabPanel("Select Data Source",
                              column(5,
                              h5("You can select which data source to use,"),
                              h5('"Uploaded data", or "Dowloaded data".'),
                              br(),
                              selectInput("data_source",label = "Choose Data Source",
                                          choices = list("Uploaded Data"="uploaded",
                                                         "Downloaed Data"="dowloaded"),
                                          selected = "uploaded")),
                              column(5,
                                     h3("Summary for Selected Data"),
                                     br(),
                                     h5(textOutput("data_summary_data_source")),
                                     h5(textOutput("data_summmary_num_of_records")),
                                     h5(textOutput("data_summary_date_range"))
                                     ))
                   ),
                   
                   # this part is to begin analysis
                   navbarMenu("Analysis",
                              
                              tabPanel("Package Analysis",
                                       fluidRow(
                                         column(5,
                                                textInput("package_name",
                                                          label = "Please enter the name of the package that you're interested in:"),
                                                h4("The package you're going to analyze is:"),
                                                h3(textOutput("package_name")),
                                                br(),
                                                textOutput("package_name_check"),
                                                br(),
                                                h5("Please note that the capitalization is important"),
                                                h5("For example, 'rtts' while real name is 'Rtts' will cause error.")
                                                ),
                                         column(5,
                                                h3("Key Numbers"),
                                                h5(textOutput("package_download_num_of_downloads")),
                                                h5(textOutput("package_download_num_of_country"))
                                                )
                                       ),
                                       
                                       fluidRow(
                                         h3("Country Distribution"),
                                         dataTableOutput("country_distribution"),
                                         downloadButton("download.summary", "Download Country Distribution Summary"),
                                         br(),
                                         br(),
                                         plotOutput("map_plot")
                                       )

                                       ),

                              tabPanel("Pareto Principle (80-20 rule)",
                                       
                                       column(4,
                                              h4("Top 10 Packages in the data obtained"),
                                              tableOutput("download_top10")),
                                       
                                       column(5,
                                              h5("The following plot help us know that how many packages achieved most of the downloads"),
                                              h5("e.g., (878, 80%) means the top 878 packages achived 80% of the downloads."),
                                              plotOutput("download_percentage", width = 800)
                                              )
                                       ),
                              
                              tabPanel("Map for All downloads",
                                       plotOutput("map_plot_for_all_downloads"))
                              )
                   

))
