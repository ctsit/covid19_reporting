# Covid-19 Reporting Tools

This repository provides reporting tools in support of the COVID-19 Testing projects at the University of Florida. The reporting tools are RMarkdown scripts run by a Docker container.

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

## Running the RMarkdown script
The primary script used to run the RMarkdown reports is [`render_report.R`](render_report.R)

To build the image and run the report using docker within the project directory do:

`docker build -t <image_name> .`

and run the report using docker within the project directory like this:

`docker run --rm --env-file my.env <image_name> R -e <script_name.R>`
