library(tidyverse)
library(dotenv)
library(REDCapR)
library(lubridate)
source("functions.R")


records <- get_records()  

filtered_records <- records %>% 
  mutate(test_date_and_time = as_date(test_date_and_time),
         days_since_appt = today() - test_date_and_time) %>%
  filter(redcap_event_name == "baseline_arm_1") %>%
  filter(!is.na(covid_19_swab_result)) %>%
  filter(!is.na(ce_email)) %>%
  mutate_at(vars("ce_firstname", "ce_lastname", "ce_email"), tolower) %>% 
  select(record_id, redcap_event_name, ce_firstname, ce_lastname, patient_dob, 
         ce_email, zipcode, q_agency)

# get all unique emails within filtered_records
unique_email <- filtered_records %>% 
  add_count(ce_email, name = "email_count") %>% 
  filter(email_count == 1)

one_subject_one_email <- unique_email %>% 
  group_by(ce_firstname, ce_lastname) %>% 
  filter(n() == 1) %>% 
  mutate(send_survey = 1)

# of all unique emails did the same person use multiple emails
one_subject_multiple_email <- unique_email %>% 
  group_by(ce_firstname, ce_lastname, patient_dob) %>% 
  filter(n() > 1) %>% 
  arrange(record_id) %>% 
  mutate(row_id = sequence(n())) %>% 
  mutate(send_survey = if_else(row_id == 1, 1, NA_real_))

send_survey_field_set_by_unique_email <- one_subject_one_email %>% 
  bind_rows(one_subject_multiple_email) 

# when the emails are not unique within filtered_records...
non_unique_emails <- filtered_records %>% 
  anti_join(send_survey_field_set_by_unique_email, by = "record_id")

one_dob_one_email <- non_unique_emails %>%
  group_by(patient_dob, ce_email) %>%
  filter(n() == 1) %>% 
  mutate(row_id = sequence(n())) %>%
  mutate(send_survey = if_else(row_id == 1, 1, NA_real_))

one_dob_multiple_email <- non_unique_emails %>% 
  group_by(patient_dob, ce_email) %>% 
  filter(n() > 1) %>%  
  arrange(record_id) %>% 
  mutate(row_id = sequence(n())) %>% 
  mutate(send_survey = if_else(row_id == 1, 1, NA_real_)) %>% 
  arrange(ce_firstname, ce_lastname)

# find subjects that were counted in one_dob_one_email and one_dob_multiple_email
subjects_counted_twice <- one_dob_one_email %>% 
  bind_rows(one_dob_multiple_email) %>% 
  group_by(ce_firstname, ce_lastname, zipcode) %>% 
  mutate(send_survey_sum = sum(send_survey, na.rm = T)) %>% 
  filter(send_survey_sum > 1) %>% 
  arrange(record_id) %>% 
  mutate(row_id = sequence(n())) %>% 
  mutate(send_survey = if_else(row_id == 1, 1, NA_real_)) %>% 
  select(-send_survey_sum)

send_survey_field_set_by_non_unique_email <- subjects_counted_twice %>% 
  bind_rows(one_dob_one_email %>% 
              filter(!record_id %in% subjects_counted_twice$record_id)) %>% 
  bind_rows(one_dob_multiple_email %>% 
              filter(!record_id %in% subjects_counted_twice$record_id))
  
set_send_survey_invites <- send_survey_field_set_by_unique_email %>% 
  bind_rows(send_survey_field_set_by_non_unique_email) %>% 
  arrange(ce_firstname, ce_lastname) %>% 
  mutate(send_survey_invites = if_else(is.na(send_survey), 0, send_survey)) %>% 
  ungroup()

# verify that send_survey_invites for multiple subjects with same name was correctly set
verify_same_names <- set_send_survey_invites %>% 
  add_count(ce_firstname, ce_lastname) %>% 
  filter(n > 1)  

write_csv(verify_same_names, "output/verify_same_names.csv", na = "")

# must be true
if (nrow(set_send_survey_invites) == nrow(filtered_records)) {
  write_csv(set_send_survey_invites %>% 
              select(record_id, redcap_event_name, send_survey_invites),
            paste("output/survey_field_set_", today(), ".csv"), na = "")
  
}
