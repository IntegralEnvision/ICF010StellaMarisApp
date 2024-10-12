#' site_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @import dplyr
#' @import lubridate
#' @import leaflet
#' @import leaflet.extras
#' @import bslib
#' @import googlesheets4
mod_site_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$head(
      tags$style(HTML("
        .custom-button {
          background-color: #66ccff;  /* Light green */ 
          color: black;                /* Text color */
          border: none;                /* Remove border */
          padding: 10px 20px;          /* Padding */
          border-radius: 5px;          /* Rounded corners */
        }
        .custom-button:hover {
          background-color: #0099cc;   /* Darker green on hover */
        }
        .info-text {
          font-size: 24px;             /* Increase font size */
          font-weight: bold;           /* Make text bold */
          text-align: center;          /* Center text */
          padding: 20px;               /* Add padding */
        }
      ")) # light green (90EE90)
    ),
    bslib::page_fluid(
      bslib::navset_card_underline(
        bslib::nav_panel(
          "Site Map Viewer",
          bslib::layout_sidebar(
            sidebar = bslib::sidebar(
              width = '300px',
              dateRangeInput(
                inputId = ns("date_range"),
                label = "Select Date Range",
                start = as.Date("2024-01-01"),  # Default start date
                end = Sys.Date()            # Default end date
              ),
              selectInput(
                inputId = ns("nest_dig"),
                label = "Nest Dig",
                choices = c("All Sites", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"),  # Add your locations here
                selected = NULL,
                multiple = FALSE
              ),
              actionButton(
                inputId = ns("update_map"),
                label = "Update Map",
                class = "custom-button"  # Use your custom class
              )
            ),
            bslib::layout_column_wrap(
              leafletOutput(ns("map"), height = "600px"),  # Leaflet map output
              width = 1
            )
          )
        ),
        bslib::nav_panel(
          "Additional Information",
          div(class = "info-text",  # Apply custom class for styling
              "Add text, pictures, stats, etc.")
        )
      )
    )
  )
}
    
#' site_map Server Functions
#'
#' @noRd 
mod_site_map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    data_sheet_id <- "1P1xYJtAaR5MdxWqb05JS6_3RqGAWbg2cZxhat2piSDc"  # Sheet for submitted data
    sheet_data <- reactive({
      # Read data from the Google Sheet
      data <- read_sheet(sheet_id) %>%
        mutate(Emergence_Date = ymd(Emergence_Date))  # Convert to date format
      return(data)
    })
    
    location_sheet_id <- "1TZF3y-ABfs8bCWHhQOonOHw9r7vdTO_iI0UeqP7ZdqQ" # Sheet for Nest locations
    location_data <- reactive({
      loc_data <- read_sheet(location_sheet_id) %>%
        mutate(Nest_Dig = as.character(Nest_Dig))  # Convert to character
      return(loc_data)
    })
    
    # Render the Leaflet map
    output$map <- renderLeaflet({
      leaflet() %>%
        setView(lng = -80.6077, lat = 28.0836, zoom = 12) %>%  # Centered on Melbourne, FL
        leaflet::addProviderTiles(
          leaflet::providers$Esri.WorldImagery,
          group = "Satellite"
        ) %>%  # Use %>% to chain addTiles
        leaflet::addProviderTiles(
          leaflet::providers$Esri.WorldTopoMap,
          group = "Topographic"
        ) %>%
        leaflet::addLayersControl(
          baseGroups = c(
            "OSM",
            "Topographic",
            "Satellite"
          )) %>%
        addTiles() 
    })
    
    observe({
      loc_data <- location_data()
      
      if (!is.null(loc_data) && nrow(loc_data) > 0) {
        leafletProxy(ns("map")) %>%
          clearMarkers() %>%
          addMarkers(data = loc_data,
                            lng = ~Longitude,
                            lat = ~Latitude,
                            popup = ~paste(
                              "<br><b>Nest Dig:</b>", Nest_Dig))
                            # icon = awesomeIcons(
                            #   icon = 'circle',  # Change to desired icon (without library)
                            #   markerColor = 'blue' # Change to desired color
                            # ))  # Customize popup content as needed
      }
    })
    
    # Observe the update map button
    observeEvent(input$update_map, {
      req(input$date_range)
      
        sheet_data <- read_sheet(sheet_id) %>%
          mutate(Emergence_Date = ymd(Emergence_Date), Nest_Dig = as.character(Nest_Dig))  # Convert to date format
        
        loc_data <- read_sheet(location_sheet_id) %>%
          mutate(Nest_Dig = as.character(Nest_Dig))
      
      # Filter the data based on the date range and nest dig
      filtered_data <- sheet_data %>%
        filter(!is.na(Emergence_Date) & 
                 Emergence_Date >= input$date_range[1] & 
                 Emergence_Date <= input$date_range[2] & 
                 (Nest_Dig == input$nest_dig | input$nest_dig == "All Sites"))
      
      # Join with location data to get Longitude and Latitude
      map_data <- filtered_data %>%
        left_join(loc_data, by = "Nest_Dig")
      
      # Add points to the Leaflet map
      leafletProxy(ns("map")) %>%
        clearMarkers() %>%
        addMarkers(data = map_data,
                   lng = ~Longitude,
                   lat = ~Latitude,
                   popup = ~paste(
                              "<br><b>Nest Dig:</b>", Nest_Dig))  # Customize popup content as needed
    })
  })
}
    
## To be copied in the UI
# mod_site_map_ui("site_map_1")
    
## To be copied in the server
# mod_site_map_server("site_map_1")
