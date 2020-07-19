FROM rustagainshell/rash:1.0.0 AS rash

FROM python:3.8-alpine3.12

COPY --from=rash /bin/rash /bin

RUN apk add --no-cache bash

LABEL maintainer="Sergio del Rio <sdelrio@users.noreploy.github.com>" \
        python-version=3.8

ENV PYTHONIOENCODING=UTF-8
ENV PYTHONUNBUFFERED=1

ENV PATH="/root/.local/bin:$PATH"

ARG AWS_CLI_VERSION
ARG AWS_CLI_ENDPOINT_VERSION

RUN pip install --no-cache-dir --user awscli==$AWS_CLI_VERSION awscli-plugin-endpoint==$AWS_CLI_ENDPOINT_VERSION

COPY scripts/restore.sh /restore.sh
RUN chmod +x /restore.sh

COPY entrypoint.rh /
RUN chmod +x /entrypoint.rh

ENTRYPOINT ["/entrypoint.rh"]

