#!/bin/sh


APP_NAME="bootiful-applications"
DB_SVC_NAME="bootiful-applications-postgresql"
NEWRELIC_SVC_NAME="bootiful-applications-newrelic"


# tear app and service down if they already exist
cf delete -f $APP_NAME
cf delete-service -f $DB_SVC_NAME
cf delete-service -f $NEWRELIC_SVC_NAME

# push the app to the cloud
cf push -p target/demo-0.0.1-SNAPSHOT.jar --random-route $APP_NAME

# give it a backing service
cf services | grep $DB_SVC_NAME || cf create-service elephantsql turtle $DB_SVC_NAME

# bind it to the app
cf bind-service $APP_NAME $DB_SVC_NAME
cf restage $APP_NAME

# scale it
cf set-env  $APP_NAME ENDPOINTS_ENV_SENSITIVE false
cf scale -i 3 -f $APP_NAME # our free turtle tier PG DB only handles 5 at a time

# connect to DB
DB_URI=`cf env $APP_NAME | grep postgres: | cut -f2- -d:`;
echo $DB_URI

# lets add New Relic APM
cf create-service newrelic standard $NEWRELIC_SVC_NAME
cf bind-service $APP_NAME $NEWRELIC_SVC_NAME
cf restage $APP_NAME

# make sure we can get back here again
cf create-app-manifest $APP_NAME
