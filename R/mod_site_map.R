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
        .warning-text {
          color: red;                  /* Red text color */
          font-size: 16px;             /* Font size */
          text-align: center;          /* Center text */
          margin-top: 10px;            /* Spacing above the text */
        }
      "))
    ),
    bslib::page_fluid(
      bslib::navset_card_underline(
        bslib::nav_panel(
          "Site Map Viewer",
          bslib::layout_sidebar(
            sidebar = bslib::sidebar(
              width = '300px',
              selectInput(
                inputId = ns("data_source"),
                label = "DATA SOURCE",
                choices = c("", "Nest Digs", "Public Turtle Walks", "Sky Quality: Light Measurments"), 
                selected = NULL,
                multiple = FALSE
              ),
              dateRangeInput(
                inputId = ns("date_range"),
                label = "SELECT DATE RANGE",
                start = as.Date("2024-01-01"),  # Default start date
                end = Sys.Date()                 # Default end date
              ),
              # Conditional UI for Nest Digs
              conditionalPanel(
                condition = sprintf("input['%s'] == 'Nest Digs'", ns("data_source")),
                selectInput(
                  inputId = ns("nest_dig"),
                  label = "NEST DIG",
                  choices = c("All Sites", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"),
                  selected = NULL,
                  multiple = FALSE
                )
              ),
              # Conditional UI for Public Turtle Walks
              conditionalPanel(
                condition = sprintf("input['%s'] == 'Public Turtle Walks'", ns("data_source")),
                selectInput(
                  inputId = ns("walk_site"),
                  label = "WALK SITE",
                  choices = c("All Sites", "1", "2", "3", "4"),
                  selected = NULL,
                  multiple = FALSE
                )
              ),
              # Conditional UI for Sky Quality Measurements
              conditionalPanel(
                condition = sprintf("input['%s'] == 'Sky Quality: Light Measurments'", ns("data_source")),
                selectInput(
                  inputId = ns("study_site"),
                  label = "STUDY SITE",
                  choices = c("All Sites", "1", "2", "3"),
                  selected = NULL,
                  multiple = FALSE
                )
              ),
              actionButton(
                inputId = ns("update_map"),
                label = "Load Map",
                class = "custom-button"  # Use your custom class
              ),
              tags$p(
                "*These are example data points and do not show the actual location of the nests. This is just an example of the possible filter options that can be applied to this map.",
                class = "warning-text"   # Apply the warning text class
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
    location_sheet_id <- "1TZF3y-ABfs8bCWHhQOonOHw9r7vdTO_iI0UeqP7ZdqQ" # Sheet for Nest locations
    
    # Render the Leaflet map
    output$map <- renderLeaflet({
      leaflet() %>%
        setView(lng = -80.6077, lat = 28.0836, zoom = 12) %>%  # Centered on Melbourne, FL
        leaflet::addProviderTiles(
          leaflet::providers$Esri.WorldImagery,
          group = "Satellite"
        ) %>%
        leaflet::addProviderTiles(
          leaflet::providers$Esri.WorldTopoMap,
          group = "Topographic"
        ) %>%
        leaflet::addLayersControl(
          baseGroups = c("OSM", "Topographic", "Satellite")) %>%
        addTiles() 
    })
    
    # Observe the update map button
    observeEvent(input$update_map, {
      
      # Check if a data source is selected
      if (is.null(input$data_source) || input$data_source == "") {
        showNotification("Please select a data source", type = "warning")
        return()  # Exit if no data source is selected
      }
      req(input$data_source)
      
      data_sheet_name <- switch(input$data_source,
                                "Nest Digs" = "Nest_Digs",                      
                                "Public Turtle Walks" = "Turtle_Walks",        
                                "Sky Quality: Light Measurments" = "Light_Measurments"  
      )
      
      # Load the relevant data from the specified sheet
      sheet_data <- read_sheet(data_sheet_id, sheet = data_sheet_name)
      
      # Check for the presence of Emergence_Date and rename if it exists
      if ("Emergence_Date" %in% colnames(sheet_data)) {
        sheet_data <- sheet_data %>%
          rename(Date = Emergence_Date) %>%
          mutate(Date = ymd(Date))  # Convert to date format
      } else if ("Date" %in% colnames(sheet_data)) {
        sheet_data <- sheet_data %>%
          mutate(Date = ymd(Date))  # Convert to date format
      } else {
        showNotification("No valid date column found", type = "error")
        return()  # Exit if no date column is found
      }
      
      location_sheet_name <- switch(input$data_source,
                                    "Nest Digs" = "Nest_Digs",                      
                                    "Public Turtle Walks" = "Turtle_Walks",        
                                    "Sky Quality: Light Measurments" = "Light_Measurments"  
      )
      
      # Load the relevant location data from the specified sheet
      loc_data <- read_sheet(location_sheet_id, sheet = location_sheet_name)
      
      # Process loc_data based on data source
      if (input$data_source == "Nest Digs") {
        loc_data <- loc_data %>%
          mutate(Nest_Dig = as.character(Nest_Dig))
        sheet_data <- sheet_data %>%
          mutate(Nest_Dig = as.character(Nest_Dig))  # Convert to character if needed
        filter_col <- "Nest_Dig"
        selected_site <- input$nest_dig
      } else if (input$data_source == "Public Turtle Walks") {
        loc_data <- loc_data %>%
          mutate(Walk_Site = as.character(Walk_Site))
        sheet_data <- sheet_data %>%
          mutate(Walk_Site = as.character(Walk_Site))
        filter_col <- "Walk_Site"
        selected_site <- input$walk_site
      } else if (input$data_source == "Sky Quality: Light Measurments") {
        loc_data <- loc_data %>%
          mutate(Study_Site = as.character(Study_Site))
        sheet_data <- sheet_data %>%
          mutate(Study_Site = as.character(Study_Site)) 
        filter_col <- "Study_Site"
        selected_site <- input$study_site
      }
      
      # Filter the data based on the date range and selected site
      filtered_data <- sheet_data %>%
        filter(
          !is.na(Date) & Date >= input$date_range[1] & Date <= input$date_range[2] &
            (get(filter_col) == selected_site | selected_site == "All Sites")
        )
      
      # Join filtered data with location data to get Longitude and Latitude
      map_data <- filtered_data %>%
        left_join(loc_data, by = filter_col)
      
      # Add points to the Leaflet map
      leafletProxy(ns("map")) %>%
        clearMarkers() %>%
        addMarkers(data = map_data,
                   lng = ~Longitude,
                   lat = ~Latitude,
                   popup = ~paste("<br><b>Site:</b>", get(filter_col)))  # Customize popup content as needed
    })
  })
}
    
## To be copied in the UI
# mod_site_map_ui("site_map_1")
    
## To be copied in the server
# mod_site_map_server("site_map_1")
