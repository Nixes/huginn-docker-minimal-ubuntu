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
	git \
	curl \
	sudo
	
# install rake and bundler
RUN gem install rake bundler mysql2

# checkout huginn, open folder and install dependencies
RUN git clone https://github.com/huginn/huginn.git && \
	cd huginn && \ 
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
