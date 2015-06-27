dat <- read.csv("/home/xiaodong/Downloads/2015-06-24.csv")

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





