#!/bin/bash

# *********CHECK BUCKET ************ #
#[ $(aws --endpoint-url ${ENDPOINT_URL} s3 ls | grep ${S3_BUCKET_NAME} | wc -l) -eq 0 ] \
BUCKET_EXIST=$(aws --endpoint-url ${ENDPOINT_URL} s3 ls | grep ${S3_BUCKET_NAME} | wc -l)
if [ ${BUCKET_EXIST} -eq 0 ]; then
    echo "Bucket ${S3_BUCKET_NAME} does not exist"
    exit 1
else
    echo "Bucket ${S3_BUCKET_NAME} exists"
fi

# EXTRACTING LAST BACKUP FROM BUCKET

if [ -z "${LAST_BACKUP}" ]; then
# Find last backup file
: ${LAST_BACKUP:=$(aws --endpoint-url ${ENDPOINT_URL} s3 ls s3://$S3_BUCKET_NAME | awk -F " " '{print $4}' | head -n1)}
fi

# DOWNLOADING LAST BACKUP FROM S3 BUCKET

echo "=> Restore from S3 => $LAST_BACKUP"
aws --endpoint-url ${ENDPOINT_URL} s3 cp s3://$S3_BUCKET_NAME/$LAST_BACKUP $RESTORE_FOLDER/$LAST_BACKUP

# COPYING TO VOLUME FOLDER

mkdir ${VOLUME} || echo "[ERR] coudl not create ${VOLUME} directory"

echo "Extracting ${RESTORE_FOLDER}/${LAST_BACKUP} ..."
tar -xzf ${RESTORE_FOLDER}/${LAST_BACKUP} -C ${VOLUME}
echo "Untar complete"

echo "Content of ${VOLUME}:"
echo
ls -la ${VOLUME}

echo
echo "=> Restored dump from ${S3_BUCKET_NAME}/${LAST_BACKUP}"
echo "=> Done"

exit 0

