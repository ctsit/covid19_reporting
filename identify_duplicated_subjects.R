library(tidyverse)
library(dotenv)
library(REDCapR)
library(lubridate)
source("functions.R")


# find duplicates ---------------------------------------------------------


records <- get_records()  
  
filtered_records <- records %>% 
  mutate(test_date_and_time = as_date(test_date_and_time),
         days_since_appt = today() - test_date_and_time) %>% 
  filter(!is.na(covid_19_swab_result) |
         (days_since_appt > 7 & 
          is.na(covid_19_swab_result) &
          test_date_and_time != '1969-12-31')) %>%
  filter(redcap_event_name == "baseline_arm_1") %>%
  # TODO: remove this for future runs
  mutate(ce_email = tolower(coalesce(ce_email, ce_email_backup))) %>% 
  filter(!is.na(ce_email)) %>%
  mutate_at(vars("ce_firstname", "ce_lastname", "ce_email"), tolower) %>% 
  select(record_id, redcap_event_name, ce_firstname, ce_lastname, patient_dob, 
         ce_email, q_agency, zipcode, covid_19_swab_result, q_agency, test_date_and_time, 
         site_short_name, ce_orgconsentdate)

# check that it's ok to use emails to identify dupes
same_email_diff_names <- filtered_records %>% 
  filter(!is.na(ce_email)) %>% 
  group_by(ce_email) %>% 
  filter(n_distinct(ce_firstname, ce_lastname) > 1) %>% 
  select(1:8) %>% 
  arrange(ce_email)

duplicated_subjects_by_email <- filtered_records %>% 
  filter(!is.na(ce_email)) %>% 
  group_by(ce_email) %>% 
  filter(n_distinct(record_id) > 1) %>% 
  arrange(ce_email, record_id)

duplicated_subjects_by_zipcode <- filtered_records %>% 
  mutate(id = paste(ce_firstname, ce_lastname, patient_dob, zipcode)) %>%    
  group_by(id) %>% 
  filter(n_distinct(record_id) > 1) %>%
  arrange(id, record_id) %>% 
  ungroup() %>% 
  select(-id) 

duplicated_subjects <- duplicated_subjects_by_zipcode %>% 
  bind_rows(duplicated_subjects_by_email) %>% 
  distinct() %>% 
  group_by(ce_firstname, ce_lastname, patient_dob) %>% 
  mutate(row_id = sequence(n())) %>% 
  select(row_id, everything()) %>% 
  mutate(ce_email_backup = if_else(row_id > 1, ce_email, NA_character_),
         ce_email = if_else(row_id == 1, ce_email, NA_character_)) %>%
  # sum the row_id to find subjects that have name/dob issues
  mutate(row_id_sum = sum(row_id))
  

subjects_with_bad_data <- duplicated_subjects %>% 
  filter(row_id_sum < 2)

write.csv(subjects_with_bad_data, 
          paste0("output/blank_emails_for_duplicate_subjects_", today(), ".csv"),
          row.names = F, na = "")

redcap_import <- duplicated_subjects %>% 
  filter(row_id_sum > 1) %>% 
  ungroup() %>% 
  select(record_id, redcap_event_name, ce_email, ce_email_backup)
  
  
write.csv(redcap_import, 
          paste0("output/blank_emails_for_duplicate_subjects_", today(), ".csv"),
          row.names = F, na = "")
