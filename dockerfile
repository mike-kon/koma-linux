FROM debian:latest

# Установка нужных компонентов
RUN apt update \
    && apt install -y locales openssh-server sudo mc apache2 openssl

# создание сервиса sshd
RUN mkdir -p /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Русская локаль
RUN mv /etc/locale.gen /etc/locale.gen.orign
RUN echo ru_RU.UTF-8 UTF-8 > /etc/locale.gen 
RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen 
RUN locale-gen ru_RU.UTF-8
RUN update-locale LANG=ru_RU.UTF-8 LC_ALL=ru_RU.UTF-8

# Создание пользователя koma с паролем 123
RUN useradd koma -m --groups sudo,www-data -s /bin/bash
RUN echo 'koma:123' | chpasswd
RUN chage -d 0 koma

# Настройка SSL для apache

RUN mkdir -p /etc/apache2/ssl
RUN openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache-selfsigned.key -out /etc/apache2/ssl/apache-selfsigned.crt -subj "/C=RU/ST=Docker/L=Localhost/O=MikeSoft/CN=localhost"

RUN a2enmod ssl
RUN a2enmod headers

RUN sed -i '/SSLCertificateFile  /c\	SSLCertificateFile      /etc/apache2/ssl/apache-selfsigned.crt ' /etc/apache2/sites-available/default-ssl.conf
RUN sed -i '/SSLCertificateKeyFile  /c\	SSLCertificateKeyFile   /etc/apache2/ssl/apache-selfsigned.key ' /etc/apache2/sites-available/default-ssl.conf
RUN a2ensite default-ssl.conf

EXPOSE 22 80 8080 443

RUN echo '#!/bin/bash \n\
echo "start docker" \n\
service apache2 start \n\
/usr/sbin/sshd -D \n\
' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
 


