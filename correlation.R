source("Composantes.R")
dens = read.csv("Densite_Communes.csv")  
dens = dens[dens$an == max(unique(dens$an)),]

# Calcul de la fenêtre
lat_min=100
long_min=100
lat_max=-100
long_max=-100
list_poly=list()
for(i in seq(1,length(france@polygons))){
  var_lat=rev(france@polygons[[i]]@Polygons[[1]]@coords[,1])
  var_long=rev(france@polygons[[i]]@Polygons[[1]]@coords[,2])
  
  lat_min=min(lat_min,min(var_lat))
  lat_max=max(lat_max,max(var_lat))
  long_min=min(long_min,min(var_long))
  long_max=max(long_max,max(var_long))
  
  
  list_poly=c(list_poly,list(cbind(var_lat,var_long)))
  
}
 #Definition de la fenetre  
fenetre =owin(c(lat_min,lat_max),c(long_min,long_max),poly=list_poly)

decha = ppp(points$Longitude,points$Latitude,fenetre)
if (!exists("barycom")){
  barycom = bary()
}
#filtrage des 0
bary2=barycom[barycom$dens != 0,]
bary2=ppp(bary2$Longitude,bary2$Latitude,window =fenetre)



g=gridcenters(window=fenetre,20,20)

nearestneighbour = function(x,y){
  a=ppp(x,y,window=fenetre)
  barycom$dens[nncross(a,bary2)$which]
}


duX=function(x,y){
  X=ppp(x,y,window = fenetre)
  nncross(X,bary2)$dist
}


im_nncross = as.im(nearestneighbour,W=fenetre)

r = rhohat(decha,im_nncross)
plot(r)

