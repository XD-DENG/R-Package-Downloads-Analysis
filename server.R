
library(shiny)
library(RCurl)
library(rworldmap,quietly = TRUE)

#this line is setting the maximum size of the file which is going to be uploaded by user.
options(shiny.maxRequestSize=50*1024^2) 


shinyServer(function(input, output) {
  

  # functions ---------------------------------------------------------------
  
  data_collect_internet <- function(start_date, end_date){
    tmp_file_location <- paste(getwd(),"/temp_file.csv.gz", sep="")
    
    
    start <- as.Date(start_date)
    today <- as.Date(end_date)
    
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
        data_collection <- rbind(data_collection, tmp_data)
        file.remove(tmp_file_location)
      }else{
        cat("The data on this date is not available.\n\n")
      }
    }
    return(data_collection)
  }
  
  # this function help collect data from the file uploaded
  data_collect <- function(){
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    contents <- read.csv(inFile$datapath, header = TRUE,
                         sep = ",", quote = '"')
    return(contents)
  }
  
#   # pie plot for country
#   pie_plot_country <- function(){
#     num_to_display <- 5
#     data_collection <- dat()
#     data_collection <- subset(data_collection, package==input$package_name)
#     data_pie_country <- rev(sort(table(data_collection$country)))
#     if(length(unique(data_collection$country))>num_to_display){
#       pie(c(data_pie_country[1:num_to_display],sum(data_pie_country[-(1:num_to_display)])),
#           labels = c(names(data_pie_country)[1:num_to_display], "Others"))
#     }else{
#       pie(data_pie_country, 
#           labels = names(data_pie_country))
#     }
#   }
#   
#   # pie plot for version
#   pie_plot_version <- function(){
#     num_to_display <- 5
#     data_collection <- dat()
#     data_collection <- subset(data_collection, package==input$package_name)
#     data_pie_version <- rev(sort(table(as.character(data_collection$version))))
#     
#     if(length(unique(data_collection$version))>num_to_display){
#       pie(c(data_pie_version[1:num_to_display],sum(data_pie_version[-(1:num_to_display)])),
#           labels = c(names(data_pie_version)[1:num_to_display], "Others"))
#     }else{
#       pie(data_pie_version, 
#           labels = names(data_pie_version))
#     }
#   }
#   
#   #pie plot for r version
#   pie_plot_r_version <- function(){
#     num_to_display <- 5
#     data_collection <- dat()
#     data_collection <- subset(data_collection, package==input$package_name)
#     data_pie_r_version <- rev(sort(table(as.character(data_collection$r_version))))
#     
#     if(length(unique(data_collection$r_version))>num_to_display){
#       pie(c(data_pie_r_version[1:num_to_display],sum(data_pie_r_version[-(1:num_to_display)])),
#           labels = c(names(data_pie_r_version)[1:num_to_display], "Others"))
#     }else{
#       pie(data_pie_r_version, 
#           labels = names(data_pie_r_version))
#     }
#   }
  
  
  # global data setting ----------------------------------------------
  
  # by using reactive(), I can have the data I desired as a global object.
  # so that I need to run data_collect() for only once.
  
  #dat <- reactive(dat_uploaded())
  
  
  dat_uploaded <- reactive(data_collect())
  
  
  # following part is for downloading test
  # test if can directly download data from CRAN
  output$dat_CRAN_head <- renderTable(head(dat_downloaded()))
  output$dat_CRAN_tail <- renderTable(tail(dat_downloaded()))
  output$dat_downloaded_show <- renderDataTable(dat_downloaded())
  
  dat_downloaded <- eventReactive(input$start_download, {
    #your action
#     tmp <- dat()
#     head(tmp)
#     test_url <- "http://cran-logs.rstudio.com/2015/2015-06-24.csv.gz"
#     download.file(test_url, destfile = "test.csv.gz")
#     tmp_data <- read.csv(gzfile("test.csv.gz"))
#     head(tmp_data)
    tmp <- data_collect_internet(input$start_date, input$end_date)
    tmp
  })
  
  dat <- reactive(
    if(input$data_source=="uploaded"){
      dat_uploaded()
    }else{
      dat_downloaded()
    }
  )
  
  # UI Definitions ----------------------------------------------------------
  
  # this helps show the example from the data obtained
  output$contents <- renderDataTable({
    dat_uploaded()
  })
  
