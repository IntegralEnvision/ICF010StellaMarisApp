#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    
    tags$head(
      tags$style(HTML("
        .fixed-button {
          position: fixed;
          top: 20px; /* Adjust as needed */
          right: 20px; /* Adjust as needed */
          z-index: 1000; /* Ensure it stays on top */
        }
        /* Reduce spacing between the navbar and module content */
        .bslib-nav {
          margin-bottom: 5px; /* Adjust the value as needed */
        }
        .navbar-brand {
          margin-bottom: 0; /* Remove margin from the brand/logo */
        }
      "))
    ),
    
    bslib::page_navbar(
      title = div(
        style = "margin: 10px; padding: 5px;",  # Reduced margin for the title
        img(src = "www/SM.LOGO.png", width = '180px'),
        span(style = "font-size: 26px", "")  # Increase font size here
      ),
      id = "nav",
      bslib::nav_panel("Report Nest Dig Data", mod_site_reporting_ui("site_reporting_1")),
      bslib::nav_panel("Report Turtle Walk Data", mod_turtle_walk_reporting_ui("turtle_walk_reporting_1")),
      bslib::nav_panel("Report Light Survey Data", mod_light_reporting_ui("light_reporting_1")),
      bslib::nav_panel("Site Map", mod_site_map_ui("site_map_1")),
      bslib::nav_item(
        div(
          tags$span(
            class = "fixed-button",
            "Draft",
            style = "font-size: 45px; background-color: #f44336;"
          )
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "StellaMarie"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
