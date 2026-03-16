#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Migrate all databases (primary + solid_queue, solid_cache, cable)
bundle exec rails db:prepare
