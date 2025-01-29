

#' Title
#'
#' @description This will be our interface to the 
#'
#' @return
#' @export
#'
#' @examples
retrieve_chats <- function(){
  
  # Temporary/dummy static data:
  
  list(
    
    "b7424015" = tibble(
      timestamp = now(),
      sender = "system",
      message = "Welcome to Chat 1!",
      pending = F
    ),
    
    "81838109" = tibble(
      timestamp = now(),
      sender = "system",
      message = "Welcome to Chat 2!",
      pending = F
    ),
    
    "e253ebcc" = tibble(
      timestamp = now(),
      sender = "system",
      message = "Welcome to Chat 3!",
      pending = F
    )
    
  )
  
  # Long-term --------------------
  
  # What I'd like to do is make sure there's good support for chat branching
  # natively: so maybe all chats will basically be linked lists across atomic
  # chat elements (messages). Might be flat files (nice and searchable in other
  # contexts) or a database - TBC.
  
}
