FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common wget gnupg && \
    add-apt-repository -y ppa:iconnor/zoneminder-1.36 && \
    apt-get update && \
    apt-get install -y zoneminder php php-mysql apache2 libapache2-mod-php mysql-client && \
    apt-get install dumb-init -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN a2enconf zoneminder && \
    a2enmod rewrite cgi

COPY zoneminder.conf /etc/apache2/conf-available/zoneminder.conf
COPY .htpasswd /etc/zm/.htpasswd

COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/local/bin/wait-for-it.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/entrypoint.sh"]
