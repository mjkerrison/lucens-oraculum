# R/endpoint_config_module.R

# Endpoint Configuration Module

# UI function
endpointConfigUI <- function(id) {
  ns <- NS(id)
  tagList(
    # Minimal display
    div(
      id = ns("minimal_view"),
      selectInput(ns("select_endpoint"), "Endpoint", choices = NULL),
      actionLink(ns("expand_config"), "Configure")
    ),
    # Expanded display
    #hidden(
      div(
        id = ns("expanded_view"),
        textInput(ns("endpoint_name"), "Endpoint Name"),
        textInput(ns("api_key"), "API Key"),
        textAreaInput(ns("parameters"), "Parameters (JSON format)"),
        actionButton(ns("save_endpoint"), "Save Endpoint", class = "btn-success"),
        actionButton(ns("collapse_config"), "Collapse", class = "btn-secondary")
      )
    #)
  )
}

# Server function
endpointConfigServer <- function(id, storage, app_state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive for endpoints
    endpoints <- reactiveVal(fetch_endpoints(storage))
    
    # Update endpoint choices
    observe({
      endpoint_list <- endpoints()$endpoint_name
      updateSelectInput(session, "select_endpoint", choices = endpoint_list)
    })
    
    # Handle expanding the config panel
    observeEvent(input$expand_config, {
      shinyjs::hide("minimal_view")
      shinyjs::show("expanded_view")
    })
    
    # Handle collapsing the config panel
    observeEvent(input$collapse_config, {
      shinyjs::hide("expanded_view")
      shinyjs::show("minimal_view")
    })
    
    # Handle saving endpoint configuration
    observeEvent(input$save_endpoint, {
      req(input$endpoint_name, input$api_key)
      parameters <- input$parameters
      save_endpoint(storage, input$endpoint_name, input$api_key, parameters)
      endpoints(fetch_endpoints(storage))
      shinyjs::hide("expanded_view")
      shinyjs::show("minimal_view")
    })
    
    # Update active endpoint
    observeEvent(input$select_endpoint, {
      selected_endpoint <- endpoints() %>%
        filter(endpoint_name == input$select_endpoint)
      app_state$active_endpoint <- selected_endpoint
    })
  })
}
