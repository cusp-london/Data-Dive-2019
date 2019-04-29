
###1. Time-series plot of crime data by police ###

k <- read.csv("crime_0.csv")
past <- read.csv("Knifecrimedata2016_2017.csv")
incident <- read.csv("instance_date_2018_2.csv")
res <- read.csv("response_date.csv")

#group the raw data by date and month
require(dplyr)
month <- k %>% group_by(k$Mon) %>% summarize(knife = sum(Knife.Crime.Offs))

date <- k %>% group_by(k$Date...Daily.Data) %>% summarize(knife = sum(Knife.Crime.With.Injury.Offs), month=mean(Mon))

inc <-  incident %>% group_by(Mon, Day) %>% count

resp <-  res %>% group_by(Mon, Day) %>% count

# recode the variable Date into date format
library(xts)
as.Date(Knifemon$`k$Date...Daily.Data`)
date1 <- xts(date$knife, as.Date(date$`k$Date...Daily.Data`))

#plot the daily scatter plot
plot(date1, type = "p", ylim = c(15, 70),lwd = 1, yaxis.right = F,  main = "Crime data by date", col = "deepskyblue4", lty = 1)
plot(date1, type = "l", ylim = c(15, 60),lwd = 1, yaxis.right = F,  main = "Crime data by date", col = "deepskyblue4", lty = 1)

?plot


#add the ambulance data
las <- read.csv("cleaned_incident.csv")
lasmonth <- las %>% group_by(las$Mon) %>% count
plot(lasmonth, type = "l", ylim=c(150,250),lwd = 0.7, col="red", ylab = "Knife incidence", main = "", xlab = "Month")

par(new= T)

#plot the monthly plot
plot(month, type = "l", col="blue", lty = 3, yaxt="n", ylab ="", xlab = "", ylim = c(1500, 2300))
axis(4)
box()
legend("topright",c("ambulance","cirme"),col=c("red","blue"),lty =c(1,3), text.col=c("red","blue"))

#compare las and crime data
head(lasmonth$n)
head(month$knife)
pro2 <- t(data.frame(lasmonth$n,month$knife-lasmonth$n))

colnames(pro2) <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12")
par(las=1)
barplot(pro2, xlab = "Month", ylab = "las call / knife crime offs with injury", )


#plot scatter points on daily data. 
library(ggplot2)
ds <- plyr::ddply(date, "month", plyr::summarise, mean = mean(knife), sd = sd(knife))

g <- ggplot(date, aes(month, knife)) +
  geom_point() +
  geom_point(data = ds, aes(y = mean), colour = 'red', size = 3) +
  geom_line(data = ds, aes(y = (mean + 3*sd)), colour = 'steelblue', lty =3, size = 0.7)


g + scale_x_continuous(limits=c(1,12), breaks=seq(1, 12, 1))

#same plot for ambulance data
ds <- plyr::ddply(inc, "Mon", plyr::summarise, mean = mean(n), sd = sd(n))

g <- ggplot(inc, aes(Mon, n)) +
  geom_point(size = 2) +
  geom_point(data = ds, aes(y = mean), colour = 'red', size = 2) +
  geom_line(data = ds, aes(y = (mean + 3*sd)), colour = 'steelblue', lty =3, size = 0.7)

#same plot for response data
resp <- na.omit(resp)
ds <- plyr::ddply(resp, "Mon", plyr::summarise, mean = mean(n), sd = sd(n))

g <- ggplot(resp, aes(Mon, n), main = "Response data") +
  geom_point(size = 2) +
  geom_point(data = ds, aes(y = mean), colour = 'red', size = 2) +
  geom_line(data = ds, aes(y = (mean + 3*sd)), colour = 'steelblue', lty =3, size = 0.7)

g + scale_x_continuous(limits=c(1,12), breaks=seq(1, 12, 1))

#double-check this plot
sum(k$Knife.Crime.With.Injury.Offs[k$Date...Daily.Data == "2018-01-01"])
mean(Knifemon$knife [Knifemon$month == 1])


### 2. 2016 & 2017 patterns ###
past2016 <- past[past$year == 2016,]
past2017 <- past[past$year == 2017,]


date2016 <- past2016 %>% group_by(Date...Daily.Data) %>% summarize(knife = sum(Knife.Crime.Offs), month=mean(month))
date20161 <- xts(date2016$knife, as.Date(date2016$Date...Daily.Data, format ='%d %b %Y'))
plot(date20161, type = "p", ylim = c(10,65))


date2017 <- past2017 %>% group_by(Date...Daily.Data) %>% summarize(knife = sum(Knife.Crime.Offs), month=mean(month))
date20171 <- xts(date2017$knife, as.Date(date2017$Date...Daily.Data, format ='%d %b %Y'))
plot(date20171, type = "p", ylim = c(10,65))

month16 <- past2016 %>% group_by(past2016$month) %>% summarize( knife = sum(Knife.Crime.Offs))

