library(rmarkdown)
library(dotenv)
library(sendmailR)

# create the pdf report
file_name <- paste0('appointment_report_', Sys.Date(), '.pdf')
render("appointment_report.Rmd", 
       output_file = file_name )

# email credentials
email_server <- list(smtpServer = Sys.getenv("SMTP_SERVER"))
email_from <- Sys.getenv("EMAIL_FROM")
email_to <- unlist(strsplit(Sys.getenv("EMAIL_TO")," "))
email_cc <- unlist(strsplit(Sys.getenv("EMAIL_CC")," "))
email_subject <- (Sys.getenv("EMAIL_SUBJECT"))

# attach the zip file and email it
attachment_object <- mime_part(file_name, file_name)
body <- paste0("The attached file includes the Appointment Outcomes for",
               " the First Responder Covid-19 Project.", " File generated on ", Sys.time())

body_with_attachment <- list(body, attachment_object)

# send the email with the attached output file
sendmail(from = email_from, to = email_to, cc = email_cc,
         subject = email_subject, msg = body_with_attachment,
         control = email_server)

# uncomment to delete output once on tools4
unlink(file_name, recursive = T)
