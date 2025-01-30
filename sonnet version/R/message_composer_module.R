# R/message_composer_module.R

# Message Composer Module

# UI function
messageComposerUI <- function(id) {
  ns <- NS(id)
  tagList(
    textAreaInput(ns("message_input"), label = NULL, placeholder = "Type your message...", width = "100%"),
    fileInput(ns("file_attachment"), "Attach a file", multiple = FALSE),
    actionButton(ns("send_message"), "Send", class = "btn-primary")
  )
}

# Server function
messageComposerServer <- function(id, storage, app_state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Handle sending a message
    observeEvent(input$send_message, {
      req(app_state$active_thread, input$message_input)
      
      # Save the user's message
      save_message(
        storage,
        thread_id = app_state$active_thread,
        sender = "User",
        message_text = input$message_input
      )
      
      # If there's an attachment, handle it (this example just saves the filename)
      if (!is.null(input$file_attachment)) {
        # TODO: Handle file saving and linking to the message
      }
      
      # Clear the input fields
      updateTextAreaInput(session, "message_input", value = "")
      reset("file_attachment")
      
      # Trigger API call through app state
      app_state$new_user_message <- TRUE
    })
  })
}
