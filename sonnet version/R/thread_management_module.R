# R/thread_management_module.R

# Thread Management Module

# UI function
threadManagementUI <- function(id) {
  ns <- NS(id)
  tagList(
    h4("Threads"),
    actionButton(ns("create_thread"), "New Thread"),
    br(), br(),
    DTOutput(ns("thread_table"))
  )
}

# Server function
threadManagementServer <- function(id, storage, app_state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive for thread list
    threads <- reactiveVal(fetch_threads(storage))
    
    # Render thread table
    output$thread_table <- renderDT({
      threads() %>%
        select(thread_id, thread_name, created_at) %>%
        datatable(
          selection = 'single',
          options = list(dom = 't', paging = FALSE),
          rownames = FALSE
        )
    })
    
    # Update active thread when a thread is selected
    observeEvent(input$thread_table_rows_selected, {
      selected_row <- input$thread_table_rows_selected
      if (length(selected_row)) {
        selected_thread <- threads()[selected_row, ]
        app_state$active_thread <- selected_thread$thread_id
      }
    })
    
    # Handle creating a new thread
    observeEvent(input$create_thread, {
      showModal(modalDialog(
        title = "Create New Thread",
        textInput(ns("new_thread_name"), "Thread Name"),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("confirm_create_thread"), "Create")
        )
      ))
    })
    
    # Confirm creating a new thread
    observeEvent(input$confirm_create_thread, {
      req(input$new_thread_name)
      create_thread(storage, input$new_thread_name)
      threads(fetch_threads(storage))
      removeModal()
    })
    
    # Return reactive for threads
    return(list(
      threads = threads
    ))
  })
}
