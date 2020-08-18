FROM rocker/verse:4.0.1

WORKDIR /report

RUN apt update -y && apt install -y \
 libcurl4-openssl-dev

#install necessary libraries
RUN R -e 'install.packages(c("sendmailR", "dotenv", "REDCapR", "RCurl", "checkmate", "lubridate", "kableExtra", "skimr", "tidyverse"))'

ADD latex_packages.csv /tmp/
RUN R -e 'tinytex::tlmgr_install(read.csv("/tmp/latex_packages.csv")$package)'

ADD *.R /report/
ADD *.Rmd /report/

# Note where we are and what is there
CMD pwd && ls -AlhF ./
