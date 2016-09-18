FROM ruby:2.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/Gemfile
RUN bundle install

COPY . /usr/src/app
RUN rm -rf /usr/src/app/db/data/*.sqlite3

ENTRYPOINT ["/usr/src/app/start.sh"]
CMD ["/usr/src/app/bin/rails", "server", "-p", "3000", "-b", "0.0.0.0"]