#   output$pie_plot <- renderPlot({
#     par(mfrow=c(3,1))
#     pie_plot_country()
#     pie_plot_version()
#     pie_plot_r_version()
#   })
  
  # plot the distributions of downloads on map
  output$map_plot <- renderPlot({
    data_collection <- dat()
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
  
  # show the range of dates selected for downloading
  output$show_date_range <- renderText({
    paste(as.character(input$start_date), as.character(input$end_date), sep=" to ")
  })
  
  # return the package name selected
  output$package_name <- renderText({
    input$package_name
  })
  
  # check if the package name selected is in the data obtained
  output$package_name_check <- renderText({
    package_list <- unique(dat()$package)
    if(input$package_name %in% package_list){
      paste("'", input$package_name, "' detected in the data.", sep="")
    }else{
      paste("'", input$package_name, "' NOT detected in the data.", sep="")
    }
  })
  
  
  output$package_download_num_of_country <- renderText({
    tmp <- dat()
    tmp <- subset(tmp, tmp$package==input$package_name)
    tmp <- length(unique(tmp$country))
    paste("Number of download countries: ", tmp, sep="")
  })
  
  output$package_download_num_of_downloads <- renderText({
    tmp <- dat()
    tmp <- subset(tmp, tmp$package==input$package_name)
    tmp <- dim(tmp)[1]
    paste("Number of downloads: ", tmp, sep="")
  })
  
  
  output$country_distribution <- renderDataTable({
    # I combined the lines below to reduce the memory usage
    # tmp <- dat()
    # tmp <- subset(dat(), tmp$package==input$package_name)
    temp_table <- data.frame(table(as.vector(subset(dat(), package==input$package_name)$country)))
    # temp_table <- data.frame(temp_table)
    names(temp_table) <- c("Country.Code", "Num.of.Downloads")
    temp_table[rev(order(temp_table$Num.of.Downloads)),]
  },
  # here we can define how many lines to show on each page
  options = list(lengthMenu = c(5, 30, 50), pageLength = 5))
  
  output$download_top10 <- renderTable({
    n=10
    # several lines below are combined to reduce the memory usage
    tmp_0 <- dat()
#     tmp_1 <- table(tmp_0$package)
#     tmp_2 <- rev(sort(tmp_1))
    tmp_3 <- rev(sort(table(tmp_0$package)))[1:n]
    
    result <- data.frame(PackageName = letters[1:n],
                         DownloadNum = 1:n,
                         Percentage = 1:n)
    result$PackageName <- names(tmp_3)
    result$DownloadNum <- tmp_3
    result$Percentage <- paste(as.character(round((result$DownloadNum/dim(tmp_0)[1])*100,2)),"%")
    
    result
    
  })
  
  output$download_percentage <- renderPlot({
    dat <- dat()
    
    dat_package <- dat$package
    dat_package_download<- rev(sort(table(dat_package)))
    
    dat_package_download_percentage <- dat_package_download/length(dat_package)
    #dat_package_download_percentage <- paste(round(100*dat_package_download_percentage, 2), "%", sep="")
    
    data_for_percentage_plot <- data.frame(cum_percentage=cumsum(dat_package_download_percentage), n=1:length(dat_package_download))
    
    # this part help get the tuples (number of top packages, cumulative downloads percentage)
    tmp <- seq(0.2, 0.8, by=0.2)
    points_x <- c()
    points_y <- c()
    for(i in 1:length(tmp)){
      points_x[i] <- which(data_for_percentage_plot$cum_percentage>=tmp[i])[1]
    }
    for(i in 1:length(points_x)){
      points_y[i] <- data_for_percentage_plot$cum_percentage[points_x[i]]
    }
    points_cumulative_percentage <- data.frame(n=points_x,
                                               cum_percentage=points_y,
                                               Labels=paste("(",points_x, "," ,round(points_y*100,2),"%)"))
    
    
    library(ggplot2)
    p <- ggplot(data_for_percentage_plot, aes(x=n, y=cum_percentage))+
      geom_line(cex = 2, color = "green")+
      geom_area(fill="lightblue")
    
    p+geom_point(data=points_cumulative_percentage, aes(x=n, y=cum_percentage),
                 size = 5,
                 color = "purple")+
      geom_text(data=points_cumulative_percentage,aes(x=n+500,
                                                      y=cum_percentage+0.05,
                                                      label=Labels))
  })
  
  
  output$map_plot_for_all_downloads <- renderPlot({
    data_collection <- dat()
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
  
  
  
  # several modules below are to display the summary information of the data obtained
  output$data_summary_data_source <- renderText({
    if(input$data_source=="uploaded"){
      tmp <- "Uploaded data"
    }else{
      tmp <- "Downloaded data"
    }
    paste("Source:", tmp)
  })
  
  output$data_summmary_num_of_records <- renderText({
    dat_tmp <- dat()
    if(is.null(dim(dat_tmp))){
      paste("Number of Records:", "0")
    }else{
      paste("Number of Records:", dim(dat_tmp)[1])
    }
  })
  
  output$data_summary_date_range <- renderText({
    dat_tmp <- dat()
    if(is.null(dim(dat_tmp))){
      "Date Range: N.A."
    }else{
      date_range <- range(as.Date(dat_tmp$date))
      paste("Date Range:", date_range[1], "to", date_range[2])
    }
  })
  
  # new function for downloading summary data
  # reference: http://shiny.rstudio.com/articles/download.html
  
  to.download <- reactive({
    tmp <- dat()
    
    # several lines here are combined to reduce memory usage
    
    # tmp <- subset(tmp, tmp$package==input$package_name)
    temp_table <- data.frame(table(as.vector(subset(tmp, tmp$package==input$package_name)$country)))
    # temp_table <- data.frame(temp_table)
    names(temp_table) <- c("Country.Code", "Num.of.Downloads")
    temp_table[rev(order(temp_table$Num.of.Downloads)),]
  })
  
  date_range <- reactive({
    dat_tmp <- dat()
    date_range <- range(as.Date(dat_tmp$date))
    paste(date_range[1], "to", date_range[2])
  })
  
  package_name <- reactive({
    input$package_name
  })
  
  output$download.summary <- downloadHandler(
    
    # !!!note that the filename must be produced with a function if it's dynamical.
    # if you don't produce it with a function, like below, then the filename can't be changed automatically
    # filename = paste("Country.Distribution", date_range(),".csv", sep=""),
    filename = function(){
      paste("Country.Distribution", date_range(),"_",package_name(),".csv", sep="")
      },
    
    content = function(file) {
      write.csv(to.download(), file, row.names = FALSE)
    }
  )
  
})
