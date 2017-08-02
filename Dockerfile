FROM debian:jessie
MAINTAINER sergey.motorny@vanderbilt.edu

# Usage:
# docker run -d --name=apache-php -p 8080:80 -p 8443:443 chriswayg/apache-php
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

RUN apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get -y install \
      apache2 \
      libapache2-mod-php5 \
      php5 \
      mysql-client \
      php5-mysql \
      php5-curl \
      php5-gd \
      vim \
      mailutils && \
    apt-get clean && rm -r /var/lib/apt/lists/*

# Apache + PHP requires preforking Apache for best results & enable Apache SSL
# forward request and error logs to docker log collector
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork \
            ssl \
            rewrite && \
    a2ensite default-ssl && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

WORKDIR /var/www/html

COPY apache2-foreground /bin/
COPY apache2.conf /etc/apache2/
COPY 000-default.conf /etc/apache2/sites-available
COPY update-exim4.conf.conf /etc/exim4/

RUN /usr/sbin/update-exim4.conf

EXPOSE 80
EXPOSE 443

CMD ["/bin/apache2-foreground"]
