# global.R

# Load required libraries
library(shiny)
library(shinydashboard)
library(tidyverse)
library(DBI)
library(RSQLite)

# Initialize the database connection
initialize_database <- function() {
  # Connect to a SQLite database (can be replaced with other backends)
  con <- dbConnect(RSQLite::SQLite(), "chat_app.db")
  
  # Create tables if they don't exist
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS threads (
      id   INTEGER PRIMARY KEY,
      name TEXT
    );
  ") |> invisible()
  
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS messages (
      id           INTEGER PRIMARY KEY,
      thread_id    INTEGER,
      sender       TEXT,
      message      TEXT,
      timestamp    DATETIME,
      api_response TEXT,
      FOREIGN KEY(thread_id) REFERENCES threads(id)
    );
  ") |> invisible()
  
  # Additional tables can be added here (e.g., endpoints, attachments)
  
  # Return the database connection
  con
}

# Initialize the database connection
db_con <- initialize_database()

# Helper Functions

# Function to retrieve all threads from the database
get_threads <- function(con) {
  dbGetQuery(con, "SELECT * FROM threads;")
}

# Function to create a new thread in the database
create_thread <- function(con, name) {
  dbExecute(con, "INSERT INTO threads (name) VALUES (?);", params = list(name)) |> invisible()
}

# Function to delete a thread and its associated messages from the database
delete_thread <- function(con, thread_id) {
  dbExecute(con, "DELETE FROM threads WHERE id = ?;", params = list(thread_id)) |> invisible()
  dbExecute(con, "DELETE FROM messages WHERE thread_id = ?;", params = list(thread_id)) |> invisible()
}

# Additional helper functions for messages, endpoints, attachments, etc., can be defined here

# Shiny Modules

# Thread Sidebar Module
# This module handles the left-hand sidebar where users can navigate between different threads,
# create and delete them, and so on.

## UI function for the thread sidebar module
thread_sidebar_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Sidebar menu with thread navigation
    sidebarMenu(
      id = ns("thread_menu"),
      actionButton(ns("new_thread"), "New Thread"),
      uiOutput(ns("thread_list"))  # Dynamic list of threads
    )
  )
}

## Server function for the thread sidebar module
thread_sidebar_server <- function(input, output, session) {
  ns <- session$ns
  
  # Reactive value to keep track of the selected thread
  selected_thread <- reactiveVal(NULL)
  
  # Reactive expression to load threads from the database
  threads <- reactive({
    get_threads(db_con)
  })
  
  # Generate the UI output for the list of threads
  output$thread_list <- renderUI({
    req(threads())
    
    # Create menu items for each thread
    lapply(seq_len(nrow(threads())), function(i) {
      thread <- threads()[i, ]
      menuItem(
        text     = thread$name,
        tabName  = paste0("thread_", thread$id),
        selected = thread$id == selected_thread(),
        icon     = icon("comments"),
        # Use actionLink to capture clicks
        actionLink(ns(paste0("select_thread_", thread$id)), label = thread$name)
      )
    }) |> tagList()
  })
  
  # Observe event for the "New Thread" button
  observeEvent(input$new_thread, {
    # In a real app, you'd prompt the user for a thread name
    new_name <- paste("Thread", Sys.time())
    create_thread(db_con, new_name)
  })
  
  # Dynamic observe events for each thread selection link
  observe({
    req(threads())
    lapply(seq_len(nrow(threads())), function(i) {
      thread <- threads()[i, ]
      observeEvent(input[[paste0("select_thread_", thread$id)]], {
        selected_thread(thread$id)
      })
    })
  })
  
  # Return the selected thread ID to other modules
  list(
    selected_thread = selected_thread
  )
}

# Endpoint Configuration Module
# This module allows the user to select and customize API endpoints.
# It provides a collapsible panel for configuring endpoints, API keys, system prompts, etc.

## UI function for the endpoint configuration module
endpoint_config_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Collapsible panel for endpoint configuration
    div(
      id = ns("endpoint_panel"),
      # Header with toggle button to expand/collapse the panel
      actionButton(ns("toggle_panel"), "Endpoint Configuration"),
      uiOutput(ns("collapsed_view")),
      
      # Details panel that shows when expanded
      conditionalPanel(
        condition = sprintf("input.%s %% 2 == 1", ns("toggle_panel")),
        ns        = ns,
        # Full configuration options
        selectInput(ns("endpoint_select"), "Select Endpoint", choices = c("OpenAI", "GPT-3", "Custom")),
        textInput(ns("api_key"), "API Key", value = ""),
        textAreaInput(ns("system_prompt"), "System Prompt", value = "", rows = 3)
        # Additional parameters can be added here
      )
    )
  )
}

