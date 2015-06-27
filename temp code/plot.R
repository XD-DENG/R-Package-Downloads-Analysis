dat <- read.csv("/home/xiaodong/Downloads/2015-06-24.csv")

dat_package <- dat$package
dat_package_download<- rev(sort(table(dat_package)))

dat_package_download_percentage <- dat_package_download/length(dat_package)
#dat_package_download_percentage <- paste(round(100*dat_package_download_percentage, 2), "%", sep="")

data_for_percentage_plot <- data.frame(cum_percentage=cumsum(dat_package_download_percentage), n=1:length(dat_package_download))


library(ggplot2)
ggplot(data_for_percentage_plot, aes(x=n, y=cum_percentage))+
  geom_line()+
  geom_area(fill="lightblue")


plot(data_for_percentage_plot$cum_percentage~data_for_percentage_plot$n,
     type="l",
     xlab="The Number of Top Packages",
     ylab = "Cumulative Downloads Percentage")

tmp <- seq(0.2, 0.8, by=0.2)
points_x <- c()
points_y <- c()
for(i in 1:length(tmp)){
  points_x[i] <- which(data_for_percentage_plot$cum_percentage>=tmp[i])[1]
}
for(i in 1:length(points_x)){
  points_y[i] <- data_for_percentage_plot$cum_percentage[points_x[i]]
}
points(points_y~points_x)

