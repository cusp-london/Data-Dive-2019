
#Load Packages 
library(maptools) 
library(RColorBrewer) 
library(classInt) 
library(OpenStreetMap) 
library(sp) 
library(rgeos) 
library(tmap) 
library(tmaptools) 
library(sf) 
library(rgdal) 
library(geojsonio)
library(tidyr)
library(dplyr)
library(spdep)
library(raster)
library(readr)
library(spgwr)

########################################### data pre ###############################################
setwd("E:/UCL/CUSP/CUSP_London_Data_Dive_2019/data/Responses")
response_all <- read_csv('response_clean.csv', na = "NULL")
WARD <- read_shape("E:/UCL/CUSP/Shape/LondonWardsNew.shp", as.sf= TRUE)

# group data
response_sub <- response_all[,c("wardID","response","distance_to_scene","dohcategory")]
response_sub_clean <- response_sub[complete.cases(response_sub), ]
ward_response <- response_sub_clean %>% group_by(wardID,dohcategory) %>% 
  summarize(mean_response = mean(response, na.rm=TRUE),
            mean_distance = mean(distance_to_scene, na.rm=TRUE))
ward_response <- ward_response[-1:-5,]
write.csv(ward_response,file = "ward_response.csv")

# seperate category
ward_response <- read.csv("ward_response.csv")
ward_response_C1 <- subset(ward_response,dohcategory == 'C2')

# join data to the map
ward_response_map <- WARD %>% left_join(ward_response_C1, by = c("WD11CDO" = "wardID"))
names(ward_response_map)[names(ward_response_map) == 'mean_response'] <- 'mean_response_C1'
names(ward_response_map)[names(ward_response_map) == 'mean_distance'] <- 'mean_distance_C1'

# load data
# profile <- read.csv("LondonData2.csv",na = "NULL")
# profile_sub <- profile[,c("OldCode","PopDensity_personsPerSqkm_2013","Job_Density","CrimeRate_2014_15")]
# ward_response_map <- ward_response_map %>% left_join(profile_sub, by = c("WD11CDO" = "OldCode"))

# draw map
tm_shape(ward_response_map)+
  tm_fill("mean_response_C1",style = "quantile", title = "Seconds") +
  tm_layout(legend.position = c("right","bottom"),legend.outside=TRUE, main.title = "Average Response Time for C2")

ward_response_map2 <- ward_response_map[-which(is.na(ward_response_map$mean_response_C1)),] 
ward_response_map2 <- ward_response_map2[-9,]

###################################### global and local moran ###########################################
WARD_SP <- as(ward_response_map2, "Spatial")
BNG <- CRS("+init=epsg:27700")
WARD_BNG <- spTransform(WARD_SP, crs(BNG))

# neighbour link
neighbours <- poly2nb(WARD_BNG)

plot(WARD_BNG, border = 'lightgrey')
# plot(neighbours, coordinates(WARD_BNG), add=TRUE,col='blue')

listw <- nb2listw(neighbours,zero.policy=TRUE)

# global spatial autocorrelation
moran.test(WARD_BNG$mean_response_C1, listw,zero.policy=TRUE)

# local spatial autocorrelation
local <- localmoran(x = WARD_BNG$mean_response_C1, listw)
moran.map <- cbind(WARD_BNG, local)
tm_shape(moran.map) + tm_fill(col = "Ii", style = "quantile", title = "local moran statistic")+
  tm_layout(legend.position = c("right","bottom"),legend.outside=TRUE)

####################################### LISA cluster map ###############################################
quadrant <- vector(mode="numeric",length=nrow(local))
# centers the variable of interest around its mean
m.reponse <- WARD_BNG$mean_response_C1 - mean(WARD_BNG$mean_response_C1)     
# centers the local Moran's around the mean
m.local <- local[,1] - mean(local[,1])    
# significance threshold
signif <- 0.1 
# builds a data quadrant
quadrant[m.reponse >0 & m.local>0] <- 4  
quadrant[m.reponse <0 & m.local<0] <- 1      
quadrant[m.reponse <0 & m.local>0] <- 2
quadrant[m.reponse >0 & m.local<0] <- 3
quadrant[local[,5]>signif] <- 0  
# plot
brks <- c(0,1,2,3,4)
colors <- c("white","blue",rgb(0,0,1,alpha=0.4),rgb(1,0,0,alpha=0.4),"red")
plot(WARD_BNG,border="lightgray",col=colors[findInterval(quadrant,brks,all.inside=FALSE)],main="Cluster for Response Time (C2)")
box()
legend("bottomleft",legend=c("insignificant","low-low","low-high","high-low","high-high"),
       fill=colors,bty="n")

##################################### GWR ########################################################
#calculate kernel bandwidth
GWRbandwidth <- gwr.sel(WARD_BNG$mean_response_C1 ~ WARD_BNG$mean_distance_C1, data=WARD_BNG,adapt=T)
#run the gwr model
gwr.model = gwr(WARD_BNG$mean_response_C1 ~ WARD_BNG$mean_distance_C1, data=WARD_BNG, adapt=GWRbandwidth, hatmatrix=TRUE, se.fit=TRUE) 
#print the results of the model
gwr.model
results <-as.data.frame(gwr.model$SDF)
gwr.map <- cbind(WARD_BNG, as.matrix(results))

tm_shape(gwr.map)+
  tm_fill("localR2",style = "quantile", title = "Local R2") +
  tm_layout(legend.position = c("right","bottom"),legend.outside=TRUE,main.title = "Response Time vs. Distance to Scene (C2)")

qtm(gwr.map, fill = "localR2")







