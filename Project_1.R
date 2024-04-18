library(tidyverse)
library(here)
library(shiny)


# Load required libraries
library(shiny)
library(leaflet)

# Define example data
df_911 <- read.csv(here("Data", "Seattle_small_911.csv"))

clean_911 <- df_911 |>
  mutate(Datetime = mdy_hms(Datetime),
         Year = year(Datetime))

# Define UI for application
ui <- fluidPage(

  titlePanel("Map Filter"),

  sidebarLayout(
    sidebarPanel(
      selectInput("type", "Select Type:", choices = c("All", unique(clean_911$Type))),
      sliderInput("year", "Select Year Range:", min = min(clean_911$Year), max = max(clean_911$Year), value = c(min(clean_911$Year), max(clean_911$Year)))
    ),
    mainPanel(
      leafletOutput("map")
    )
  )
)

# Define server logic
server <- function(input, output) {

  filteredData <- reactive({
    req(input$Type)
    req(input$Year)
    if (input$Type == "All") {
      filtered <- data[clean_911$Year >= input$Year[1] & clean_911$Year <= input$Year[2], ]
    } else {
      filtered <- clean_911[clean_911$Type == input$Type & clean_911$Year >= input$Year[1] & clean_911$Year <= input$Year[2], ]
    }
    filtered
  })

  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Esri.WorldImagery") %>%
      addTiles() %>%
      addCircleMarkers(data = clean_911, lat = ~Latitude,
                       lng = ~Longitude,
                       opacity = ~5) %>%
      addMarkers(data = filteredData(), popup = ~paste("Type:", Type, "<br>", "Year:", Year))
  })
}

# Run the application
shinyApp(ui = ui, server = server)


# Source for leaflet in a shiny app: https://rstudio.github.io/leaflet/articles/shiny.html