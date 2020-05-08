FROM rocker/verse

WORKDIR /report

RUN apt update -y && apt install -y \
 libcurl4-openssl-dev

RUN tlmgr install \
    colortbl \
    environ \
    ifluatex \
    ifxetex \
    makecell \
    multirow \
    tabu \
    threeparttable \
    threeparttablex \
    trimspaces \
    ulem \
    varwidth \
    wrapfig \
    xcolor

#install necessary libraries
RUN R -e "install.packages(c('sendmailR', 'dotenv', 'REDCapR', 'RCurl', 'checkmate', 'lubridate', 'kableExtra'))"

ADD *.R /report/
ADD *.Rmd /report/

# Note where we are and what is there
CMD pwd && ls -AlhF ./
