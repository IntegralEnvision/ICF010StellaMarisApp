#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import gargle
#' @import googleAuthR
#' @import googlesheets4
#' @noRd
app_server <- function(input, output, session) {
  gs4_deauth()  # Start with new authentication
  
  gs4_auth(path = "stella-maris-439901-04f2bd561593.json")
  
  # Check if authentication was successful
  if (!gs4_has_token()) {
    showModal(modalDialog(
      title = "Authentication Failed",
      "Authentication was not successful. Please check the service account credentials.",
      easyClose = TRUE
    ))
    return()  # Stop further execution if authentication fails
  }
  
  # Module Servers
  mod_site_reporting_server("site_reporting_1")
  mod_turtle_walk_reporting_server("turtle_walk_reporting_1")
  mod_light_reporting_server("light_reporting_1")
  mod_site_map_server("site_map_1")
}
