library(tidyverse)
library(janitor)

data_dictionary <- list.files("data", "FirstResponderCOVID19TestingPr")
data_dictionary <- read.csv(paste0("data/", data_dictionary)) %>% 
  clean_names()

# -------Checkbox Cols----------#
get_checkboxes <- function(df){
  checkboxes <- data_dictionary %>%
    filter(field_type == "checkbox" & form_name == 'coronavirus_covid19_questionnaire') %>%  
    select(variable_field_name, choices_calculations_or_slider_labels, field_label) %>%
    separate_rows(choices_calculations_or_slider_labels, sep = "\\|") %>%
    separate(choices_calculations_or_slider_labels, into = c("numeric_value", "label"),
             sep = ",", extra = "merge") %>%
    mutate_all(trimws) %>% 
    unite("checkbox_name", variable_field_name, numeric_value, sep = "___")
  
  
  checkbox_cols <- df %>%
    select(matches(paste0(
      "^(", paste(checkboxes$checkbox_name,
                  collapse = "|"), ")"
    ))) %>%
    colnames()
  
  df_with_checkbox_labels <- df %>%
    select(checkbox_cols) %>% 
    pivot_longer(checkbox_cols, names_to = "checkbox_name",
                 values_to = "checkbox_value") %>%    
    left_join(checkboxes) %>% 
    mutate_all(trimws) %>%  
    select(-checkbox_name) %>% 
    filter(checkbox_value == 1) %>%    
    count(field_label, label)
    
  return(df_with_checkbox_labels)
}

# ----- Radio cols ----#
get_radio_cols <- function(df){
  radio <- data_dictionary %>%
  filter(field_type == "radio" & form_name == 'coronavirus_covid19_questionnaire') %>%  
    select(variable_field_name, choices_calculations_or_slider_labels, field_label) %>%
    separate_rows(choices_calculations_or_slider_labels, sep = "\\|") %>%
    separate(choices_calculations_or_slider_labels, into = c("numeric_value", "label"),
             sep = ",", extra = "merge") %>%
    mutate_all(trimws) 
  
  radio_cols <- df %>%
    select(matches(paste0(
      "^(", paste(radio$variable_field_name, collapse = "|"),
      ")"
    ))) %>% 
    colnames()
  
  df_with_radio_labels <- df %>%
    select(radio_cols) %>%  
    mutate_all(as.character) %>% 
    pivot_longer(radio_cols, names_to = "variable_field_name",
                 values_to = "numeric_value") %>%      
    inner_join(radio) %>%   
    count(field_label, label)
  
  return(df_with_radio_labels)
}

# --- yes no ---#
get_yes_no_cols <- function(df){
yes_no_labels <- data_dictionary %>%
  filter(field_type == 'yesno' & form_name == 'coronavirus_covid19_questionnaire') %>% 
  distinct(variable_field_name, field_label) %>%    
  mutate(Yes = '1', No = '0') %>% 
  pivot_longer(-c(variable_field_name,field_label),
               names_to = "label", values_to = "field_value") %>% 
  mutate_all(as.character)

yes_no_cols <- df %>%
  select(matches(paste0(
    "^(", paste(yes_no_labels$variable_field_name, collapse = "|"),
    ")"
  ))) %>%  
  colnames()

df_with_yes_no_labels <- df %>%
  select(yes_no_cols) %>%  
  mutate_if(is.logical, ~ if_else(. == TRUE, 1,
                                  if_else(. == FALSE, 0, NA_real_))) %>% 
  select_if(is.numeric) %>% 
  pivot_longer(cols = everything(), names_to = "variable_field_name",
               values_to = "field_value") %>% 
  mutate_all(as.character) %>%   
  inner_join(yes_no_labels) %>%  
  count(field_label, label)

 return(df_with_yes_no_labels)

}
  