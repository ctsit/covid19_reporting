library(rmarkdown)
library(dotenv)
library(sendmailR)
library(lubridate)

script_run_time <- with_tz(now(), tzone = Sys.getenv("TIME_ZONE"))

# create the pdf report
file_name <- paste0('appointment_report_', as_date(script_run_time), '.pdf')

render("appointment_report.Rmd", output_file = file_name )

# attach the zip file and email it
attachment_object <- mime_part(file_name, file_name)
body <- paste0("The attached file includes the Appointment Outcomes for",
               " the First Responder Covid-19 Project.", " File generated on ", script_run_time)

email_body <- list(body, attachment_object)

# send the email with the attached output file
send_upload_email(email_body, email_subject  = "")
