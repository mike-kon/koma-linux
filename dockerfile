FROM debian:latest

# Установка нужных компонентов
RUN apt update \
    && apt install -y locales openssh-server sudo mc apache2

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

EXPOSE 22 80 8080

CMD  service apache2 start && /usr/sbin/sshd -D
