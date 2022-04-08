# Importation des librairies
if (!exists("libr")){
  library(leaflet)
  library(geojsonio)
  library(shiny)
  library(raster)
  library(spatstat)
  libr = T
}


# Pseudo data base
if (!exists("dead")){
  choix1 = c("a", "a2")
  choix2 = c("b", "b2") 
  choix3 = c("c", "c2") 
  nam = c("Commune", "Département", "Région")
  # Exemple de traitement de data base
  dead = data.frame(cbind("Commune" = choix1, "Département" = choix2, "Région" = choix3))
  con = dead$Département
}

# Récupération des cooordonnées des déchetteries
if (!exists("dech")){
  
  points = read.csv("DB.csv")
  points = points[40<points$Latitude && points$Latitude<52,]
  points = points[points$Longitude>-9 && points$Longitude<15,]
  
  point = data.frame(cbind("longitude" = 5, "latitude" = 45))
  dech = T
}

# Recupérations des communes
if (!exists("communes")){
  communes = geojsonio::geojson_read("https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/communes.geojson", what = "sp")
  nc = length(communes)
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
  france = geojsonio::geojson_read("https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/metropole.geojson", what = "sp")
}
  
# récupération des densités
if (!exists("dens")){
  dc = sample(0:1500, nc, replace = T)
  dd = sample(0:1500, nd, replace = T)
  dr = sample(0:1500, nr, replace = T)
  dens = T
}

# couleurs
if (!exists("coul")){
  v = "viridis"
  p = c("blueviolet", "mediumblue", "steelblue1", "slategray2", "turquoise1", "yellowgreen", "yellow", "orange2", "red")
  enf = "inferno"
  Xx_Dark_Ice_Gold_xX = c("azure2", "slategray2", "darkslategray1", "turquoise2", "steelblue1", "cornflowerblue", "dodgerblue", "deepskyblue4", "darkblue")
  rause = c("snow", "#FDE1D3", "#FCCCD3", "#FFB7D3", "#F39DD3", "#FA90C8", "#FA90C8", "hotpink", "#FF3399")
  c = "YlOrRd"
  coul = T
}