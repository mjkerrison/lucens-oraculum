# R/api_handler_module.R

# API Handler Module

# Server function
apiHandlerServer <- function(storage, app_state) {
  # Observe for new user messages and trigger API call
  observeEvent(app_state$new_user_message, {
    req(app_state$active_thread, app_state$active_endpoint)
    
    # Fetch the last user message
    messages <- fetch_messages(storage, app_state$active_thread)
    last_user_message <- messages %>%
      filter(sender == "User") %>%
      slice_tail(n = 1)
    
    # Prepare API request
    api_response <- call_api(
      endpoint = app_state$active_endpoint,
      message = last_user_message$message_text
    )
    
    # Save API response
    save_message(
      storage,
      thread_id = app_state$active_thread,
      sender = "API",
      message_text = api_response$content,
      api_response = api_response$raw_response
    )
    
    # Reset the trigger
    app_state$new_user_message <- FALSE
  }, ignoreInit = TRUE)
}

# Function to call the API
call_api <- function(endpoint, message) {
  # Extract endpoint details
  api_key <- endpoint$api_key
  parameters <- jsonlite::fromJSON(endpoint$parameters)
  
  # Build request
  url <- parameters$url
  headers <- c(
    "Authorization" = paste("Bearer", api_key),
    "Content-Type" = "application/json"
  )
  body <- list(
    prompt = message,
    other_parameters = parameters$other_params
  )
  
  # Make POST request
  response <- httr::POST(
    url = url,
    httr::add_headers(.headers = headers),
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json"
  )
  
  # Parse response
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  parsed_content <- jsonlite::fromJSON(content)
  
  # Return parsed content and raw response
  list(
    content = parsed_content$result,
    raw_response = content
  )
}
