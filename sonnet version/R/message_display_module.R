# R/message_display_module.R

# Message Display Module

# UI function
messageDisplayUI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("message_history"))
  )
}

# Server function
messageDisplayServer <- function(id, storage, app_state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive to fetch and update messages
    messages <- reactive({
      req(app_state$active_thread)
      fetch_messages(storage, app_state$active_thread)
    })
    
    # Render message history
    output$message_history <- renderUI({
      req(messages())
      msgs <- messages()
      if (nrow(msgs) == 0) {
        h5("No messages yet. Start the conversation!")
      } else {
        # Create a list of message bubbles
        msgs %>%
          pmap(function(sender, message_text, timestamp, ...) {
            div(
              class = if_else(sender == "User", "user-message", "api-message"),
              p(strong(sender), " [", format(ymd_hms(timestamp), "%Y-%m-%d %H:%M"), "]"),
              p(message_text)
            )
          }) %>%
          tagList()
      }
    })
  })
}
