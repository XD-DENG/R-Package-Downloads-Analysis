# this code helps analyze the downloads statistics for R package on the CRAN (Rstudio Mirror)
# data source: http://cran-logs.rstudio.com/

library(RCurl)

pacakge_name <- "ggplot2"


# tmp_file_location <- "/home/xiaodong/Downloads/temp_file.csv.gz"
# tmp_data_location <- "/home/xiaodong/Downloads/temp_file.csv"
tmp_file_location <- paste(getwd(),"/temp_file.csv.gz", sep="")
tmp_data_location <- paste(getwd(),"/temp_file.csv", sep="")


start <- as.Date('2015-05-26')
today <- as.Date('2015-05-27')

all_days <- seq(start, today, by = 'day')

year <- as.POSIXlt(all_days)$year + 1900
urls <- paste0('http://cran-logs.rstudio.com/', year, '/', all_days, '.csv.gz')
# You can then use download.file to download into a directory.

data_collection <- NULL
for(i in 1:length(urls)){
  print(all_days[i])
  if(url.exists(urls[i])==TRUE){
    download.file(urls[i], destfile = tmp_file_location)
    system(command = paste("gunzip", tmp_file_location))
    tmp_data <- read.csv(tmp_data_location)
    tmp_data <- subset(tmp_data, tmp_data$package==pacakge_name)
    data_collection <- rbind(data_collection, tmp_data)
    file.remove(tmp_data_location)
  }else{
    cat("The data on this date is not available.\n\n")
  }
}

num_to_display <- 5

# pie plot for country
pie_plot_country <- function(){
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
  data_pie_r_version <- rev(sort(table(as.character(data_collection$r_version))))
  
  if(length(unique(data_collection$r_version))>num_to_display){
    pie(c(data_pie_r_version[1:num_to_display],sum(data_pie_r_version[-(1:num_to_display)])),
        labels = c(names(data_pie_r_version)[1:num_to_display], "Others"))
  }else{
    pie(data_pie_r_version, 
        labels = names(data_pie_r_version))
  }
}

#pie plot for operation system
pie_plot_os <- function(){
  data_pie_os <- rev(sort(table(as.character(data_collection$r_os))))
  
  if(length(unique(data_collection$r_os))>num_to_display){
    pie(c(data_pie_os[1:num_to_display],sum(data_pie_os[-(1:num_to_display)])),
        labels = c(names(data_pie_os)[1:num_to_display], "Others"))
  }else{
    pie(data_pie_os, 
        labels = names(data_pie_os))
  }
}



# map plot for country
library(rworldmap,quietly = TRUE)
country_mapping <- read.csv("/home/xiaodong/R/package_download_analysis/country_mapping.csv")
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
