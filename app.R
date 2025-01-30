# app.R
library(shiny)
library(tidyverse)
library(lubridate)
library(targets)

targets::tar_source("R")


chat_database <- retrieve_chats()


# Main App UI ==================================================================
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "lucens-oraculum-stylesheet.css")
  ),
  
  titlePanel("Chat Application"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      uiOutput("chatList")
    ),
    
    mainPanel(
      width = 9,
      uiOutput("activeChatModule")
    )
  )
  
)

# Main App Server ==============================================================
server <- function(input, output, session) {

  
  # TODO: think about how we take dependencies and on what
  #   For instance - do we actually need to keep all chat stuff in the workspace
  #   at the same time? Probably not - we could treat it much more like a 
  #   database (whether it technically ends up being one or not), and just worry
  #   about keeping state synced with it.
  
  # TODO: build functionality to start with no chat selected
  
  # Initialize reactive values
  
  all_chat_ids <- reactiveVal(names(chat_database))

  active_chat <- reactiveVal(names(chat_database)[1])
  
  # Chat list UI
  output$chatList <- renderUI({
    chatListUI("chat_list")
  })
  
  # TODO: figure out how to have a module handle a 'global' variable...
  selected_chat <- chatList("chat_list", all_chat_ids, active_chat)
  
  observeEvent(selected_chat(), {
    active_chat(selected_chat())
  })
  
  # Chat module --------------------------------------------------
  
  # Render active chat module
  output$activeChatModule <- renderUI({
    chatModuleUI(paste0("chat", active_chat()))
  })
  
  # Initialize chat with messages etc.
  observe({
    chatModule(paste0("chat", active_chat()), 
               active_chat())
  })
  
}

shinyApp(ui = ui, server = server)
