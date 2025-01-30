# global.R

# Load required packages
library(shiny)
library(DBI)
library(DT)
library(httr)
library(jsonlite)
library(R6)
library(purrr)
library(dplyr)
library(stringr)
library(lubridate)

# Source all module files (to be stored in R/ directory)
# Chat management modules
source("R/thread_management_module.R")
source("R/message_display_module.R")
source("R/message_composer_module.R")
source("R/endpoint_config_module.R")

# Data persistence modules
source("R/storage_interface_module.R")

# API interaction modules
source("R/api_handler_module.R")

# Helper functions and utilities
source("R/utils.R")

# Initialize storage backend through storage interface module
storage <- initialize_storage()

# Define global variables if needed
