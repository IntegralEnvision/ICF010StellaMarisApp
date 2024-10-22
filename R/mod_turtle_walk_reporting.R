#' turtle_walk_reporting UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_turtle_walk_reporting_ui <- function(id) {
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
          width = 12,
          div(style = "border: 1px solid gray; padding: 10px; border-radius: 10px;",
              fluidRow(
                column(width = 4, dateInput(ns("date"), label = "DATE")),
                column(width = 4, textInput(ns("leader"), label = "LEADER")),
                column(width = 4, textInput(ns("group_num"), label = "# IN GROUP")),
                column(width = 4, selectInput(ns("turtle_observ"), label = "WAS A TURTLE OBSERVED?", choices = c("YES", "NO", "N/A"))),
                column(width = 4, selectInput(ns("did_it_nest"), label = "DID SHE NEST?", choices = c("YES", "NO", "N/A"))),
                column(width = 4, textInput(ns("other_turtles"), label = "# OF OTHER TURTLES OBSERVED")),
                column(width = 12, textInput(ns("comments"), label = "COMMENTS"))
              )
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          actionButton(ns("submit_data"), label = "SUBMIT TURTLE WALK DATA",
                       class = "btn-submit")  # Apply custom class
        )
      )
    )
  )
}
    
#' turtle_walk_reporting Server Functions
#'
#' @noRd 
mod_turtle_walk_reporting_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # Reactive value to store the submitted data
    data <- reactiveVal(data.frame(
      Measurement_Date = as.Date(character()),
      Leader = character(),
      Group_Num = integer(),
      Turtle_Observed = character(),
      Did_It_Nest = character(),
      Other_Turtles = integer(),
      Comments = character(),
      stringsAsFactors = FALSE
    ))
    
    # Your Google Sheet ID (from the URL)
    sheet_id <- "1P1xYJtAaR5MdxWqb05JS6_3RqGAWbg2cZxhat2piSDc"
    
    # Observe the submit button
    observeEvent(input$submit_data, {
      req(input$date, input$leader, input$group_num)  # Ensure inputs are filled
      
      # Capture the input values
      new_entry <- data.frame(
        Measurement_Date = input$date,
        Leader = input$leader,
        Group_Num = as.integer(input$group_num),
        Turtle_Observed = input$turtle_observ,
        Did_It_Nest = input$did_it_nest,
        Other_Turtles = as.integer(input$other_turtles),
        Comments = input$comments,
        stringsAsFactors = FALSE
      )
      
      # Append the new entry to the existing data
      updated_data <- rbind(data(), new_entry)
      data(updated_data)
      
      # Write the new entry to Google Sheets, targeting 'Turtle_Walks'
      sheet_append(sheet_id, new_entry, sheet = "Turtle_Walks")
      
      # Clear the inputs after submission
      lapply(c("measurement_date", "leader", "group_num", "turtle_observ", 
               "did_it_nest", "other_turtles", "comments"), function(x) {
                 updateTextInput(session, ns(x), value = "")
               })
      updateDateInput(session, ns("measurement_date"), value = Sys.Date())
      
      showModal(modalDialog(
        title = "Success",
        "Data Successfully Uploaded to Turtle Walks.",
        easyClose = TRUE,
        footer = NULL
      ))
    })
  })
}
    
## To be copied in the UI
# mod_turtle_walk_reporting_ui("turtle_walk_reporting_1")
    
## To be copied in the server
# mod_turtle_walk_reporting_server("turtle_walk_reporting_1")
