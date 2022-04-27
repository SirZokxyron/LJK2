# Shiny
source("map.R")

if(!(exists("ui"))){
  
  # on crée l'ui pour l'app shiny
  ui <- fluidPage(
    # On affiche le titre
    titlePanel("Déchetterie"),
    
    # On affiche sur un côté :
    sidebarLayout(
      sidebarPanel(
        # On met un bouton contour qui demande à l'utilisateur quel contour il veut
        selectInput("contour", 
                    label = "Quel type d'information",
                    choices = c("Densité par Commune", 
                                "Densité par Département",
                                "Densité par Région",
                                "Heatmap des Distances",
                                "Heatmap des Déchetteries"),
                    selected = "Densité par Département",),
        
      # Représente le choix des années pour la densité
      # selectionner les années dans les densitées afin de les affichers
      checkboxGroupInput("deche", 
                  label = "Type de Dechetteries sélectionnée",
                  choices = c("Ressourceries" = "1","Dechetteries" = "2","Recycleries" = "4"),
                  selected = c("1","2","4")),
      
      # Pour sélectionner la couleur de la carte
      selectInput("couleur", 
                  label = "Couleur",
                  choices = c("Viridis", 
                              "Spectre des Couleurs",
                              "Inferno",
                              "Glacier",
                              "Rose",
                              "Classique"),
                  selected = "Classique"),
      ),
      
      # Sur le panel de base
      mainPanel(
        # On affiche la map
        leafletOutput("map")
      )
    )
  )
}


if(!(exists("server"))){
  # On crée un server pour réagir à l'ui
  server <- function(input, output) {
    
    # On affiche la map
    output$map <- renderLeaflet({
      # On change de zones quand on choisit une autre zone
      zone = switch(input$contour,
                       "Densité par Département" = noms_departements,
                       "Densité par Région" = noms_regions)
    
      # On change de contour quand on change de zone
      cont = switch(input$contour,
                       "Densité par Commune" = france , # Mettre la france à la place
                       "Densité par Département" = departements,
                       "Densité par Région" = regions,
                       "Heatmap des Distances" = france,
                       "Heatmap des Déchetteries" = france)
      
      # On change de densité quand on change de zone et qu'on change d'année de densité
      densit = switch(input$contour,
                       "Densité par Commune" = dc,
                       "Densité par Département" = dd,
                       "Densité par Région" = dr)
      
      # On change de couleur quand on change la couleur
      col = switch(input$couleur,
                   "Viridis" = v,
                   "Spectre des Couleurs" = spectre,
                   "Inferno" = enfer,
                   "Rose" = rose,
                   "Glacier" = glacier,
                   "Classique" = classique)
  
      # On change la couleur des points quand on change la couleur générale
      col_point = switch(input$couleur,
                         "Viridis" = "red",
                         "Spectre des Couleurs" = "purple",
                         "Inferno" = "blue",
                         "Rose" = "green",
                         "Glacier" = "red",
                         "Classique" = "blue")
      
      choixdech = sum(as.integer(input$deche))
      choixdech
      r = switch(choixdech,
                 "1" = r_rs,
                 "2" = r_dech,
                 "3" = r_rsd,
                 "4" = r_rc,
                 "5" = r_rcs,
                 "6" = r_rcd,
                 "7" = r_all)
      
      points_s = switch(choixdech,
                        "1" = points[points$Type == "Ressourcerie",],
                        "2" = points[points$Type == "Déchetterie",],
                        "3" = points[points$Type != "Recyclerie",],
                        "4" = points[points$Type == "Recyclerie",],
                        "5" = points[points$Type != "Déchetterie",],
                        "6" = points[points$Type != "Ressourcerie",],
                        "7" = points)
      
      # On affiche la map avec tous les changements
      mapp = switch(input$contour,
                   "Densité par Commune" = mapping_communes(rcom,col,points_s,col_point), 
                   "Densité par Département" =  mapping(cont, zone, densit, col, points_s, col_point),
                   "Densité par Région" =  mapping(cont, zone, densit, col, points_s, col_point),
                   "Heatmap des Distances" = mapping_dist(r_dist,col),
                   "Heatmap des Déchetteries" = mapping_dechetterie(r,col))
    })
  }
}


# On affiche l'application avec l'ui et le server
shinyApp(ui, server)
