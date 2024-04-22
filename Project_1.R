
# Source for leaflet in a shiny app: https://rstudio.github.io/leaflet/articles/shiny.html
# Source for sorting months in order: https://groups.google.com/g/manipulatr/c/RPMFm--cDt8
# Source for line break in popup: https://blog.hubspot.com/website/html-line-break#:~:text=To%20do%20a%20line%20break%20in%20HTML%2C%20use%20the%20%3Cbr,element%2C%20there's%20no%20closing%20tag.
# Used ChatGPT to set up formating of shiny app, this includes adding the filters and the time series plot
# Source for theme/shiny app formating: https://rstudio.github.io/bslib/reference/sidebar.html

library(shiny)
library(leaflet)
library(tidyverse)
library(here)
library(bslib)
library(bsicons)

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


ui <- page_sidebar(
  
  theme = bs_theme(bootswatch = "sandstone", 
                   base_font = "Helvetica now",
                   heading_font = "Helvetica now"),
  
  title = "2023 Accidents in Seattle",
  
  sidebar = list(
    selectInput("type_filter", "Select Type of Accident:",
                choices = c("All", types)),
    selectInput("month_filter", "Select Month of Accident:",
                choices = c("All", as.character(months)))
    ),
  layout_columns(
    card(card_header("Map of 911 Accidents in Seattle"),
         leafletOutput('mymap')),
    
    card(card_header("Number of Accidents per Day Over Time"),
         plotOutput('time_series_plot')),
    
    value_box(title = "Average Number of Accidents per Day",
              textOutput("average_accidents"),
              showcase = bs_icon("person-fill-exclamation")),
    
    col_widths = c(12, 9, 3)
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
      labs(x = " ",
           y = " ") +
      theme_bw()
  })
  
  # Calculate average number of accidents for value box
  output$average_accidents <- renderText({
    data <- filtered_data()
    total_accidents <- nrow(data)
    start_date <- min(data$Datetime)
    end_date <- max(data$Datetime)
    total_days <- as.numeric(difftime(end_date, start_date, units = "days"))
    average_accidents <- total_accidents / total_days
    round(average_accidents)
  })
  
}

shinyApp(ui, server)
