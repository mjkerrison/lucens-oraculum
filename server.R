server <- function(input, output, session) {
  
  # Initialise =================================================================
  
  
  
  # Handle library =============================================================
  # Reactive value to store chat threads
  chats_in_memory <- reactiveValues()
  
  chat_last_clicked <- ""
  
  
  
  active_chat <- reactiveVal()

  observe({
    
    
    
  })
    
  # TODO: new chat creation
  
  # TODO:
  # Handle sending messages
  observeEvent(input$send, {
    req(input$message)
    
    new_message <- list(
      content = input$message,
      timestamp = Sys.time(),
      sender = "user"
    )
    
    # Add to current chat
    current_chat$messages <- c(
      current_chat$messages,
      list(new_message)
    )
    
    # Handle API call and response
    # Add API response to messages
  })
  
  # Render chat messages
  output$chat_messages <- renderUI({
    req(current_chat$messages)
    
    tags$div(
      class = "chat-messages",
      lapply(current_chat$messages, function(msg) {
        card(
          class = paste("message", msg$sender),
          card_body(
            msg$content,
            tags$small(
              format(msg$timestamp, "%H:%M:%S")
            )
          )
        )
      })
    )
  })
  
  
}
