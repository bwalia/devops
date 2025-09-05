#!/bin/bash

set -x

if [ -z "$1" ]; then
  echo "The env is empty, so setting ENV_REF to test (default)"
  ENV_REF="test"
else
   echo "The env is NOT empty, so setting ENV_REF to $1"
   ENV_REF=$1
fi

if [ -z "$ENV_REF" ]; then
  ENV_REF="test"
fi

if [ -z "$2" ]; then
  echo "The password is empty, so setting PASSWORD to empty (default)"
  PASSWORD=""
else
   echo "The password is NOT empty, so setting PASSWORD to $2"
   PASSWORD=$2
fi

if [ -z "$PASSWORD" ]; then
  echo "The password is empty, please set the PASSWORD environment variable."
  exit 1
fi

mc alias set minio-$ENV_REF https://$ENV_REF-s3-cli.workstation.co.uk minioadmin $PASSWORD
mc mb --ignore-existing minio-$ENV_REF/minio-$ENV_REF-images

TEST_FILE="README.md"

if [ -f $TEST_FILE ]; then
    echo "Test copying file $TEST_FILE to S3 bucket"
    mc cp $TEST_FILE minio-$ENV_REF/minio-$ENV_REF-images/$TEST_FILE
else
    echo "Error copying file $TEST_FILE to S3 bucket"
fi

