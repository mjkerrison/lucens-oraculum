# ui.R

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  
  # Main layout with sidebar
  sidebarLayout(
    
    # Thread management sidebar
    sidebarPanel(
      width = 3,
      threadManagementUI("thread_manager")
    ),
    
    # Main panel containing chat and controls
    mainPanel(
      width = 9,
      
      # Endpoint configuration panel (collapsible)
      div(
        class = "endpoint-panel",
        endpointConfigUI("endpoint_config")
      ),
      
      # Chat message display area
      div(
        class = "chat-container",
        messageDisplayUI("message_display")
      ),
      
      # Message composition area
      div(
        class = "composer-container",
        messageComposerUI("message_composer")
      )
    )
  )
)
