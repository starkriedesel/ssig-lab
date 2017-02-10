#!/bin/bash
set -e

cd /usr/src/app
echo RAILS_ENV = $RAILS_ENV

if [ $(bin/rake db:exists) -eq 0 ]; then
  echo "Setup database (first time)"
  bin/rake db:setup
else
  echo Run migrations
  bin/rake db:migrate
fi

if [ "$RAILS_ENV" == "production" ]; then
  echo Pre-compile assets for production
  bin/rake assets:precompile
fi

# Execute given command, default to running rails server
if [ "x$1" == "x" ]; then
  echo Running default
  exec bin/rails server -b 0.0.0.0 -p 3000
else
  echo Running "$@"
  exec "$@"
fi
