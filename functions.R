get_records <- function(...){
  records <- redcap_read_oneshot(redcap_uri = Sys.getenv("URI"),
                                 token = Sys.getenv("TOKEN"),
                                 guess_max = 3000, ...)$data 
  
  fields_from_baseline <- c("ce_firstname", "ce_lastname", "patient_dob", 
                            "ce_orgconsentdate","ce_email","zipcode", "first_responder_role",
                            "q_agency", "q_ufhealth_department",
                            "q_ufhealth_covid_unit_role","q_ufhealth_covid_unit")
  
  baseline_records <- records %>%
    # redcap event is BASELINE or baseline_arm_1 depending on if 'raw' or 'label'
    # values are exported
    filter(str_detect(tolower(redcap_event_name), "bas")) %>% 
    select(record_id, fields_from_baseline)
  
  records <- records %>%
    select(-fields_from_baseline) %>%    
    left_join(baseline_records, by = c("record_id")) %>%
    select(record_id, redcap_event_name, fields_from_baseline, everything())
  
  return(records)
}


# -------Checkbox Cols----------#
get_checkboxes <- function(df){
  checkboxes <- data_dictionary %>%
    filter(field_type == "checkbox" & form_name == 'coronavirus_covid19_questionnaire') %>%  
    select(field_name, select_choices_or_calculations, field_label) %>%
    separate_rows(select_choices_or_calculations, sep = "\\|") %>%
    separate(select_choices_or_calculations, into = c("numeric_value", "label"),
             sep = ",", extra = "merge") %>%
    mutate_all(trimws) %>% 
    unite("checkbox_name", field_name, numeric_value, sep = "___")
  
  
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
    inner_join(checkboxes) %>% 
    mutate_all(trimws) %>%  
    select(-checkbox_name) %>% 
    count(field_label, label, checkbox_value)
    
  return(df_with_checkbox_labels)
}

# ----- Radio cols ----#
get_radio_cols <- function(df){
  radio <- data_dictionary %>%
  filter(field_type == "radio" & (form_name == 'coronavirus_covid19_questionnaire' |
                                    field_name %in% c('covid_19_swab_result', 'site_short_name', 'test_type'))) %>%
    select(field_name, select_choices_or_calculations, field_label) %>%
    separate_rows(select_choices_or_calculations, sep = "\\|") %>%
    separate(select_choices_or_calculations, into = c("numeric_value", "label"),
             sep = ",", extra = "merge") %>%
    mutate_all(trimws) 
  
  radio_cols <- df %>%
    select(matches(paste0(
      "^(", paste(radio$field_name, collapse = "|"),
      ")"
    ))) %>% 
    colnames()
  
  df_with_radio_labels <- df %>%
    select(radio_cols) %>% 
    mutate_all(as.character) %>% 
    pivot_longer(radio_cols, names_to = "field_name",
                 values_to = "numeric_value") %>%  
    inner_join(radio) %>%   
    count(field_label, label)
  
  return(df_with_radio_labels)
}

# --- yes no ---#
get_yes_no_cols <- function(df){
yes_no_labels <- data_dictionary %>%
  filter(field_type == 'yesno' & form_name == 'coronavirus_covid19_questionnaire') %>% 
  distinct(field_name, field_label) %>%    
  mutate(Yes = '1', No = '0') %>% 
  pivot_longer(-c(field_name,field_label),
               names_to = "label", values_to = "field_value") %>% 
  mutate_all(as.character)

yes_no_cols <- df %>%
  select(matches(paste0(
    "^(", paste(yes_no_labels$field_name, collapse = "|"),
    ")"
  ))) %>%  
  colnames()

df_with_yes_no_labels <- df %>%
  select(yes_no_cols) %>%  
  mutate_if(is.logical, ~ if_else(. == TRUE, 1,
                                  if_else(. == FALSE, 0, NA_real_))) %>% 
  select_if(is.numeric) %>% 
  pivot_longer(cols = everything(), names_to = "field_name",
               values_to = "field_value") %>%  
  mutate_all(as.character) %>%   
  inner_join(yes_no_labels) %>%  
  count(field_label, label)

 return(df_with_yes_no_labels)

}
  