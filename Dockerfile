FROM rocker/verse:4.0.1

WORKDIR /report

RUN apt update -y && apt install -y \
 libcurl4-openssl-dev

#install necessary libraries
RUN R -e "install.packages(c('sendmailR', 'dotenv', 'REDCapR', 'RCurl', 'checkmate', 'lubridate', 'kableExtra', 'skimr', 'tidyverse'))"

Run R -e "devtools::source_url('https://raw.githubusercontent.com/ctsit/r_utils/master/install_latex_packages.R')"

ADD *.R /report/
ADD *.Rmd /report/

# Note where we are and what is there
CMD pwd && ls -AlhF ./
