library(rmarkdown)
library(dotenv)
library(sendmailR)
library(lubridate)

source("functions.R")

script_run_time <- with_tz(now(), tzone = Sys.getenv("TIME_ZONE"))

# create the pdf report
results_summary_by_agency_file_name <- paste0('results_summary_by_agency_', 
                                              as_date(script_run_time), '.pdf')

survey_report_file_name <- paste0('survey_report_', as_date(script_run_time), '.pdf')

output_dir <- paste0("fr_covid_reports_", as_date(script_run_time))
dir.create(output_dir, recursive = T)

render("results_summary_by_agency.Rmd",
       output_file = results_summary_by_agency_file_name,
       output_dir = output_dir)

render("survey_report.Rmd", 
       output_file = survey_report_file_name,
       output_dir = output_dir,
       params = list(
         dataout = paste0(output_dir, "/")
       )
)

zipfile_name = paste0(output_dir, ".zip")
zip(zipfile_name, output_dir)

# attach the zip file and email it
attachment_object <- mime_part(zipfile_name, zipfile_name)
body <- paste0("The attached file includes the reports for",
               " the First Responder Covid-19 Project.", " File generated on ", script_run_time)

email_body <- list(body, attachment_object)

# send the email with the attached output file
send_upload_email(email_body, email_subject  = "")
