
#' Wrapper around \{ellmer\} chats to use them ~natively
#'
#' @param ellmer_chat_R6 
#' @param id 
#'
#' @return
#' @export
#'
#' @examples
enrich_ellmerChat <- function(ellmer_chat_R6, id){
  
  enrichedChat <- list(
    "id" = id,
    chatR6 = ellmer_chat_R6
  )
  
  class(enrichedChat) <- c(class(enrichedChat), "enrichedChat")
  
  return(enrichedChat)
  
}


#' Save an enrichedChat object to disk
#'
#' @param enriched_chat_R6 
#' @param library_dir 
#'
#' @return
#' @export
#'
#' @examples
serialise_enrichedChat <- function(enriched_chat_R6,
                                   library_dir = LIBRARY_DIR){
  
  readr::write_rds(
    enriched_chat_R6,
    glue::glue("{library_dir}/{enriched_chat_R6$id}")
  )
  
  return(invisible(enriched_chat_R6$id))
  
}


ennumerate_thread_library <- function(library_dir = LIBRARY_DIR){
  
  
  
}





chat_thread_manager <- function(active_chat_id,
                                # Shiny context
                                input,
                                output,
                                session){
  
  observe({})
  
  # Placeholder ================================================================
  
  
  # Self-destruction ===========================================================
  
  # Wait for API etc. to finish running
  
  # Serialise this chat
  
  # Destroy this thread observer
  
}
