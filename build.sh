#!/bin/sh

IMAGE_NAME=fr_covid_reporting
docker build -t $IMAGE_NAME . && docker tag $IMAGE_NAME:latest $IMAGE_NAME:`cat VERSION` && docker image ls $IMAGE_NAME
