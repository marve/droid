FROM python:3-bookworm

ENV TZ=America/Los_Angeles

ADD "https://api.github.com/repos/marve/wordsearcher/commits?per_page=1" latest_commit
RUN curl -sLO "https://github.com/marve/wordsearcher/archive/main.zip" && unzip main.zip

COPY start.sh /start.sh

ENTRYPOINT /start.sh