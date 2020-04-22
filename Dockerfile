FROM rocker/verse

WORKDIR /report

RUN apt update -y && apt install -y \
 libcurl4-openssl-dev

#install necessary libraries
RUN R -e "install.packages(c('sendmailR', 'dotenv', 'REDCapR', 'RCurl', 'checkmate', 'lubridate', 'kableExtra'))"

CMD R -e "source('render_report.R')"