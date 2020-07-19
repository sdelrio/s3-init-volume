# AWS cli with entrypoint plugin

The main target is to create a container that can read from a 3rd party S3 and extract a tar.gz to a target directory (`VOLUME`). That way you can use it on an InitContainer on kubernetes for an aplication.

# Sample execution
```
docker run \
    --env ENDPOINT_URL=https://s3.nl-ams.scw.cloud \
    --env AWS_DEFAULT_REGION=nl-ams \
    --env AWS_ACCESS_KEY_ID=MYS3KEYID \
    --env AWS_SECRET_ACCESS_KEY=MYS3SECRET \
    --env S3_BUCKET_NAME=mybucket \
    --env VOLUME=/data1 \
    --rm -ti sdelrio/awscli-plugin-endpoint
```

