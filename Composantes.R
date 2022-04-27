# Importation des librairies
library(leaflet)
library(geojsonio)
library(shiny)
library(raster)
library(spatstat)

# Récupération des cooordonnées des déchetteries
if (!exists("dech")){
  points = read.csv("landfill/landfills.csv")
  
  # Trie des déchetteries hors métropole
  points = points[40<points$Latitude,]
  points = points[points$Latitude<52,]
  points = points[points$Longitude>-9,]
  points = points[points$Longitude<15,]
  
  # Variable pour dire qu'on a bien la base de donnée
  dech = T
}

# Calcul des barycentres
if(!exists("bary")){
  bary = function(){
    dentity = read.csv("pop_density/Densite_Communes.csv")
    geo = dentity$codgeo
    list_x_communes=c()
    list_y_communes=c()
    list_dens = c()
    for(i in communes@polygons){
      if (communes@data$code[as.integer(i@ID)] %in% geo){
        list_coord=i@Polygons[[1]]@coords
        list_x=list_coord[,1]
        list_y=list_coord[,2]
        mean_x=mean(list_x)
        mean_y=mean(list_y)
        list_x_communes=c(list_x_communes,mean_x)
        list_y_communes=c(list_y_communes,mean_y)
        d = dentity[communes@data$code[as.integer(i@ID)] == geo,]
        d = d[d$an == max(unique(d$an)),]
        list_dens = c(list_dens,d$dens_pop )
        }
    }
    return(data.frame("Longitude" = list_x_communes, "Latitude" = list_y_communes, dens = list_dens))
  }
}


# Recupérations des communes
if (!exists("communes")){
  communes = geojsonio::geojson_read("https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/communes.geojson", what = "sp")
  nc = length(communes)
  
  # Barycentre des communes
  barycom = bary()
}


# Recupérations des departements
if (!exists("departements")){
  departements = geojsonio::geojson_read("https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements.geojson", what = "sp")
  nd = length(departements)
  noms_departements = departements@data$nom
}


# Recupérations des régions
if (!exists("region")){
  regions = geojsonio::geojson_read("https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/regions.geojson", what = "sp")
  nr = length(regions)
  noms_regions = regions@data$nom
}


# Récupération de la france
if (!exists("france")){
  france = geojsonio::geojson_read("map.geojson", what = "sp")
  # https://raw.githubusercontent.com/SirZokxyron/LJK2/c83ddcb595c98d53abca1ae3e14cd27ea9120391/france_noe.geojson
}
  

# récupération des densités
if (!exists("dens")){
  
  den = read.csv("pop_density/Densite_Communes.csv")
  dc=c()
  for(j in communes@data$code){
    dcj=den[den$codgeo==j,]
    a1=dcj$an
    n=a1[length(a1)]
    densite=dcj[dcj$an==n,]$dens_pop
    dc=c(dc,c(densite))
  }

  den= read.csv("pop_density/Densite_Departements.csv")
  a1 = unique(den$an)
  n = length(a1)
  a1 = a1[n]
  dd = den$dens_pop[den$an == a1]
  
  den = read.csv("pop_density/Densite_Regions.csv")
  a1 = unique(den$an)
  n = length(a1)
  a1 = a1[n]
  dr = den$dens_pop[den$an == a1]
  
  rm(densite)
  rm(den)
  rm(a1)
  rm(n)
  rm(dcj)
  
  dens = T
}


# couleurs
if (!exists("coul")){
  v = "viridis"
  spectre = c("blueviolet", "mediumblue", "steelblue1", "slategray2", "turquoise1", "yellowgreen", "yellow", "orange2", "red")
  enfer = "inferno"
  glacier = c("azure2", "slategray2", "darkslategray1", "turquoise2", "steelblue1", "cornflowerblue", "dodgerblue", "deepskyblue4", "darkblue")
  rose = c("snow", "#FDE1D3", "#FCCCD3", "#FFB7D3", "#F39DD3", "#FA90C8", "#FA90C8", "hotpink", "#FF3399")
  classique = "YlOrRd"
  coul = T
}