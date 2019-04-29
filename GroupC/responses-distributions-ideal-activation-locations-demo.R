library(dplyr)
library(xlsx)
library(readr)
library(ggplot2)
library(ggmap)
library(stats)
library(e1071)     
library(lubridate)
library(reshape2)


# Data Cleaning for making Maps for individual LSOA/Ward Plots with surrounding ambulances
# =================================================================

resP1 <- read_csv("responsesP1(Jan-Feb).csv", na = "NULL")
resP2 <- read_csv("responsesP2(Mar-Apr).csv", na = "NULL")
resP3 <- read_csv("responsesP3(May-Jun).csv", na = "NULL")
resP4 <- read_csv("responsesP4(Jul-Aug).csv", na = "NULL")
resP5 <- read_csv("responsesP5(Sep-Oct).csv", na = "NULL")
resP6 <- read_csv("responsesP6(Nov-Dec).csv", na = "NULL")

resFull <- rbind(resP1, resP2, resP3, resP4, resP5, resP6)

resFull$dohcategory <- as.character(resFull$dohcategory)

resFull <- dplyr::select(resFull, "lsoa", "lat_activation", "lon_activation", "dohcategory", "running", "wardID")
lsoas <- c("harrow", "southwark", "bexley", "islington", "newton", "ealing", "merton")
lsoacodes <- c("E01002147", "E01004021", "E01000467", "E01002788", "E01003566", "E01001253", "E01003446")
wards <- c("00BEGG", "00BJGJ", "00AFGQ", "00ARGW")

# LSOA
for (i in 1:length(lsoas)){
  lsoaLSOA <- resFull %>%
    dplyr::filter(lsoa == lsoacodes[i], dohcategory == "C1")
  write.csv(lsoaLSOA, paste(lsoas[i], ".csv", sep = ""))
}


# Wards
for (i in 1:length(wards)){
  wardID <- resFull %>%
    dplyr::filter(wardID == wards[i], dohcategory == "C1")
  write.csv(wardID, paste(wards[i], ".csv", sep = ""))
}



# Distribution Plots of Response Times
# =================================================

fullData <- rbind(resP1, resP2, resP3, resP4, resP5, resP6)
fullData$TotalResponse <- fullData$activation + fullData$mobilisation + fullData$running

par(mfrow=c(2,1))
c1meanclac <- fullData %>%
  dplyr::filter(dohcategory == "C1")
c1Dist <- fullData %>%
  dplyr::filter(dohcategory == "C1", response <3600, response >= 0) 
hist(c1Dist$response, breaks = 60,
     main = "C1 Average Response Time Targets (Mean and 90th Percentile)",
     xlab = "Response Time (Minutes)",
     ylab = "Frequency")
abline(v = 420, col = "cyan", lwd = 3)
abline(v = mean(c1meanclac$response, na.rm = TRUE), col = "blue", lwd = 3)
abline(v = 900, col = "pink", lwd = 3)
abline(v = quantile(c1meanclac$response, prob = 0.9, na.rm = TRUE), lwd = 3, col = "red")
xlabel("Minutes")

c2meanclac <- fullData %>%
  dplyr::filter(dohcategory == "C2")
c2Dist <- fullData %>%
  dplyr::filter(dohcategory == "C2", response <3600, response >= 0) 
hist(c2Dist$response, breaks = 60,
     main = "C2 Average Response Time Targets (Mean and 90th Percentile)",
     xlab = "Response Time (Minutes)",
     ylab = "Frequency")
abline(v = 1080, col = "cyan", lwd = 3)
abline(v = mean(c2meanclac$response, na.rm = TRUE), col = "blue", lwd = 3)
abline(v = 2400, col = "pink", lwd = 3)
abline(v = quantile(c2meanclac$response, prob = 0.9, na.rm = TRUE), lwd = 3, col = "red")



# Circular Bar Plot (Theoretical usage)
# ==============================================
# Create dataset
data=data.frame(
  id=seq(1,60),
  individual=paste( "Mister ", seq(1,60), sep=""),
  value=sample( seq(10,100), 60, replace=T)
)

# Make the plot
p = ggplot(data, aes(x=as.factor(id), y=value)) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
  
  # This add the bars with a blue color
  geom_bar(stat="identity", fill=alpha("blue", 0.3)) +
  
  # Limits of the plot = very important. The negative value controls the size of the inner circle, the positive one is useful to add size over each bar
  ylim(-100,100) +
  ylab("Time Taken") +
  
  # Custom the theme: no axis title and no cartesian grid
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank()
    #panel.grid = element_blank(),
    #plot.margin = unit(rep(-2,4), "cm")     # This remove unnecessary margin around plot
  ) +
  annotate("text", x = rep(max(data$id),2), y = c(50,100), label = c("50", "100") , color="black", size=3 , angle=0, fontface="bold", hjust=1) +
  annotate("point", x = 0, y = -100) +
  annotate("text", x = 0, y = -80, label = "instance") +
  
  # This makes the coordinate polar instead of cartesian.
  coord_polar(start = 0)
p

