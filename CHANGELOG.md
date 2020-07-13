# Change Log
All notable changes to the REDCap First Responder covid19 reporting project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).


## [0.3.0] - 2020-07-13
### Changed
- Update set_send_survey_invites_field.R (Laurence James-Woodley)
- Remove previously set records and upload data via redcap_write (Laurence James-Woodley)
- Add survey_report.Rmd to render_report.R (Laurence James-Woodley)
- use send_upload_email function (Laurence James-Woodley)
- Rename appointment_report to results_summary_by_agency (Philip Chase)
- Adjust labeling in results summary by agency (Philip Chase)
- Revise project name in README (Philip Chase)
- Add build script, document in README, and adapt the cron script to the image name (Philip Chase)
- add q_ufhealth_department counts (Laurence James-Woodley)


## [0.2.0] - 2020-06-04
### Added
- Add set_send_survey_invites_field.R with improved de-duplication (Laurence James-Woodley)

### Changed
- remove swab results from survey_report (Laurence James-Woodley)
- Use send_survey_invites in survey_report (Philip Chase)
- use env variable for uri (Laurence James-Woodley)


## [0.1.0] - 2020-05-08
### Added
- appointment_report.Rmd - A person-centric report about the study participants who have received or are still waiting for a result.
- render_report.R - A script runner that runs and sends appointment_report.Rmd via email.
- identify_duplicated_subjects.R - An ETL script that will disable subsequent email addresses of people who created multiple records.
- survey_report.Rmd - A basic data summary and data export script.
