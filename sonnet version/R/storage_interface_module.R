# R/storage_interface_module.R

# Storage Interface Module

# Function to initialize storage (e.g., connect to a SQLite database)
initialize_storage <- function() {
  # Using SQLite for lightweight database storage
  con <- DBI::dbConnect(RSQLite::SQLite(), dbname = "chat_app.db")
  # Initialize tables if they don't exist
  create_tables(con)
  return(con)
}

# Function to create necessary tables
create_tables <- function(con) {
  # Create threads table
  DBI::dbExecute(con, "
    CREATE TABLE IF NOT EXISTS threads (
      thread_id INTEGER PRIMARY KEY,
      thread_name TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  # Create messages table
  DBI::dbExecute(con, "
    CREATE TABLE IF NOT EXISTS messages (
      message_id INTEGER PRIMARY KEY,
      thread_id INTEGER NOT NULL,
      sender TEXT NOT NULL,
      message_text TEXT NOT NULL,
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
      api_response TEXT,
      FOREIGN KEY(thread_id) REFERENCES threads(thread_id)
    )
  ")
  
  # Create endpoints table
  DBI::dbExecute(con, "
    CREATE TABLE IF NOT EXISTS endpoints (
      endpoint_id INTEGER PRIMARY KEY,
      endpoint_name TEXT NOT NULL,
      api_key TEXT,
      parameters TEXT
    )
  ")
}

# Function to fetch threads
fetch_threads <- function(con) {
  DBI::dbGetQuery(con, "SELECT * FROM threads ORDER BY created_at DESC")
}

# Function to create a new thread
create_thread <- function(con, thread_name) {
  DBI::dbExecute(
    con,
    "INSERT INTO threads (thread_name) VALUES (?)",
    params = list(thread_name)
  )
}

# Function to delete a thread and its associated messages
delete_thread <- function(con, thread_id) {
  DBI::dbExecute(
    con,
    "DELETE FROM messages WHERE thread_id = ?",
    params = list(thread_id)
  )
  DBI::dbExecute(
    con,
    "DELETE FROM threads WHERE thread_id = ?",
    params = list(thread_id)
  )
}

# Function to fetch messages for a thread
fetch_messages <- function(con, thread_id) {
  DBI::dbGetQuery(
    con,
    "SELECT * FROM messages WHERE thread_id = ? ORDER BY timestamp ASC",
    params = list(thread_id)
  )
}

# Function to save a message
save_message <- function(con, thread_id, sender, message_text, api_response = NULL) {
  DBI::dbExecute(
    con,
    "INSERT INTO messages (thread_id, sender, message_text, api_response) VALUES (?, ?, ?, ?)",
    params = list(thread_id, sender, message_text, api_response)
  )
}

# Function to fetch endpoints
fetch_endpoints <- function(con) {
  DBI::dbGetQuery(con, "SELECT * FROM endpoints")
}

# Function to save endpoint configuration
save_endpoint <- function(con, endpoint_name, api_key, parameters) {
  DBI::dbExecute(
    con,
    "INSERT INTO endpoints (endpoint_name, api_key, parameters) VALUES (?, ?, ?)",
    params = list(endpoint_name, api_key, parameters)
  )
}

# Function to update endpoint configuration
update_endpoint <- function(con, endpoint_id, endpoint_name, api_key, parameters) {
  DBI::dbExecute(
    con,
    "UPDATE endpoints SET endpoint_name = ?, api_key = ?, parameters = ? WHERE endpoint_id = ?",
    params = list(endpoint_name, api_key, parameters, endpoint_id)
  )
}
