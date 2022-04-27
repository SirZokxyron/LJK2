source("composantes.R")

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
    bins <- c(0, 10, 25, 50, 100, 200, 500, 750, 1000, Inf)
  
    # La palette crée à partir des bins
    pal <- colorBin(col, domain = c(0,90000), bins = bins)
    
    # Les labels affichés lorsque l'utilisateur passe sa souris sur la zone en question
    labels <- sprintf(
      "<strong>%s</strong><br/>%s hab/km^2", 
      zones, data_density
    ) %>% lapply(htmltools::HTML) # Le texte est crée en HTML pour pouvoir faire de la mise en forme
    
    # Création de la map
    map <- leaflet(geolink, options = leafletOptions(minZoom = 5)) %>% # on utilise les données spaciales de geolink et on bloque le zoom à 5
      fitBounds(15, 42, -9, 51) %>% setMaxBounds(11,40,-9,55) %>% # On met la "caméra" dans une certaines boite et faisons en sorte que l'on ne puisse sortir de cette dernière
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
    
    labels2 <- sprintf(
      "<strong>%s</strong>", 
      point$Nom
    ) %>% lapply(htmltools::HTML) # Le texte est crée en HTML pour pouvoir faire de la mise en forme
    
    
    # On ajoute les points sur la carte aux coordonnées des dechetteries
    if (dim(point)[1] != 0){
      map <-  addCircles(map,
              lng = point$Longitude,
              lat = point$Latitude,
              radius = 100,
              color = col_point,
              fillOpacity = 1,
              stroke = FALSE,
              label = labels2,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "12px",
                direction = "auto"))
    }
    
    # On affiche la légende
    map <- addLegend(map = map,pal = pal, values = ~data_density, opacity = 0.7, title = NULL,
                     position = "topright")
    
    # On affiche la map
    map
  }
}


# Calcul de la fenêtre      
# Mapping spécial pour les heatmap sans poids
if (!(exists("fenetre"))){
  cal_fenetre <- function(res = c(2000,2000)){
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
    fen = owin(c(lat_min,lat_max),c(long_min,long_max),poly=list_poly)
    return(fen)
  }
  fenetre = cal_fenetre()
}


# Calcul du raster
if (!exists("ras")){
  cal_r <- function(data,fenetre){
    mypattern2 <- ppp(data$Longitude,data$Latitude, fenetre)
    ds <- density(mypattern2,sigma=bw.diggle(mypattern2),diggle=TRUE)
    r <- raster(ds)
    crs(r) <- CRS("+init=epsg:4326")
    return(r)
  }
  
  r_c = function(){
    bary2=barycom[barycom$dens != 0,]
    bary2=ppp(bary2$Longitude,bary2$Latitude,window = fenetre)
    
    g=gridcenters(window=fenetre,50,50)
    
    DensX = function(x,y){
      a=ppp(x,y,window=fenetre)
      barycom$dens[nncross(a,bary2)$which]
    }
    
    
    rslt = as.im(DensX,W=fenetre)
    rslt$v = apply(rslt$v,1,function(x){sapply(x,function(y){return(max(1,y))})})
    rslt = log(rslt)
    rslt$v = t(rslt$v)
    r = raster(rslt)
    crs(r) <- CRS("+init=epsg:4326")
    return(r)
  }
  
  r_rs = cal_r(points[points$Type == "Ressourcerie",],fenetre)
  r_dech = cal_r(points[points$Type == "Déchetterie",],fenetre)
  r_rsd = cal_r(points[points$Type != "Recyclerie",],fenetre)
  r_rc = cal_r(points[points$Type == "Recyclerie",],fenetre)
  r_rcs = cal_r(points[points$Type != "Déchetterie",],fenetre)
  r_rcd = cal_r(points[points$Type != "Ressourcerie",],fenetre)
  r_all = cal_r(points,fenetre)
  
  rcom = r_c()
  ras = T
}


# Mapping spécial pour les heatmap des dechetteries
if (!exists("mapping_dechetterie")){
  mapping_dechetterie <- function(r,col){
    pal <- colorNumeric(col, values(r),na.color = "transparent")
    map <- leaflet(options = leafletOptions(minZoom = 5)) %>% fitBounds(15,42,-9,51) %>% setMaxBounds(11,40,-9,55) %>% 
      addProviderTiles("Stamen.TonerBackground") %>%
      addRasterImage(r, colors = pal, opacity = 0.8)
    map <- addLegend(map = map,pal = pal, values = values(r), opacity = 0.7, title = NULL,
                     position = "topright")
    map
  }
}


# On crée une fonction qui crée la map pour la densité par communes
if(!exists("mapping_communes")){
  mapping_communes <- function(r,col,data,col_point){
    pal <- colorNumeric(col,values(r),na.color = "transparent")
    
    # On crée la map des communes
    map <-  leaflet(options = leafletOptions(minZoom = 5)) %>% 
            fitBounds(15,42,-9,51) %>% 
            setMaxBounds(11,40,-9,55) %>% 
            addProviderTiles("Stamen.TonerBackground") %>%
            addRasterImage(r, colors = pal, opacity = 0.8)
    
    # On crée un label pour les noms des dechetteries
    labels2 <- sprintf(
      "<strong>%s</strong>", 
      data$Nom
    ) %>% lapply(htmltools::HTML) # Le texte est crée en HTML pour pouvoir faire de la mise en forme
    
    # On ajoute les points sur la carte aux coordonnées des dechetteries
    if (dim(data)[1] != 0){
      map <-  addCircles(map,
                         lng = data$Longitude,
                         lat = data$Latitude,
                         radius = 100,
                         color = col_point,
                         fillOpacity = 1,
                         stroke = FALSE,
                         label = labels2,
                         labelOptions = labelOptions(
                           style = list("font-weight" = "normal", padding = "3px 8px"),
                           textsize = "12px",
                           direction = "auto"))
    }
    # On affiche la légende
    map <- addLegend(map = map,pal = pal, values = values(r), opacity = 0.7, title = NULL,
                     position = "topright")
    
    # On affiche la map
    map
  }
}

if(!exists("mapping_dist")){
  r_d = function(){
    bary2=barycom[barycom$dens != 0,]
    bary2=ppp(bary2$Longitude,bary2$Latitude,window = fenetre)
    
    g=gridcenters(window=fenetre,50,50)
    
    duX=function(x,y){
      X=ppp(x,y,window = fenetre)
      nncross(X,bary2)$dist
    }
    
    imDist = as.im(duX,W=fenetre)
    imDist = log(imDist)
    r = raster(imDist)
    crs(r) <- CRS("+init=epsg:4326")
    return(r)
  }
  
  r_dist = r_d()
  
  mapping_dist <- function(r,col){
    pal <- colorNumeric(col,values(r),na.color = "transparent")
    
    # On crée la map des distances
    map <-  leaflet(options = leafletOptions(minZoom = 5)) %>% 
      fitBounds(15,42,-9,51) %>% 
      setMaxBounds(11,40,-9,55) %>% 
      addProviderTiles("Stamen.TonerBackground") %>%
      addRasterImage(r, colors = pal, opacity = 0.8)
    # On affiche la légende
    map <- addLegend(map = map,pal = pal, values = values(r), opacity = 0.7, title = NULL,
                     position = "topright")
    
    # On affiche la map
    map
  }
}
