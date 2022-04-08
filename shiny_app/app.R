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
      selectInput("densitee", 
                  label = "Densités",
                  choices = con,
                  selected = con[1]),
      
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
  server <- function(input, output, session) {
    
    # On affiche la map
    output$map <- renderLeaflet({
      # On change de zones quand on choisit une autre zone
      zone = switch(input$contour,

                       "Densité par Département" = noms_departements,
                       "Densité par Région" = noms_regions)
    
      # On change de contour quand on change de zone
      cont = switch(input$contour,
                       "Densité par Commune" = communes, # Mettre la france à la place
                       "Densité par Département" = departements,
                       "Densité par Région" = regions,
                       "Heatmap des Distances" = france,
                       "Heatmap des Déchetteries" = france)
      
      # On change de densité quand on change de zone et qu'on change d'année de densité
      densit = switch(input$contour,
                       "Densité par Commune" = dc,
                       "Densité par Département" = dd,
                       "Densité par Région" = dr)
      # Rajouter la selection d'année avec [input$densitee]
      
      # On change les valeurs de densité possible quand on change de zones
      # observe({
      #   arg <- input$contour
      #   updateSelectInput(session, "densitee",
      #                     label = "Densité",
      #                     choices = dead[,arg],
      #                     selected = tail(dead[,arg],1))
      # })
  
      # On change de couleur quand on change la couleur
      col = switch(input$couleur,
                   "Viridis" = v,
                   "Spectre des Couleurs" = p,
                   "Inferno" = enf,
                   "Rose" = rause,
                   "Glacier" = Xx_Dark_Ice_Gold_xX,
                   "Classique" = c)
  
      # On change la couleur des points quand on change la couleur générale
      col_point = switch(input$couleur,
                         "Viridis" = "red",
                         "Spectre des Couleurs" = "purple",
                         "Inferno" = "blue",
                         "Rose" = "green",
                         "Glacier" = "red",
                         "Classique" = "blue",)
      
      # On affiche la map avec tous les changements
      brr = switch(input$contour,
                   "Densité par Commune" = mapping_dechetterie(col), 
                   "Densité par Département" =  mapping(cont, zone, densit, col, point, col_point),
                   "Densité par Région" =  mapping(cont, zone, densit, col, point, col_point),
                   "Heatmap des Distances" = mapping_dechetterie(col),
                   "Heatmap des Déchetteries" = mapping_dechetterie(col))
    })
  }
}

# On affiche l'application avec l'ui et le server
shinyApp(ui, server)
