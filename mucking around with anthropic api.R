

#' Use API to list Anthropic models
#'
#' @return
#' @export
#'
#' @examples
list_models_anthropic <- function(){
  
  httr2::request("https://api.anthropic.com/v1/models") |> 
    
    httr2::req_headers(
      `x-api-key` = Sys.getenv("ANTHROPIC_API_KEY"),
      `anthropic-version` = "2023-06-01"
    ) |> 
    
    httr2::req_perform() |> 
    
    httr2::resp_body_json()
  
}


list_models_anthropic <- memoise::memoise(list_models_anthropic)


list_models_anthropic()


# =========================================================


test_claude_chat <- ellmer::chat_claude(
  system_prompt = NULL,
  turns = NULL,
  # max_tokens,
  model = "claude-3-5-sonnet-20241022"
  # api_args
  # base_url
  # api_key
  # echo
)



test_claude_chat |> readr::write_rds(file = "test_claude_chat")


reimported <- readr::read_rds(file = "test_claude_chat")


reimported$chat("Nothing specific - I'm testing some tools with your API. Feel free to generate whatever tokens you'd like.")


# ellmer::live_browser(reimported)


# TODO: 
