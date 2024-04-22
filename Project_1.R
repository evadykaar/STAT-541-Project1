
# Source for leaflet in a shiny app: https://rstudio.github.io/leaflet/articles/shiny.html
# Source for sorting months in order: https://groups.google.com/g/manipulatr/c/RPMFm--cDt8
# Source for line break in popup: https://blog.hubspot.com/website/html-line-break#:~:text=To%20do%20a%20line%20break%20in%20HTML%2C%20use%20the%20%3Cbr,element%2C%20there's%20no%20closing%20tag.
# Used ChatGPT to set up formating of shiny app, this includes adding the filters and the time series plot

library(shiny)
library(leaflet)
library(tidyverse)
library(here)
library(bslib)

# Dataset and cleaning the dataset
df_911 <- read.csv(here("Data", "Seattle_small_911.csv"))

clean_911 <- df_911 |>
  mutate(
    Datetime = as.Date(mdy_hms(Datetime)),
    Year = year(Datetime),
    Month = factor(months(Datetime), levels = month.name),
    pop = paste("Incident Number:",
                Incident.Number,
                "<br>",
                "Address:",
                Address,
                "<br>",
                "Type:",
                Type,
                "<br>",
                "Date and Time:", Datetime)) |>

  filter(Year == 2023,
         Type %in% c("Aid Response",
                     "Medic Response",
                     "Auto Fire Alarm",
                     "Trans to AMR",
                     "Aid Response Yellow",
                     "Motor Vehicle Accident",
                     "Automatic Fire Alarm Resd",
                     "MVI - Motor Vehicle Incident"))

types <- unique(clean_911$Type)

months <- levels(clean_911$Month)

ui <- fluidPage(
  
  theme = bs_theme(bootswatch = 'journal'),

  # Title of shiny app
  titlePanel("2023 Accidents in Seattle"),

  # Formatting for page
  tags$head(
    tags$style(HTML("
      .map-container {
        position: relative;
        height: 600px;
        width: 900px;
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
      .plot-container {
        position: absolute;
        top: 400px;
        height: 400px;
        width: 900px;
      }
    "))
  ),

  # Map and time series plot
  fluidRow(
    column(width = 8,
           div(class = "map-container",
               leafletOutput("mymap")
           ),
           div(class = "plot-container",
               plotOutput("time_series_plot")
           )
    ),

    # Type and month filters
    column(width = 4,
           div(class = "filter-bar",
               selectInput("type_filter", "Select Type of Accident:",
                           choices = c("All", types)),
               selectInput("month_filter", "Select Month of Accident:",
                           choices = c("All", as.character(months)))
           )
    )
  )
)

server <- function(input, output) {

  # Setting up filtered data
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



  # Map
  output$mymap <- renderLeaflet({
    leaflet() |>
      addProviderTiles(providers$Esri.NatGeoWorldMap) |>
      addCircleMarkers(data = filtered_data(),
                       lat = ~Latitude,
                       lng = ~Longitude,
                       radius = 1,
                       color = "red",
                       popup = ~pop)
  })

  # Time series plot
  output$time_series_plot <- renderPlot({
    ggplot(filtered_data()) +
      geom_line(aes(x = Datetime, y = ..count..),
                stat = "count",
                color = "navy") +
      labs(x = "Date",
           y = " ",
           title = "Number of Accidents per Day Over Time") +
      theme_bw()
  })
}

shinyApp(ui, server)
