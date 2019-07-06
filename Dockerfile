FROM ruby:2.4

RUN apt-get update

WORKDIR /app
ADD Gemfile /app
ADD Gemfile.lock /app

ENV BUNDLE_PATH /box
RUN bundle install

ADD . /app