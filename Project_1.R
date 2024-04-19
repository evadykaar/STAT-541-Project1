
# Source for leaflet in a shiny app: https://rstudio.github.io/leaflet/articles/shiny.html



# library(shiny)
# library(leaflet)
# library(tidyverse)
# library(here)
# 
# df_911 <- read.csv(here("Data", "Seattle_small_911.csv"))
# 
# clean_911 <- df_911 |>
#   mutate(Datetime = mdy_hms(Datetime),
#          Year = year(Datetime)) |>
#   filter(Year == 2023,
#          Type %in% c("Aid Response",
#                      "Medic Response",
#                      "Auto Fire Alarm",
#                      "Trans to AMR",
#                      "Aid Response Yellow",
#                      "Motor Vehicle Accident",
#                      "Automatic Fire Alarm Resd",
#                      "MVI - Motor Vehicle Incident"))
# 
# 
# ui <- fluidPage(
#   leafletOutput("mymap")
# )
# 
# server <- function(input, output) {
# 
#   output$mymap <- renderLeaflet({
#     leaflet() |>
#       addProviderTiles(providers$Esri.NatGeoWorldMap) |>
#       addCircleMarkers(data = clean_911,
#                        lat = ~Latitude,
#                        lng = ~Longitude)
#   })
# }
# 
# shinyApp(ui, server)


library(shiny)
library(leaflet)
library(tidyverse)
library(here)

df_911 <- read.csv(here("Data", "Seattle_small_911.csv"))

clean_911 <- df_911 |>
  mutate(Datetime = mdy_hms(Datetime),
         Year = year(Datetime),
         Month = months(Datetime)) |>
  filter(Year == 2023,
         Type %in% c("Aid Response",
                     "Medic Response",
                     "Auto Fire Alarm",
                     "Trans to AMR",
                     "Aid Response Yellow",
                     "Motor Vehicle Accident",
                     "Automatic Fire Alarm Resd",
                     "MVI - Motor Vehicle Incident"))

# Unique types for type dropdown menu
types <- unique(clean_911$Type)

# Unique months for month dropdown menu
months <- unique(clean_911$Month)

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .map-container {
        position: relative;
        height: 800px;
      }
      .filter-bar {
        position: absolute;
        top: 10px;
        right: 20px;
        z-index: 1000;
        background-color: white;
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 5px;
      }
    "))
  ),
  fluidRow(
    column(width = 8,
           div(class = "map-container",
               leafletOutput("mymap")
           )
    ),
    column(width = 4,
           div(class = "filter-bar",
               selectInput("type_filter", "Select Type:",
                           choices = c("All", types)),
               selectInput("month_filter", "Select Month:",
                           choices = c("All", as.character(months)))
           )
    )
  )
)

server <- function(input, output) {
  
  filtered_data <- reactive({
    data <- clean_911
    
    if (input$type_filter != "All") {
      data <- filter(data, Type == input$type_filter)
    }
    
    if (input$month_filter != "All") {
      data <- filter(data, Month == input$month_filter)
    }
    
    return(data)
  })
  
  output$mymap <- renderLeaflet({
    leaflet() |>
      addProviderTiles(providers$Esri.NatGeoWorldMap) |>
      addCircleMarkers(data = filtered_data(),
                       lat = ~Latitude, 
                       lng = ~Longitude)
  })
}

shinyApp(ui, server)





