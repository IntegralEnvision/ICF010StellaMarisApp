#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  gs4_deauth()
  
  # Create a reactive value to track authentication status
  auth_status <- reactiveVal(FALSE)
  
  # Show the authentication warning message
  showModal(modalDialog(
    title = "Authentication Required",
    "You must authenticate your Google account in order to access the datasheets for this project. After inputting your credentials, be sure to select the checkbox to enable access to Google Sheets.",
    easyClose = FALSE,
    footer = tagList(
      actionButton("cancel_button", "Cancel"),
      actionButton("auth_button", "Authenticate")
    )
  ))
  
  # Observe the cancel button click
  observeEvent(input$cancel_button, {
    stopApp()  # Close the app if the user cancels
  })
  
  # Observe the authentication button click
  observeEvent(input$auth_button, {
    # Proceed with authentication
    gs4_auth(cache = FALSE, scopes = c("https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive"))
    
    # Check if authentication was successful
    if (gs4_has_token()) {
      auth_status(TRUE)  # Update the authentication status
      removeModal()      # Close the modal after authentication
    } else {
      showModal(modalDialog(
        title = "Authentication Failed",
        "Authentication was not successful. Please try again.",
        easyClose = TRUE
      ))
    }
  })
  
  # Use a reactive expression to check authentication status
  observe({
    req(auth_status())  # Ensure authentication is complete before proceeding
    mod_site_reporting_server("site_reporting_1")
    mod_site_map_server("site_map_1")
  })
}
