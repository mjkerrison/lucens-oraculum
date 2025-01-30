# server.R

server <- function(input, output, session) {
  
  # Reactive values for app state
  app_state <- reactiveValues(
    active_thread = NULL,
    active_endpoint = NULL
  )
  
  # Thread management module
  threadManagementServer(
    id = "thread_manager",
    storage = storage,
    app_state = app_state
  )
  
  # Endpoint configuration module
  endpointConfigServer(
    id = "endpoint_config",
    storage = storage,
    app_state = app_state
  )
  
  # Message display module
  messageDisplayServer(
    id = "message_display",
    storage = storage,
    app_state = app_state
  )
  
  # Message composer module
  messageComposerServer(
    id = "message_composer",
    storage = storage,
    app_state = app_state
  )
  
  # API handler module
  apiHandlerServer(
    storage = storage,
    app_state = app_state
  )
}
