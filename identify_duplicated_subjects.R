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
  arrange(id, record_id)

duplicated_subjects <- duplicated_subjects_by_zipcode %>% 
  ungroup() %>% 
  select(-id) %>% 
  bind_rows(duplicated_subjects_by_email) %>%  
  ungroup() %>%   
  distinct(record_id, redcap_event_name, ce_firstname, ce_lastname, .keep_all = T) 

write.csv(duplicated_subjects, 
          paste0("output/duplicate_subjects_", today(), ".csv"),
          row.names = F, na = "")

# compare to cindy's data -------------------------------------------------


cindys_repeats <- readxl::read_excel("data/FirstResponder_Repeats.xlsx")

only_in_cindys <- cindys_repeats %>% 
  anti_join(duplicated_subjects, by = c("Record ID" = "record_id"))

# compare those only in cindys to what's in records.
locate_only_in_cindys_ids <- records %>% 
  filter(record_id %in% only_in_cindys$`Record ID`) %>% 
  select(record_id, ce_firstname, ce_lastname, test_date_and_time, covid_19_swab_result)


# redcap import dataset ---------------------------------------------------

redcap_import <- duplicated_subjects_by_email %>% 
  filter(record_id == max(record_id)) %>% 
  bind_rows(duplicated_subjects_by_zipcode %>% 
              filter(record_id == max(record_id))) %>% 
  select(-id) %>% 
  ungroup() %>%
  distinct() %>%
  select(record_id, redcap_event_name, ce_email) %>% 
  mutate(ce_email_backup = ce_email) %>%
  mutate(ce_email = "")
  
write.csv(redcap_import, 
          paste0("output/blank_emails_for_duplicate_subjects_", today(), ".csv"),
          row.names = F, na = "")
