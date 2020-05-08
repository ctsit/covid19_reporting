# Change Log
All notable changes to the REDCap First Responder covid19 reporting project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).


## [0.1.0] - 2020-05-08
### Added
- appointment_report.Rmd - A person-centric report about the study participants who have received or are still waiting for a result.
- render_report.R - A script runner that runs and sends appointment_report.Rmd via email.
- identify_duplicated_subjects.R - An ETL script that will disable subsequent email addresses of people who created multiple records.
- survey_report.Rmd - A basic data summary and data export script.
