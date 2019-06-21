FROM ruby:2.4

RUN apt-get update

WORKDIR /app
ADD Gemfile /app
ADD Gemfile.lock /app

RUN bundle install

ADD . /app