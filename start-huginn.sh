#!/bin/bash

# start mysql server
sudo service mysql start
sleep 1

# start huginn
cd huginn && bundle exec foreman start
