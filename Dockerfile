FROM rails:onbuild

# Prevent silent errors when Gemfile.lock is generated on a different system (like windows!)
# Make sure to provide specific version numbers in the Gemfile!
RUN bundle config --global frozen 0
RUN bundle install

ENV RAILS_ENV production

RUN rake assets:precompile
RUN rm -f /usr/src/app/db/production.sqlite3
