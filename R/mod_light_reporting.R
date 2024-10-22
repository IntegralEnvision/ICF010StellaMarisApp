#' light_reporting UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_light_reporting_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$style(HTML("
      .btn-auth {
        background-color: #66cc66; 
        border-color: gray; 
        color: black; 
        margin-bottom: 15px; 
        margin-right: 1px;
      }
      .btn-auth:hover {
        background-color: #55b755;  /* Darker green on hover */
      }
      .btn-submit {
        background-color: #66ccff; 
        border-color: gray; 
        color: black; 
        display: block; 
        margin: auto; 
        margin-top: 15px;
      }
      .btn-submit:hover {
        background-color: #0099cc;  /* Darker blue on hover */
      }
    ")),
    
    bslib::page_fluid(
      fluidRow(
        # First column with a border
        column(
          width = 3,
          div(style = "border: 1px solid gray; padding: 10px; border-radius: 10px;",
              dateInput(ns("date"), label = "DATE"),
              textInput(ns("study_site"), label = "STUDY SITE"),
              textInput(ns("observer"), label = "OBSERVER"),
              textInput(ns("wp"), label = "WP"),
              textInput(ns("site_description"), label = "SITE DESCRIPTION")
          )
        ),
        
        # Four columns within a single border
        column(
          width = 9,
          div(style = "border: 1px solid gray; padding: 10px; border-radius: 10px;",
              fluidRow(
                column(
                  width = 3,
                  textInput(ns("ocean_1"), label = "OCEAN 1"),
                  textInput(ns("ocean_2"), label = "OCEAN 2"),
                  textInput(ns("ocean_3"), label = "OCEAN 3"),
                  textInput(ns("ocean_4"), label = "OCEAN 4")
                ),
                column(
                  width = 3,
                  textInput(ns("south_1"), label = "SOUTH 1"),
                  textInput(ns("south_2"), label = "SOUTH 2"),
                  textInput(ns("south_3"), label = "SOUTH 3"),
                  textInput(ns("south_4"), label = "SOUTH 4")
                ),
                column(
                  width = 3,
                  textInput(ns("dune_1"), label = "DUNE 1"),
                  textInput(ns("dune_2"), label = "DUNE 2"),
                  textInput(ns("dune_3"), label = "DUNE 3"),
                  textInput(ns("dune_4"), label = "DUNE 4")
                ),
                column(
                  width = 3,
                  textInput(ns("north_1"), label = "NORTH 1"),
                  textInput(ns("north_2"), label = "NORTH 2"),
                  textInput(ns("north_3"), label = "NORTH 3"),
                  textInput(ns("north_4"), label = "NORTH 4")
                )
              )
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          actionButton(ns("submit_data"), label = "SUBMIT LIGHT SURVEY DATA",
                       class = "btn-submit")  # Apply custom class
        )
      )
    )
  )
}
    
#' light_reporting Server Functions
#'
#' @noRd 
mod_light_reporting_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Reactive value to store the submitted data
    data <- reactiveVal(data.frame(
      Measurement_Date = as.Date(character()),
      Study_Site = character(),
      Observer = character(),
      WP = character(),
      Site_Description = character(),
      Ocean_1 = character(),
      Ocean_2 = character(),
      Ocean_3 = character(),
      Ocean_4 = character(),
      South_1 = character(),
      South_2 = character(),
      South_3 = character(),
      South_4 = character(),
      Dune_1 = character(),
      Dune_2 = character(),
      Dune_3 = character(),
      Dune_4 = character(),
      North_1 = character(),
      North_2 = character(),
      North_3 = character(),
      North_4 = character(),
      stringsAsFactors = FALSE
    ))
    
    # Observe help icon click
    observeEvent(input$help_icon, {
      showModal(modalDialog(
        title = "Help",
        "New users may need to authenticate their Google account in order to submit data. This button will send you to a secure Google authentication page. Please login to your Google account and select 'See, edit, create, and delete all your Google Sheets spreadsheets' in order to proceed.",
        easyClose = TRUE,
        footer = NULL
      ))
    })
    
    # Your Google Sheet ID (from the URL)
    sheet_id <- "1P1xYJtAaR5MdxWqb05JS6_3RqGAWbg2cZxhat2piSDc"
    
    # Observe the submit button
    observeEvent(input$submit_data, {
      req(input$date, input$study_site, input$observer)  # Ensure inputs are filled
      
      # Capture the input values
      new_entry <- data.frame(
        Measurement_Date = input$date,
        Study_Site = input$study_site,
        Observer = input$observer,
        WP = input$wp,
        Site_Description = input$site_description,
        Ocean_1 = input$ocean_1,
        Ocean_2 = input$ocean_2,
        Ocean_3 = input$ocean_3,
        Ocean_4 = input$ocean_4,
        South_1 = input$south_1,
        South_2 = input$south_2,
        South_3 = input$south_3,
        South_4 = input$south_4,
        Dune_1 = input$dune_1,
        Dune_2 = input$dune_2,
        Dune_3 = input$dune_3,
        Dune_4 = input$dune_4,
        North_1 = input$north_1,
        North_2 = input$north_2,
        North_3 = input$north_3,
        North_4 = input$north_4,
        stringsAsFactors = FALSE
      )
      
      # Append the new entry to the existing data
      updated_data <- rbind(data(), new_entry)
      data(updated_data)
      
      # Write the new entry to Google Sheets, targeting 'Light_Surveys'
      sheet_append(sheet_id, new_entry, sheet = "Light_Surveys")
      
      # Clear the inputs after submission
      lapply(c("measurement_date", "study_site", "observer", "wp", 
               "site_description", "ocean_1", "ocean_2", "ocean_3", 
               "ocean_4", "south_1", "south_2", "south_3", "south_4", 
               "dune_1", "dune_2", "dune_3", "dune_4", 
               "north_1", "north_2", "north_3", "north_4"), function(x) {
                 updateTextInput(session, ns(x), value = "")
               })
      updateDateInput(session, ns("measurement_date"), value = Sys.Date())
      
      showModal(modalDialog(
        title = "Success",
        "Data Successfully Uploaded to Light Surveys.",
        easyClose = TRUE,
        footer = NULL
      ))
    })
  })
}
    
## To be copied in the UI
# mod_light_reporting_ui("light_reporting_1")
    
## To be copied in the server
# mod_light_reporting_server("light_reporting_1")