month17 <- past2017 %>% group_by(past2017$month) %>% summarize( knife = sum(Knife.Crime.Offs))

plot(month16, type = "l", col="steelblue", ylim = c(700, 1600), lwd = 2.5, xlab = "Month")
par(new = T)
plot(month17, type = "l", ylab ="", xlab = "", ylim = c(700, 1600), col ="darkslategray3", lwd = 2.5)
par(new = T)
plot(month, type = "l", col="darkgoldenrod2", ylim = c(700, 1600), ylab ="", xlab = "", lwd = 2.5)

legend("topright",c("2016","2017", "2018"),col=c("steelblue","darkslategray3", "darkgoldenrod2"),bty="n", lwd = c(2.5, 2.5, 2.5), text.col=c("steelblue","darkslategray3", "darkgoldenrod2"))


# melt into barcharts of 2016, 2017 and 2018
data <- data.frame(
  Month = factor(c(1,2,3,4,5,6,7,8,9,10,11,12), levels = c(1,2,3,4,5,6,7,8,9,10,11,12)),
  data2016 = month16$knife,
  data2017 = month17$knife,
  data2018 = month$knife)

library(reshape2)
mydata <- melt(data, id.vars = "Month", variable.name = "Year", value.name = "Knife_crime_offs")
ggplot(mydata, aes(Month, Knife_crime_offs, fill = Year)) + geom_bar(stat = "identity", position = "dodge")



###3. Gradient plot of number of activations by week and hour ###

Las <- read.csv("Merged file of LAS stab 2018 & police 2018.csv")
LAS <- read.csv("instance_date_2018_2.csv")

Las$hour <- as.factor(Las$Hrs)

#group by month and hour
require(dplyr)
count2 <- LAS %>% group_by(Hrs,Week)  %>% count
sum(count2$n)
length(Las$X.1)
count2$Hours <- as.factor(count2$Hrs)
count2$week <- factor(count2$Week, levels =c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun") )
table(count2$Week)

count$n[count$n == 49123] <- NA
count = na.omit(count)
library(ggplot2)

ggplot(count2, aes(x = week, y = Hours)) + 
  geom_tile(aes(fill = n, colour = "white")) + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
  scale_fill_gradient(low = "white", high = "red") + 
  coord_fixed(ratio = .9) 





################################################

################################################
## Bad codes
require(dplyr)
Knifemonth <- k %>% group_by(month) %>% summarise(knife = sum(Knife_Total))
Knifedate <- k %>% group_by(Date) %>% summarise(knife = sum(Knife_Total))



sum(k$Knife_Total[k$Date=='1/1/18'])
head(Knifedate)

#change the format of time
ktime <- as.Date(Knifedate$Date, format = '%m/%d/%Y')

library(xts)
kk <- xts(Knifedate$knife,ktime)
plot(kk, type = "p", xlab = "Date", ylab = "Total Knife crimes(police)")




install.packages("TSA")
library(TSA)
win.graph(width=9.5, height = 4.5, pointsize = 8)
plot(kk,type = 'p',main='2018 Crime Data(Daily)', mar = c(3, 2, 1, 2), outer = TRUE)
plot(kk,type = 'l',main='2018 Crime Data(Daily)', xaxt="n" )
axis(1,at=seq(1,12),label=c(1,2,3,4,5,6,7,8,9,10,11,12)) 

v<-ts(ktime,frequency=7,start=c(0018,1))  
plot(v)

ktime <- data.frame(date = ktime, k$Knife_Total)
head(ktime)


library(ggplot2)
ggplot(ktime, aes(x=date, y=k$Knife_Total)) + geom_line()
head(k$Knife_Total)

#Monthly time series
par(las=3)
plot(Knifemonth,ylim=c(1400,2500), type = 'l',main='2018 Crime Data(Monthly)', xaxt="n" )
axis(1,labels=c(1,2,3,4,5,6,7,8,9,10,11,12),at=1:12,las=2)
?axis

###########################
## use the incident data ##
###########################
inc <- read.csv("cleaned_incident.csv")
require(dplyr)
inc1 <- table(inc$Mon)
plot(table(inc$Mon))
plot(1:12, inc1, type = "l")

incmonth <- inc %>% group_by(Mon) %>% summarise(knife = count())




ggplot(Knifemonth, aes(x=month, y=knife), xaxt="n")) + geom_line()
## Daily time series
g<-ggplot()+geom_line(aes(x=month,y=knife),data=Knifemonth,color="gray40")
g<-g+geom_point(aes(x=month,y=knife),data=Knifemonth,col="gray26",size=1.5,alpha=0.6)
g<-g+theme(panel.background =element_rect(fill="transparent",color="gray")) #修改背景
g<-g+labs(x="date",y="amount",title="2018 Crime Data(Monthly)")
g


require(dplyr)
count <- Las %>% group_by(Las$hour,Las$Week)  %>% count
sum(count$n)
length(Las$X.1)
