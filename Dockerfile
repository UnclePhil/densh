FROM docker:29-cli
ARG build_arg="-"

ENV BUILD=$build_arg

LABEL maintainer="koenigphil@gmail.com"
LABEL purpose="Monitor Docker events and send it to apprise Api"

RUN apk update && apk add --no-cache curl jq bash

WORKDIR /root
COPY src/densh.sh .

ENTRYPOINT [ "/root/densh.sh" ]
