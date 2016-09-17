#!/bin/bash
set -e

cd /usr/src/app
echo RAILS_ENV = $RAILS_ENV

echo Setup database
bin/rake db:create
bin/rake db:migrate
bin/rake db:seed

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
