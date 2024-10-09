#' site_reporting UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_site_reporting_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h1("Site Reporting"),  # Adding the title here
    # Other UI elements can go here
  )
}

    
#' site_reporting Server Functions
#'
#' @noRd 
mod_site_reporting_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_site_reporting_ui("site_reporting_1")
    
## To be copied in the server
# mod_site_reporting_server("site_reporting_1")
