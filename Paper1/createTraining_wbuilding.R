"
@author: Zsofia Koma, UvA
Aim: create training data
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
#full_path="D:/Sync/_Amsterdam/02_Paper1_ReedbedStructure_onlyALS/3_Dataprocessing/forClassification/"
full_path="D:/Koma/Paper1/ALS/forClassification3/"

polygon_file="recategorized.shp"
building_file="buldings.shp"

level=25

setwd(full_path)

# Import
polygon=readOGR(dsn=polygon_file)
buildings=readOGR(dsn=building_file)

# Create trainings per classes
classes=unique(polygon@data[,level])

for (cat in classes) { 
  print(cat)
  sel_poly <- polygon[polygon@data[,level] == cat,]
  sel_poly_invbuf=gBuffer(sel_poly, width=-5, byid=TRUE )
  points_inpoly=spsample(sel_poly_invbuf, n = 100, "random")
  points_inpoly_df=as.data.frame(points_inpoly)
  points_inpoly_df$level=cat
  write.table(points_inpoly_df, file = paste(cat,"_selpolyper",names(polygon@data)[level],"v2.csv",sep="_"),row.names=FALSE,col.names=FALSE,sep=",")
}

#Building
points_inbuilding=spsample(buildings, n = 75, "random")
points_inbuilding_df=as.data.frame(points_inbuilding)
points_inbuilding_df$level="Bu"
write.table(points_inbuilding_df, file = paste("Bu","_selpolyper","level1","v2.csv",sep="_"),row.names=FALSE,col.names=FALSE,sep=",")

# Reorganize
files <- list.files(pattern = paste("_selpolyper",names(polygon@data)[level],"v2.csv",sep="_"))

allcsv <- lapply(files,function(i){
  read.csv(i, header=FALSE)
})

allcsv_df <- do.call(rbind.data.frame, allcsv)

coordinates(allcsv_df)=~V1+V2
proj4string(allcsv_df)<- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs")

# Add buffer zone

allcsv_df_buff <- gBuffer( allcsv_df, width=2.5, byid=TRUE )

# Export shapefile
rgdal::writeOGR(allcsv_df_buff, '.', paste("selpolyper",names(polygon@data)[level],"v4",sep="_"), 'ESRI Shapefile',overwrite_layer = TRUE)