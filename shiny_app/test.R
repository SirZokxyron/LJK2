source("Composantes.R")

lat_min=100
long_min=100
lat_max=-100
long_max=-100
list_poly=list()
for(i in c(1:169)){
  var_lat=rev(france@polygons[[1]]@Polygons[[i]]@coords[,1])
  var_long=rev(france@polygons[[1]]@Polygons[[i]]@coords[,2])
  
  lat_min=min(lat_min,min(var_lat))
  lat_max=max(lat_max,max(var_lat))
  long_min=min(long_min,min(var_long))
  long_max=max(long_max,max(var_long))
  
  
  list_poly=c(list_poly,list(cbind(var_lat,var_long)))
  
}
fenetre=owin(c(lat_min,lat_max),c(long_min,long_max),poly=list_poly)
mypattern2 <- ppp(points$Longitude,points$Latitude, fenetre)
ds <- density(mypattern2)
r <- raster(ds)
crs(r) <- CRS("+init=epsg:4326")
pal <- colorNumeric(i, values(r),na.color = "transparent")
map <- leaflet() %>% fitBounds(15,42,-9,51) %>% setMaxBounds(15,42,-9,52) %>% 
  addProviderTiles("Stamen.TonerBackground") %>%
  addRasterImage(r, colors = pal, opacity = 0.8)
map <- addLegend(map = map,pal = pal, values = values(r), opacity = 0.7, title = NULL,
                 position = "topright")
map