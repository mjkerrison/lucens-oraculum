
# Chat Module UI ===============================================================

chatModuleUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    
    div(
      class = "chat-messages",
      style = "height: 70vh; overflow-y: auto; padding: 15px;",
      uiOutput(ns("messageHistory"))
    ),
    
    div(
      class = "chat-input",
      style = "padding: 15px; border-top: 1px solid #eee;",
      fluidRow(
        column(10,
               textInput(ns("messageInput"), 
                         label = NULL, 
                         placeholder = "Type your message...")
        ),
        column(2,
               actionButton(ns("sendMessage"), 
                            "Send", 
                            class = "btn-primary",
                            style = "margin-top: 5px;")
        )
      )
    )
  )
}

# Chat Module Server ===========================================================

chatModule <- function(id, chat_id) {
  moduleServer(id, function(input, output, session) {
    
    # When a chat is opened (either new, or switching to another existing chat)
    # start by rendering that chat

    
    print(chat_id)
    chat_database |> pluck(chat_id) |> print()
    
    
    chatModule_initialise(chat_database |> pluck(chat_id),
                          input, output, session)
    
    # Handle sending messages
    observeEvent(input$sendMessage, {
      
      req(input$messageInput)
      
      chatModule_send_message(
        chat_id,
        input, output, session
      )
      
    })
    
  })
}


# Chat Module Server components ================================================

chatModule_render_message <- function(msg_tibble,
                                      # Shiny context
                                      input, output, session){
  
  div(
    
    class = glue::glue(
      "message-bubble {role_based_class}",
      role_based_class = switch(
        msg_tibble$sender,
        "user" = 'message-user', 
        "system" = 'message-system')
    ),
    
    div(msg_tibble$message),
    
    div(
      class = "message-timestamp",
      format(msg_tibble$timestamp, "%H:%M")
    )
    
  )
  
}

chatModule_initialise <- function(chat_messages,
                                  # Shiny context
                                  input, output, session) {
  
  tags <- map(1:nrow(chat_messages), function(i) {
    
    chatModule_render_message(
      chat_messages |> slice(i),
      input, output, session
    )
    
  })
  
  # renderUI to overwrite whatever was in there previously - initialising!
  output$messageHistory <- renderUI({
    do.call(tagList, tags)
  })
  
}


chatModule_send_message <- function(chat_id,
                                    # Shiny context
                                    input, output, session) {

  # Collate message data
  new_message <- tibble(
    timestamp = now(),
    sender = "user",
    message = input$messageInput,
    pending = FALSE
  )
  
  print(new_message)
  
  # Clear the input:
  updateTextInput(session, "messageInput", value = "")
  
  # Save that:
  chatModule_save_message(chat_id,
                          new_message,
                          input, output, session)
  
  # Render it:
  # TODO: rewrite to avoid re-rendering 100% of the chat every time
  #   (And to avoid any costly calls to the eventual 'database' to re-retrieve
  #   everything...)
  chatModule_initialise(chat_database |> pluck(chat_id),
                        input, output, session)
  
  # Dispatch to new worker(?) to await API response:
  # TODO
  
  
}


chatModule_save_message <- function(chat_id,
                                    new_message,
                                    # Shiny context
                                    input, output, session){
  
  # TODO: database connection or something? Global for now.
  chat_database[[chat_id]] <<- chat_database[[chat_id]] |> 
    
    add_row(new_message)
  
  return(invisible(TRUE))
  
}
