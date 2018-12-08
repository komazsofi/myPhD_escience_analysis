"
@author: Zsofia Koma, UvA
Aim: explore training-validation data
"

# Import libraries
library("sp")
library("rgdal")
library("raster")
library("spatialEco")
library("rgeos")
library("plyr")
library("dplyr")
library("maptools")
library("gridExtra")

library("ggplot2")
library("ggmap")
library("maps")
library("mapdata")

# Set global variables
full_path="D:/Koma/Paper1/ALS/forClassification/"
filename="featuretable_level3_b2o5.csv"

setwd(full_path)

# Import
featuretable=read.csv(filename)

colnames=names(featuretable)

# Boxplots

for (i in 1:22){
  print(colnames[i])
  
  jpeg(paste(substr(filename, 1, nchar(filename)-4),colnames[i],'_boxplot.jpg',sep=''))
  boxplot(featuretable[[colnames[i]]]~layer,data=featuretable,ylab=colnames[i])
  dev.off()
}