## Server function for the endpoint configuration module
endpoint_config_server <- function(input, output, session) {
  ns <- session$ns
  
  # Reactive values to hold the endpoint configuration
  endpoint_config <- reactiveValues(
    endpoint      = NULL,
    api_key       = NULL,
    system_prompt = NULL
  )
  
  # Update the reactive values when inputs change
  observe({
    endpoint_config$endpoint      <- input$endpoint_select
    endpoint_config$api_key       <- input$api_key
    endpoint_config$system_prompt <- input$system_prompt
  })
  
  # UI output for the collapsed view (when panel is collapsed)
  output$collapsed_view <- renderUI({
    if (input$toggle_panel %% 2 == 0) {  # Panel is collapsed
      tagList(
        strong("Current Endpoint: "),
        span(endpoint_config$endpoint %||% "None Selected"),
        br(),
        # Quick selection dropdown
        selectInput(ns("quick_select"), "Quick Select", choices = c("OpenAI", "GPT-3", "Custom"), selected = endpoint_config$endpoint)
      )
    } else {
      NULL
    }
  })
  
  # Update the selected endpoint when quick select changes
  observeEvent(input$quick_select, {
    updateSelectInput(session, "endpoint_select", selected = input$quick_select)
  })
  
  # Return the endpoint configuration to other modules
  endpoint_config
}

# Chat History Module
# This module displays the message history for the selected chat thread.
# Messages include content, metadata such as timestamps, and API response details.

## UI function for the chat history module
chat_history_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Container for the chat messages
    div(
      id = ns("chat_history_container"),
      # Messages will be dynamically rendered here
      uiOutput(ns("message_list"))
    )
  )
}

## Server function for the chat history module
chat_history_server <- function(input, output, session, thread_info) {
  ns <- session$ns
  
  # Reactive expression to get the messages for the selected thread
  messages <- reactive({
    thread_id <- thread_info$selected_thread()
    req(thread_id)  # Ensure a thread is selected
    
    # Query the database for messages in the selected thread
    dbGetQuery(db_con, "SELECT * FROM messages WHERE thread_id = ? ORDER BY timestamp ASC;", params = list(thread_id))
  })
  
  # Render the list of messages
  output$message_list <- renderUI({
    msgs <- messages()
    req(nrow(msgs) > 0)
    
    # Generate UI for each message
    lapply(seq_len(nrow(msgs)), function(i) {
      msg <- msgs[i, ]
      tagList(
        div(
          class = ifelse(msg$sender == "User", "message user-message", "message bot-message"),
          h5(paste(msg$sender, "@", msg$timestamp)),
          p(msg$message),
          if (!is.null(msg$api_response)) {
            div(
              class = "api-response",
              h6("API Response:"),
              verbatimTextOutput(ns(paste0("api_response_", msg$id)))
            )
          } else {
            NULL
          }
        )
      )
    }) |> tagList()
  })
  
  # Render the API response text outputs
  observe({
    msgs <- messages()
    req(nrow(msgs) > 0)
    
    lapply(seq_len(nrow(msgs)), function(i) {
      msg <- msgs[i, ]
      if (!is.null(msg$api_response)) {
        local({
          msg_id <- msg$id
          output[[paste0("api_response_", msg_id)]] <- renderText({
            msg$api_response
          })
        })
      }
    })
  })
}

# Message Composition Module
# This module allows the user to compose new messages and attach files to the active chat thread.
# It handles sending the message to the selected endpoint and caching attachments.

## UI function for the message composition module
message_compose_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Message input area
    textAreaInput(ns("message_input"), label = NULL, placeholder = "Type your message here...", rows = 3),
    # File attachment input
    fileInput(ns("attachment_input"), label = "Attach Files", multiple = TRUE),
    # Send button
    actionButton(ns("send_button"), "Send", icon = icon("paper-plane"))
  )
}

## Server function for the message composition module
message_compose_server <- function(input, output, session, thread_info, endpoint_info) {
  ns <- session$ns
  
  # Observe send button click
  observeEvent(input$send_button, {
    # Get the message text
    message_text <- input$message_input
    req(message_text)
    
    # Get the selected thread ID
    thread_id <- thread_info$selected_thread()
    req(thread_id)
    
    # Handle file attachments (not fully implemented here)
    attachments <- input$attachment_input
    
    # Send the message to the selected endpoint
    # For now, we simulate an API response
    api_response <- paste("Simulated response to:", message_text)
    
    # Save the user's message to the database
    dbExecute(db_con, "INSERT INTO messages (thread_id, sender, message, timestamp) VALUES (?, ?, ?, datetime('now'));",
              params = list(thread_id, "User", message_text)) |> invisible()
    
    # Save the API response as a new message in the thread
    dbExecute(db_con, "INSERT INTO messages (thread_id, sender, message, timestamp, api_response) VALUES (?, ?, ?, datetime('now'), ?);",
              params = list(thread_id, "Bot", api_response, api_response)) |> invisible()
    
    # Clear the message input
    updateTextAreaInput(session, "message_input", value = "")
  })
}

# Additional modules and helper functions can be added here.
# The modules are designed to be modular and reusable, making the code accessible to collaborators.
