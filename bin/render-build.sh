#!/usr/bin/env bash

bundle install
bin/rails assets:precompile
bin/rails assets:clean
