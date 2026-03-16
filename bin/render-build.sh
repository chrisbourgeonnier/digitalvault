#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Migrate primary database
bundle exec rails db:migrate

# Load schemas for Solid Queue, Solid Cache and Action Cable
bundle exec rails db:schema:load:queue
bundle exec rails db:schema:load:cache
bundle exec rails db:schema:load:cable
