FROM mwaeckerlin/very-base:latest

ENV CONTAINERNAME "allow-write-access"

RUN mkdir -p /app

CMD ["/bin/sh", "-c", "${ALLOW_USER} /app && sleep infinity"]
