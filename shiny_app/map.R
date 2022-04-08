source("Composantes.R")

# On test si la fonction a déjà été crée
if (!(exists("mapping"))){
  
  # Si elle n'a pas été crée, on le fait
  mapping <- function(geolink, zones, data_density, col, point, col_point){
    "
      geolink est la data des contours des zones
      zones est le noms des zones
      data_density represente les datas des densites par zones
      col est la couleur de la carte
      point est les data correspondants aux coordonnées des dechetteries
      col_point est la couleur des points
    "
    
    # Les niveaux pour la colorbar
    bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, 1400, Inf)
    
    # La palette crée à partir des bins
    pal <- colorBin(col, domain = c(0,90000), bins = bins)
    
    # Les labels affichés lorsque l'utilisateur passe sa souris sur la zone en question
    labels <- sprintf(
      "<strong>%s</strong><br/>%s hab/km^2", 
      zones, data_density
    ) %>% lapply(htmltools::HTML) # Le texte est crée en HTML pour pouvoir faire de la mise en forme
    
    # Création de la map
    map <- leaflet(geolink, options = leafletOptions(minZoom = 5)) %>% # on utilise les données spaciales de geolink et on bloque le zoom à 5
      fitBounds(15, 42, -9, 51) %>% setMaxBounds(15, 42, -9, 52) %>% # On met la "caméra" dans une certaines boite et faisons en sorte que l'on ne puisse sortir de cette dernière
      addProviderTiles("Stamen.TonerBackground") #On met un fond de carte
    
    # On ajoute les contours des zones, mets de la couleur à l'intérieur, affiche les lables et surlignes les contours quand le curseur est à l'intérieur
    map <- addPolygons(map = map,
                       fillColor = ~pal(data_density), 
                       weight =0.5,
                       opacity = 1,
                       color = "white",
                       dashArray = "3",
                       fillOpacity = 0.7,
                       highlightOptions = highlightOptions(
                         weight = 4,
                         color = "#FF0000",
                         dashArray = "",
                         fillOpacity = 0.7,
                         bringToFront = FALSE)
                       ,label = labels
                       ,labelOptions = labelOptions(
                         style = list("font-weight" = "normal", padding = "3px 8px"),
                         textsize = "12px",
                         direction = "auto")
                       )
    
    # On ajoute les points sur la carte aux coordonnées des dechetteries
    map <-  addCircleMarkers(map,
            lng = point$longitude,
            lat = point$latitude,
            radius = 1,
            color = col_point,
            stroke = FALSE, fillOpacity = 0.5)
    
    # On affiche la légende
    map <- addLegend(map = map,pal = pal, values = ~data_density, opacity = 0.7, title = NULL,
                     position = "topright")
    
    # On affiche la map
    map
  }
}

# Calcul de la fenêtre
# Mapping spécial pour les heatmap sans poids
if (!(exists("cal_fenetre"))){
  cal_fenetre <- function(){
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
    return(owin(c(lat_min,lat_max),c(long_min,long_max),poly=list_poly))
  }
  fenetre = cal_fenetre()
}

# Mapping spécial pour les heatmap sans poids
if (!(exists("mapping_dechetterie"))){
  mapping_dechetterie <- function(col){
    if (!exists("fenetre")){
      fenetre = cal_fenetre()
    }
    mypattern2 <- ppp(points$Longitude,points$Latitude, fenetre)
    ds <- density(mypattern2)
    r <- raster(ds)
    crs(r) <- CRS("+init=epsg:4326")
    pal <- colorNumeric(col, values(r),na.color = "transparent")
    map <- leaflet(options = leafletOptions(minZoom = 5)) %>% fitBounds(15,42,-9,51) %>% setMaxBounds(15,42,-9,52) %>% 
      addProviderTiles("Stamen.TonerBackground") %>%
      addRasterImage(r, colors = pal, opacity = 0.8)
    map <- addLegend(map = map,pal = pal, values = values(r), opacity = 0.7, title = NULL,
                     position = "topright")
    map
  }
}

# Mapping de heatmap avec poids
if (!(exists("mapping_poids"))){
  mapping_poids <- function(data,poids,col){
    if (!exists("fenetre")){
      fenetre = cal_fenetre()
    }
    mypattern2 <- ppp(data$Longitude,data$Latitude, fenetre)
    ds <- density(mypattern2, weights = poids)
    r <- raster(ds)
    crs(r) <- CRS("+init=epsg:4326")
    pal <- colorNumeric(col, values(r),na.color = "transparent")
    map <- leaflet(options = leafletOptions(minZoom = 5)) %>% fitBounds(15,42,-9,51) %>% setMaxBounds(15,42,-9,52) %>% 
      addProviderTiles("Stamen.TonerBackground") %>%
      addRasterImage(r, colors = pal, opacity = 0.8)
    map <- addLegend(map = map,pal = pal, values = values(r), opacity = 0.7, title = NULL,
                     position = "topright")
    map
  }
}
