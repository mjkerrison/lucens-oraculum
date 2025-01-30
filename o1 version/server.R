# server.R

library(shiny)

# Define the Server Logic
server <- function(input, output, session) {
  # Call the Thread Sidebar Module
  thread_info <- callModule(thread_sidebar_server, "thread_sidebar")
  
  # Call the Endpoint Configuration Module
  endpoint_info <- callModule(endpoint_config_server, "endpoint_config")
  
  # Call the Chat History Module
  callModule(chat_history_server, "chat_history", thread_info)
  
  # Call the Message Composition Module
  callModule(message_compose_server, "message_compose", thread_info, endpoint_info)
}
