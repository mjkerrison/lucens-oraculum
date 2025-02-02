# Load required packages
library(shiny)
library(bslib)
library(tidyverse)

# Source all module files (to be created in R/ directory)
# source("R/modules/sidebar_module.R")
# source("R/modules/chat_display_module.R")
# source("R/modules/message_composer_module.R")
# source("R/modules/endpoint_config_module.R")

# UI helper functions
format_timestamp <- function(timestamp) {
  format(timestamp, "%H:%M")
}






card__chat_selection <- function(){
  card(
    height = "100%",
    card_header("Chats"),
    nav_menu(
      # Chat thread navigation controls
      nav_item(
        "New Chat",
        icon = icon("plus")
      ),
      nav_spacer(),
      # Dynamic list of chat threads would go here
    )
  )
}


card__endpoint_selection <- function(){
  card(
    card_header(
      "Endpoint Configuration",
      toggle = TRUE # Makes it collapsible
    ),
    # Endpoint selection and parameter inputs
  )
}


card__main_chat <- function(){
  card(
    height = "100%",
    class = "chat-messages",
    # Messages would be rendered here dynamically
    style = "overflow-y: auto;"
  )
}


card__message_bar <- function(){
  card(
    class = "message-input",
    card_body(
      layout_column_wrap(
        width = NULL,
        style = css(
          grid_template_columns = "1fr auto"
        ),
        textAreaInput(
          "message",
          label = NULL,
          width = "100%",
          resize = "vertical"
        ),
        actionButton(
          "send",
          "Send",
          icon = icon("paper-plane")
        )
      ),
      # File attachment button
      actionButton(
        "attach",
        "Attach",
        icon = icon("paperclip")
      )
    )
  )
}
