
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(RCurl)
library(rworldmap,quietly = TRUE)

options(shiny.maxRequestSize=50*1024^2) 

shinyServer(function(input, output) {
  

  # functions ---------------------------------------------------------------
  
  data_collec_internet <- function(start_date, end_date){
    tmp_file_location <- paste(getwd(),"/temp_file.csv.gz", sep="")
    
    
    start <- as.Date('2015-05-26')
    today <- as.Date('2015-06-18')
    
    all_days <- seq(start, today, by = 'day')
    
    year <- as.POSIXlt(all_days)$year + 1900
    urls <- paste0('http://cran-logs.rstudio.com/', year, '/', all_days, '.csv.gz')
    # You can then use download.file to download into a directory.
    
    data_collection <- NULL
    for(i in 1:length(urls)){
      print(all_days[i])
      if(url.exists(urls[i])==TRUE){
        download.file(urls[i], destfile = tmp_file_location)
        tmp_data <- read.csv(gzfile(tmp_file_location))
        tmp_data <- subset(tmp_data, tmp_data$package==pacakge_name)
        data_collection <- rbind(data_collection, tmp_data)
        file.remove(tmp_file_location)
      }else{
        cat("The data on this date is not available.\n\n")
      }
    }
    return(data_collection)
  }
  
  data_collect <- function(){
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    contents <- read.csv(inFile$datapath, header = input$header,
                         sep = input$sep, quote = input$quote)
    return(contents)
  }
  
  # pie plot for country
  pie_plot_country <- function(){
    num_to_display <- 5
    data_collection <- data_collect()
    data_collection <- subset(data_collection, package==input$package_name)
    data_pie_country <- rev(sort(table(data_collection$country)))
    if(length(unique(data_collection$country))>num_to_display){
      pie(c(data_pie_country[1:num_to_display],sum(data_pie_country[-(1:num_to_display)])),
          labels = c(names(data_pie_country)[1:num_to_display], "Others"))
    }else{
      pie(data_pie_country, 
          labels = names(data_pie_country))
    }
  }
  
  # pie plot for version
  pie_plot_version <- function(){
    num_to_display <- 5
    data_collection <- data_collect()
    data_collection <- subset(data_collection, package==input$package_name)
    data_pie_version <- rev(sort(table(as.character(data_collection$version))))
    
    if(length(unique(data_collection$version))>num_to_display){
      pie(c(data_pie_version[1:num_to_display],sum(data_pie_version[-(1:num_to_display)])),
          labels = c(names(data_pie_version)[1:num_to_display], "Others"))
    }else{
      pie(data_pie_version, 
          labels = names(data_pie_version))
    }
  }
  
  #pie plot for r version
  pie_plot_r_version <- function(){
    num_to_display <- 5
    data_collection <- data_collect()
    data_collection <- subset(data_collection, package==input$package_name)
    data_pie_r_version <- rev(sort(table(as.character(data_collection$r_version))))
    
    if(length(unique(data_collection$r_version))>num_to_display){
      pie(c(data_pie_r_version[1:num_to_display],sum(data_pie_r_version[-(1:num_to_display)])),
          labels = c(names(data_pie_r_version)[1:num_to_display], "Others"))
    }else{
      pie(data_pie_r_version, 
          labels = names(data_pie_r_version))
    }
  }
  
  
  
  
  # UI Definitions ----------------------------------------------------------
  
  output$contents <- renderTable({
    temp <- data_collect()
    print(names(temp))
    if(identical(names(temp),c("date", "time", "size", "r_version", "r_arch",
                      "r_os", "package", "version", "country", "ip_id"))){
      head(temp)
    }else{
      data.frame("Possible Issue"=c("No data uploaded", "The dataset structure doesn't meet requirement."))
    }
    
  })
  
  output$pie_plot <- renderPlot({
    par(mfrow=c(3,1))
    pie_plot_country()
    pie_plot_version()
    pie_plot_r_version()
    
      
  })
  

  output$map_plot <- renderPlot({
    data_collection <- data_collect()
    data_collection <- subset(data_collection, package==input$package_name)
    # map plot for country
    country_mapping <- read.csv("www/country_mapping.csv")
    data_pie_country <- rev(sort(table(as.character(data_collection$country))))
    # country_list <- unique(names(data_pie_country))
    # country_name_list <- country_mapping$Country.name[country_mapping$Code %in% country_list]
    
    #!!! a bug exists here "%in%" will lead to wrong order
    
    country_list <- NULL
    for(i in 1:length(data_pie_country)){
      if(names(data_pie_country)[i] %in% country_mapping$Code){
        country_list <- c(country_list,
                          as.character(country_mapping$Country.name)[which((country_mapping$Code == names(data_pie_country)[i])==TRUE)])
      }
    }
    df <- data.frame(country=country_list, 
                     downloads=data_pie_country[names(data_pie_country) %in% country_mapping$Code])
    map_data <- joinCountryData2Map(df, joinCode = "NAME",
                                    nameJoinColumn = "country")
    mapCountryData(map_data, nameColumnToPlot = "downloads")
    
    par(mai=c(0,0,0.2,0),xaxs="i",yaxs="i")
    mapBubbles(map_data, 
               nameZSize = "downloads",
               nameZColour="GEO3major",
               colourPalette="rainbow",
               oceanCol = "lightblue",
               landCol = "wheat")
  })
  
  output$show_date_range <- renderText({
    paste(as.character(input$start_date), as.character(input$end_date), sep=" to ")
  })

  output$package_name <- renderText({
    input$package_name
  })
  
  output$package_name_check <- renderText({
    package_list <- unique(data_collect()$package)
    if(input$package_name %in% package_list){
      paste("'", input$package_name, "' detected in the data.", sep="")
    }else{
      paste("'", input$package_name, "' NOT detected in the data.", sep="")
    }
  })

})
