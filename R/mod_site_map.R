#' site_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @import leaflet
mod_site_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h1("Site Map"),  # Adding the title here
    leafletOutput(ns("map"), height = 500)  # Adding the Leaflet map output
  )
}
    
#' site_map Server Functions
#'
#' @noRd 
mod_site_map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Render the Leaflet map
    output$map <- renderLeaflet({
      leaflet() %>%
        setView(lng = -80.6077, lat = 28.0836, zoom = 12) %>%  # Centered on Melbourne, FL
        addTiles()  # Add default OpenStreetMap tiles
    })
  })
}
    
## To be copied in the UI
# mod_site_map_ui("site_map_1")
    
## To be copied in the server
# mod_site_map_server("site_map_1")
