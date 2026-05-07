#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Migrate primary database (safe, incremental)
bundle exec rails db:migrate

# Handles both fresh and existing databases safely
{ DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:schema:load:queue || bundle exec rails db:migrate:queue; }
{ DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:schema:load:cache || bundle exec rails db:migrate:cache; }
{ DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:schema:load:cable || bundle exec rails db:migrate:cable; }
