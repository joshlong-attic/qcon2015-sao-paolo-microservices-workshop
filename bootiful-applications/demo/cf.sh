#!/bin/sh

APP_NAME=bootiful-applications
echo $APP_NAME

# push the app to the cloud
cf push -p target/demo-0.0.1-SNAPSHOT.jar $APP_NAME

# give it a backing service
SVC_NAME=bootiful-applications-postgresql
cf services | grep $SVC_NAME || cf create-service elephantsql turtle $SVC_NAME

# bind it to the app
cf bind-service $APP_NAME $SVC_NAME
