FROM ubuntu:18.04

# install and configure php
RUN apt-get update && \
        apt-get install -y \
        nano \
        wget \
        curl \
        ruby \
        rubygems-integration \
        ruby-dev \
        libmysqlclient-dev \
        build-essential \
        git \
        curl \
        sudo

# install rake and bundler
RUN gem install rake bundler mysql2

# set environment variables for string type
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# checkout huginn, open folder and install dependencies, append some stuff to gemfile to get build to work on default ubuntu install
RUN git clone https://github.com/huginn/huginn.git && \
	cd huginn && \ 
	cp .env.example .env && \
	echo Encoding.default_external = Encoding::UTF_8 > Gemfile && \
	echo Encoding.default_internal = Encoding::UTF_8 > Gemfile && \
	bundle

# install and configure db
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections

RUN apt-get update && \
	apt-get -y install mysql-server-5.7 && \
	mkdir -p /var/lib/mysql && \
	mkdir -p /var/run/mysqld && \
	mkdir -p /var/log/mysql && \
	chown -R mysql:mysql /var/lib/mysql && \
	chown -R mysql:mysql /var/run/mysqld && \
	chown -R mysql:mysql /var/log/mysql

# UTF-8 and bind-address
RUN sed -i -e "$ a [client]\n\n[mysql]\n\n[mysqld]"  /etc/mysql/my.cnf && \
	sed -i -e "s/\(\[client\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf && \
	sed -i -e "s/\(\[mysql\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf && \
	sed -i -e "s/\(\[mysqld\]\)/\1\ninit_connect='SET NAMES utf8'\ncharacter-set-server = utf8\ncollation-server=utf8_unicode_ci\nbind-address = 0.0.0.0/g" /etc/mysql/my.cnf

# for some reason a writable volume is required for databases
VOLUME /var/lib/mysql

# enable sudo for docker user
RUN echo "docker ALL=NOPASSWD: ALL" >> /etc/sudoers

# start huginn
COPY start-huginn.sh /usr/sbin/
RUN chmod +x /usr/sbin/start-huginn.sh
CMD ["/usr/sbin/start-huginn.sh"]
