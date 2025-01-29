


get_api_response <- function(chat_id, sleep_time = 0){
  
  Sys.sleep(sleep_time)
  
  tibble(
    timestamp = now(),
    sender = "api",
    message = sample(
      c("I understand.", 
        "Could you clarify?",
        "That's interesting!",
        "Let me think about that."),
      1
    ),
    chat_id = chat_id
  )
  
}

