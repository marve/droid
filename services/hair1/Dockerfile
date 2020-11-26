FROM ubuntu:20.04

ENV TZ=America/Los_Angeles

RUN apt-get update && apt-get install \
    curl \
    ca-certificates \
    jq \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav -y --no-install-recommends

COPY start.sh /start.sh

ENTRYPOINT [ "/start.sh" ]