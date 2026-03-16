#!/usr/bin/env bash
# Exit immediately if any command fails
set -o errexit

# Install dependencies
bundle install

# Precompile assets for production
bundle exec rails assets:precompile

# Clear any stale asset cache
bundle exec rails assets:clean

# Run database migrations (creates tables if first deploy, updates them otherwise)
bundle exec rails db:migrate
