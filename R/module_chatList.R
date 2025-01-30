chatListUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      class = "chat-list",
      style = "height: 80vh; overflow-y: auto;",
      uiOutput(ns("ennumeratedChats"))
    )
  )
}

chatList <- function(id, all_chat_ids, active_chat_val) {
  moduleServer(id, function(input, output, session) {
    
    # TODO: simplify the reactive dependencies... see app.R
    
    now_selected <- reactiveVal(isolate(active_chat_val()))
    
    
    output$ennumeratedChats <- renderUI({
      
      all_chat_divs <- map2(chat_database, all_chat_ids(), function(chat_tbl_i, chat_id_i) {
        
        # Get last message for this chat
        last_msg <- chat_tbl_i |> 
          arrange(desc(timestamp)) |> 
          slice(1) |> 
          pull(message)
        
        div(
          class = ifelse(chat_id_i == active_chat_val(), "chat-list-item active", "chat-list-item"),
          id = paste0("chat_", chat_id_i),
          onclick = glue::glue("Shiny.setInputValue('selected_chat', '{chat_id_i}')"),
          
          # Content
          glue::glue("Chat {chat_id_i}"),
          div(
            style = "font-size: 0.8em; color: #6c757d;",
            stringr::str_trunc(last_msg, 30)
          )
        )
        
      })
      
      
      do.call(tagList, all_chat_divs)
    
    })
    
    # Handle chat selection
    observeEvent(input$selected_chat, {
      now_selected(input$selected_chat)
    })
    
    
    return(now_selected)
    
    
  })
}
