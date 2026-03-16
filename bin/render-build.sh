#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Migrate primary database
bundle exec rails db:migrate

# Migrate secondary databases (Solid Cache, Solid Queue, Action Cable)
bundle exec rails db:migrate:cache
bundle exec rails db:migrate:queue
bundle exec rails db:migrate:cable
