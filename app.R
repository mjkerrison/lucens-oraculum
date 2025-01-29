# app.R
library(shiny)
library(tidyverse)
library(lubridate)
library(targets)

targets::tar_source("R")


# Main App UI ==================================================================
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "lucens-oraculum-stylesheet.css")
  ),
  
  titlePanel("Chat Application"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      div(
        class = "chat-list",
        style = "height: 80vh; overflow-y: auto;",
        uiOutput("chatList")
      )
    ),
    
    mainPanel(
      width = 9,
      uiOutput("activeChatModule")
    )
  )
  
)


chat_database <- retrieve_chats()


# Main App Server ==============================================================
server <- function(input, output, session) {

  
  # TODO: think about how we take dependencies and on what
  #   For instance - do we actually need to keep all chat stuff in the workspace
  #   at the same time? Probably not - we could treat it much more like a 
  #   database (whether it technically ends up being one or not), and just worry
  #   about keeping state synced with it.
  
  # TODO: build functionality to start with no chat selected
  
  # Initialize reactive values
  active_chat <- reactiveVal(names(chat_database)[1])

  
  # Function to update messages (passed to modules)
  updateMessages <- function(new_messages) {
    all_messages(new_messages)
  }
  
  # Chat list UI
  output$chatList <- renderUI({
    
    map2(chat_database, names(chat_database), function(chat_tbl_i, chat_id_i) {
      
      # Get last message for this chat
      last_msg <- chat_tbl_i |> 
        arrange(desc(timestamp)) |> 
        slice(1) |> 
        pull(message)
      
      div(
        class = ifelse(chat_id_i == active_chat(), "chat-list-item active", "chat-list-item"),
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
  })
  
  # Handle chat selection
  observeEvent(input$selected_chat, {
    active_chat(input$selected_chat)
  })
  
  # Render active chat module
  output$activeChatModule <- renderUI({
    chatModuleUI(paste0("chat", active_chat()))
  })
  
  # Initialize chat modules
  observe({
    chatModule(paste0("chat", active_chat()), 
               active_chat())
  })
  
}

shinyApp(ui = ui, server = server)
