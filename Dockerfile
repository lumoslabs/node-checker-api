FROM ruby:2.4.1
RUN mkdir /usr/src/app
ADD Gemfile* /usr/src/app/
WORKDIR /usr/src/app/
RUN bundle

ADD . /usr/src/app/

CMD ["ruby", "/usr/src/app/app.rb"]
