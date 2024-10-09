#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  mod_site_map_server("site_map_1")
  mod_site_reporting_server("site_reporting_1")
  # Your application server logic
}
