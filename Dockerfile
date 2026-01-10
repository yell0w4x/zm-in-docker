FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common wget gnupg && \
    add-apt-repository -y ppa:iconnor/zoneminder-1.36 && \
    apt-get update && \
    apt-get install -y zoneminder php php-mysql apache2 libapache2-mod-php mysql-client tzdata msmtp && \
    apt-get install dumb-init -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY zoneminder.conf /etc/apache2/conf-available/zoneminder.conf
COPY .htpasswd /etc/zm/.htpasswd

RUN a2enconf zoneminder && \
    a2enmod rewrite cgi headers expires ssl && \
    a2ensite default-ssl

COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/local/bin/wait-for-it.sh && \
    chmod +x /entrypoint.sh && \
    chown -R www-data:www-data /usr/share/zoneminder && \
    ln -s /usr/bin/msmtp /usr/bin/sendmail

COPY certs/my.org.crt /etc/ssl/certs/my.pem
COPY certs/my.org.key /etc/ssl/private/my.key
COPY certs/root-ca-my.org.crt /etc/apache2/ssl.crt/my-ca.crt

RUN echo "order deny,allow\ndeny from all" > /var/www/html/.htaccess && \ 
    chown www-data:www-data /var/www/html/.htaccess && \
    chmod 644 /var/www/html/.htaccess
RUN sed -i -E 's|SSLCertificateFile\s+\/etc\/ssl\/certs\/ssl-cert-snakeoil\.pem|SSLCertificateFile      /etc/ssl/certs/my.pem|g' /etc/apache2/sites-available/default-ssl.conf && \
    sed -i -E 's|SSLCertificateKeyFile\s+\/etc\/ssl\/private\/ssl-cert-snakeoil\.key|SSLCertificateKeyFile   /etc/ssl/private/my.key|g' /etc/apache2/sites-available/default-ssl.conf && \
    sed -i -E 's|#SSLCertificateChainFile\s+\/etc\/apache2\/ssl.crt\/server-ca.crt|SSLCertificateChainFile     /etc/apache2/ssl.crt/my-ca.crt|g' /etc/apache2/sites-available/default-ssl.conf && \
    sed -i -E 's|ServerTokens OS|ServerTokens Prod|g' /etc/apache2/conf-available/security.conf && \
    sed -i -E 's|ServerSignature On|ServerSignature Off|g' /etc/apache2/conf-available/security.conf && \
    sed -i -E 's|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/entrypoint.sh"]
