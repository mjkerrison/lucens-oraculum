# ui.R

library(shiny)
library(shinydashboard)

# Define the User Interface
ui <- dashboardPage(
  dashboardHeader(title = "LLM Chat Platform"),
  dashboardSidebar(
    # Thread Sidebar Module UI
    thread_sidebar_ui("thread_sidebar")
  ),
  dashboardBody(
    fluidPage(
      # Endpoint Configuration Module UI
      endpoint_config_ui("endpoint_config"),
      
      # Main panel split into chat history and message composition
      fluidRow(
        # Chat History Module UI
        column(
          width = 12,
          chat_history_ui("chat_history")
        )
      ),
      fluidRow(
        # Message Composition Module UI
        column(
          width = 12,
          message_compose_ui("message_compose")
        )
      )
    )
  )
)
