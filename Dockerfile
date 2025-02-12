# Dockerfile for Webmin deployment
# Inspired by the work of Johan Pienaar at https://github.com/johanpi/docker-webmin
FROM ubuntu:latest
LABEL maintainer="Bar Abudi <barabudy@gmail.com>"

WORKDIR /webmin

# Install updates and additional required package dependencies
COPY packages.txt .
RUN apt-get update -y && \
    apt-get upgrade -y && \
    xargs -a packages.txt apt-get install -y && \
    rm -rf /var/lib/apt/lists/*
RUN dpkg-reconfigure locales

# Install Webmin
RUN echo root:password | chpasswd && \
    echo "Acquire::GzipIndexes \"false\"; Acquire::CompressionTypes::Order:: \"gz\";" >/etc/apt/apt.conf.d/docker-gzip-indexes && \
    update-locale LANG=C.UTF-8 && \
    echo deb https://download.webmin.com/download/repository sarge contrib >> /etc/apt/sources.list && \
    wget http://www.webmin.com/jcameron-key.asc && \
    apt-key add jcameron-key.asc && \
    apt-get update && \
    apt-get install -y webmin
RUN apt-get clean

EXPOSE 10000

RUN echo "#! /bin/bash" > start_webmin.sh && \
    echo "systemctl enable cron && service webmin start && tail -f /dev/null" >> start_webmin.sh && \
    chmod 755 start_webmin.sh

CMD /webmin/start_webmin.sh