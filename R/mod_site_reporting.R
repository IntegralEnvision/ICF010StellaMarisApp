#' site_reporting UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList
#' @import shiny
#' @import bslib
#' @import googlesheets4
#' @import googledrive
mod_site_reporting_ui <- function(id) {
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
      .btn-clear {
        background-color: #ff6666; 
        border-color: gray; 
        color: black; 
        display: block; 
        margin: auto; 
        margin-top: 15px;
      }
      .btn-clear:hover {
        background-color: #cc0000; 
      }
    ")),
    
    bslib::page_fluid(
      # fluidRow(
      #   column(
      #     width = 12,
      #     div(
      #       style = "display: inline-block; vertical-align: middle;",
      #       actionButton(ns("auth_button"), label = "AUTHENTICATE GOOGLE ACCOUNT", 
      #                    class = "btn-auth")  # Apply custom class
      #     ),
      #     div(
      #       style = "display: inline-block; margin-left: 1px; cursor: pointer;",
      #       actionButton(ns("help_icon"), label = "", 
      #                    icon("question-circle", class = "text-info", style = "font-size: 22px;"),
      #                    style = "background-color: transparent; border: black;")  # Clickable button style
      #     )
      #   )
      # ),
      fluidRow(
        column(
          width = 9,  # Combine the first three columns
          div(style = "border: 1px solid gray; padding: 10px; border-radius: 10px;",  # Border for first three columns
              fluidRow(
                column(
                  width = 4,
                  textInput(ns("nest_dig"), label = "NEST DIG #"),
                  textInput(ns("observers"), label = "OBSERVERS"),
                  dateInput(ns("emergence_date"), label = "EMERGENCE DATE"),
                  dateInput(ns("inventory_date"), label = "INVENTORY DATE"),
                  textInput(ns("number_guest"), label = "NUMBER OF GUESTS")
                ),
                column(
                  width = 4,
                  selectInput(ns("species"), label = "SPECIES", choices = c("", "Cc", "Cm", "Dc", "Ei", "Lk", "Other")),
                  textInput(ns("hatched_greater_50"), label = "HATCHED >50%"),
                  textInput(ns("hatched_less_50"), label = "HATCHED <50%"),
                  textInput(ns("unhactched_whole"), label = "UNHATCHED WHOLE"),
                  textInput(ns("unhatched_damaged"), label = "UNHATCHED DAMAGED")
                ),
                column(
                  width = 4,
                  textInput(ns("pipped_eggs_live"), label = "PIPPED EGGS LIVE"),
                  textInput(ns("pipped_eggs_dead"), label = "PIPPED EGGS DEAD"),
                  textInput(ns("total_eggs"), label = "TOTAL # OF EGGS"),
                  textInput(ns("sucess_rate"), label = "SUCCESS RATE %")
                )
              )
          )
        ),
        column(
          width = 3,  # Fourth column
          div(style = "border: 1px solid gray; padding: 10px; border-radius: 10px;",  # Border for fourth column
              textInput(ns("hatchlings_dead"), label = "HATCHLINGS- DEAD IN NEST"),
              textInput(ns("hatchlings_live"), label = "HATCHLINGS- LIVE IN NEST"),
              selectInput(ns("released_at_event"), label = "RELEASED AT EVENT", 
                          choices = c("", "Yes", "No", "N/A")),
              selectInput(ns("released_later"), label = "RELEASED LATER IN THE DAY", 
                          choices = c("", "Yes", "No", "N/A")),
              selectInput(ns("didnt_survive"), label = "DID NOT SURVIVE TO NIGHTTIME", 
                          choices = c("", "Yes", "No", "N/A"))
          )
        )
      ),
      fluidRow(
        column(
          width = 2,
          align = "left",  # Align the button to the left
          actionButton(ns("clear_data"), label = "CLEAR INPUTS", class = "btn-clear")  # Clear Data button
        ),
        column(
          width = 8,
          align = "center",  # Center the button
          actionButton(ns("submit_data"), label = "SUBMIT NEST DIG DATA", class = "btn-submit")  # Submit Data button
        )
      )
    )
  )
}

    
#' site_reporting Server Functions
#'
#' @noRd 
mod_site_reporting_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive value to store the submitted data
    data <- reactiveVal(data.frame(
      Nest_Dig = character(),
      Observers = character(),
      Emergence_Date = as.Date(character()),
      Inventory_Date = as.Date(character()),
      Number_of_Guests = integer(),
      Hatched_Greater_50 = character(),
      Hatched_Less_50 = character(),
      Unhatched_Whole = character(),
      Unhatched_Damaged = character(),
      Pipped_Eggs_Live = character(),
      Pipped_Eggs_Dead = character(),
      Total_Eggs = character(),
      Success_Rate = character(),
      Hatchlings_Dead = character(),
      Hatchlings_Live = character(),
      Released_At_Event = character(),
      Released_Later = character(),
      Did_Not_Survive = character(),
      stringsAsFactors = FALSE
    ))
    
    # Your Google Sheet ID (from the URL)
    sheet_id <- "1P1xYJtAaR5MdxWqb05JS6_3RqGAWbg2cZxhat2piSDc"
    
    # This code links to a button for the user to authenticate their google account. It is not used right now
    # observeEvent(input$auth_button, {
    #   # Force a new authentication process by removing cached credentials
    #   gs4_auth(cache = FALSE, scopes <- c("https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive"))
    #   if (is.null(gs4_find("sheet 1"))) {
    #     showModal(modalDialog(
    #       title = "Authentication Failed",
    #       "Could not find the specified Google Sheet. Please check your access.",
    #       easyClose = TRUE,
    #       footer = NULL
    #     ))
    #   }
    # })
    
    ######### May need to authenticate any new google account #################
    #gs4_auth(scopes = c("https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive"))
    
    # Observe the submit button
    observeEvent(input$submit_data, {
      req(input$nest_dig, input$observers, input$emergence_date, input$inventory_date)  # Ensure inputs are filled
      
      # Capture the input values
      new_entry <- data.frame(
        Nest_Dig = input$nest_dig,
        Observers = input$observers,
        Emergence_Date = input$emergence_date,
        Inventory_Date = input$inventory_date,
        Number_of_Guests = as.integer(input$number_guest),
        Species = as.character(input$species),
        Hatched_Greater_50 = input$hatched_greater_50,
        Hatched_Less_50 = input$hatched_less_50,
        Unhatched_Whole = input$unhactched_whole,
        Unhatched_Damaged = input$unhatched_damaged,
        Pipped_Eggs_Live = input$pipped_eggs_live,
        Pipped_Eggs_Dead = input$pipped_eggs_dead,
        Total_Eggs = input$total_eggs,
        Success_Rate = input$sucess_rate,
        Hatchlings_Dead = input$hatchlings_dead,
        Hatchlings_Live = input$hatchlings_live,
        Released_At_Event = input$released_at_event,
        Released_Later = input$released_later,
        Did_Not_Survive = input$didnt_survive,
        stringsAsFactors = FALSE
      )
      
      # Append the new entry to the existing data
      updated_data <- rbind(data(), new_entry)
      data(updated_data)
      
      # Write the new entry to Google Sheets
      sheet_append(sheet_id, new_entry, sheet = 'Nest_Digs')
      
      showModal(modalDialog(
        title = "Success",
        "Data Successfully Uploaded to Nest_Digs.",
        easyClose = TRUE,
        footer = NULL
      ))
    })
    observeEvent(input$clear_data, {
      # Clear text inputs
      updateTextInput(session, "nest_dig", value = "")
      updateTextInput(session, "observers", value = "")
      updateTextInput(session, "number_guest", value = "")
      updateTextInput(session, "hatched_greater_50", value = "")
      updateTextInput(session, "hatched_less_50", value = "")
      updateTextInput(session, "unhactched_whole", value = "")
      updateTextInput(session, "unhatched_damaged", value = "")
      updateTextInput(session, "pipped_eggs_live", value = "")
      updateTextInput(session, "pipped_eggs_dead", value = "")
      updateTextInput(session, "total_eggs", value = "")
      updateTextInput(session, "sucess_rate", value = "")
      updateTextInput(session, "hatchlings_dead", value = "")
      updateTextInput(session, "hatchlings_live", value = "")
      updateDateInput(session, "emergence_date", value = Sys.Date())
      updateDateInput(session, "inventory_date", value = Sys.Date())
      updateSelectInput(session, "species", selected = "")
      updateSelectInput(session, "released_at_event", selected = "")
      updateSelectInput(session, "released_later", selected = "")
      updateSelectInput(session, "didnt_survive", selected = "")
    })
  })
}
    
## To be copied in the UI
# mod_site_reporting_ui("site_reporting_1")
    
## To be copied in the server
# mod_site_reporting_server("site_reporting_1")
