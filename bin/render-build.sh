#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Migrate primary database (safe, incremental)
bundle exec rails db:migrate

# Load schemas for Solid Queue, Solid Cache and Action Cable.
# DISABLE_DATABASE_ENVIRONMENT_CHECK is safe here because these databases
# contain no user data — only background job and cache tables.
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:schema:load:queue
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:schema:load:cache
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:schema:load:cable
