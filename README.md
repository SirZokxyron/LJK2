# LJK2
A data science visualization project in the cursus of our L3 M&I at UGA

## The Team

Hugo Bensbia (manager), Paul Andre, Youssef Abyaa, Noe Romain, Victor Sigrist, Jude Coulavin

## Repo organization

### pop_density

file: `script_density.py`  
info: download population density  
usage: launch with python 3  
dependancies: BeautifulSoup, Requests  

file: `*.xlsx`  
info: Raw excel files downloaded from the INSEE study  

file: `*.csv`  
info: Converted files to comma separated values  

### landfills

file: `script_landfills.py`  
info: creates landfills database and filter oversea France  
usage: launch with python 3  
dependancies: Requests, BeautifulSoup, Pandas, Rich

file: `landfills.csv`  
info: the landfill database  

### R/Shiny app

Dependancies: leaflet, raster, rgdal, geojsonio, shiny, spatstat   
info: it will take a will to load all the maps on the first opening

`composantes.R`: defines all the core variables for our app  

`map.R`: creates all the maps  

`app.R`: launches the app with the gui

`correlation.R`: all our tests to uncover the link between population density and landfill position
