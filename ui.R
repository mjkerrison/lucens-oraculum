
ui <- page_fillable(
  
  # Layout with CSS Grid for precise control
  layout_column_wrap(
    width = NULL, # Full width
    heights_equal = "row",
    style = css(
      grid_template_columns = "300px 1fr",
      gap = "1rem"
    ),
    
    # Left sidebar for chat selection
    card__chat_selection(),
    
    # Right side main content
    layout_column_wrap(
      width = NULL,
      heights_equal = "row",
      
      # Top endpoint configuration card (collapsible)
      card__endpoint_selection(),
      
      # Main chat display area
      card__main_chat(),
      
      # Bottom message composition area
      card__message_bar()
    )
  )
)


