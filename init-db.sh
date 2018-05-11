#!/bin/bash
cd huginn

# initialise db
echo "Creating tables"
bundle exec rake db:create
echo "Migrating"
bundle exec rake db:migrate
echo "Seed database"
bundle exec rake db:seed
