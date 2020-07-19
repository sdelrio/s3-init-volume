#!/bin/bash

echo "Checking mandatory ENV var parameters: ..."
[ -z "${ENDPOINT_URL}" ] \
    && { echo "=> ENDPOINT_URL cannot be empty" && exit 1; } \
    || { echo "=> ENDPOINT_URL [OK]" }
[ -z "${AWS_DEFAULT_REGION}" ] \
    && { echo "=> AWS_DEFAULT_REGION cannot be empty" && exit 1; } \
    || { echo "=> AWS_DEFAULT_REGION [OK]" }
[ -z "${AWS_ACCESS_KEY_ID}" ] \
    && { echo "=> AWS_ACCESS_KEY_ID cannot be empty" && exit 1; } \
    || { echo "=> AWS_ACCESS_KEY_ID [OK]" }
[ -z "${AWS_SECRET_ACCESS_KEY}" ] \
    && { echo "=> AWS_SECRET_ACCESS_KEY cannot be empty" && exit 1; } \
    || { echo "=> AWS_SECRET_ACCESS_KEY[OK]" }
[ -z "${S3_BUCKET_NAME}" ] \
    && { echo "=> S3_BUCKET_NAME cannot be empty" && exit 1; } \
    || { echo "=> S3_BUCKET_NAME[OK]" }
[ -z "${VOLUME}" ] \
    && { echo "=> VOLUME path cannot be empty" && exit 1; } \
    || { echo "=> VOLUME [OK]" }

./restore.sh

exit 0

