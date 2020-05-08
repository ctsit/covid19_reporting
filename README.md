# Covid-19 Reporting Tools

This repository provides reporting, data cleaning, and export tools in support of the COVID-19 Testing projects at the University of Florida. This repo provides a Dockerfile to run some of the RMarkdown scripts via a Docker container.


## Prerequisites

This project uses R and these R packages:

    tidyverse
    dotenv
    REDCapR
    lubridate
    sendmailR
    kableExtra
    rmarkdown

To build the Docker container, you will need only Docker. Additionally, this project uses the REDCap API to download the data from REDCap. The API must be enabled on the REDCap project and the host where this script runs will need to have access to it.

## Setup and Configuration

This script is configured entirely via the environment. An example `.env` file is provided as [`example.env`](example.env). To use this file, copy it to the name `.env` and customize according to your project needs. Follow these steps to build the required components and configure the script's `.env` file.


## The Scripts

- `appointment_report.Rmd` - A person-centric report about the study participants who have received or are still waiting for a result.
- `render_report.R` - A script runner that runs and sends `appointment_report.Rmd` via email.
- `identify_duplicated_subjects.R` - An ETL script that will disable subsequent email addresses of people who created multiple records.
- `survey_report.Rmd` - A basic data summary and data export script.


## Running the RMarkdown script
The primary script used to run the RMarkdown reports is [`render_report.R`](render_report.R). `render_report.R` mails out report results to a list of recipients defined in the .env file. At this tim, `render_report.R` runs these scripts:

    appointment_report.Rmd

To build the image and run the report using docker within the project directory do:

`docker build -t <image_name> .`

and run the report using docker within the project directory like this:

`docker run --rm --env-file my.env <image_name> Rscript <script_name.R>`
