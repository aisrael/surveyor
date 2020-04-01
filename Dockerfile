FROM ruby:2.6.4

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash && apt-get install -y nodejs
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install yarn

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
EXPOSE 3000
ENV RAILS_ENV production
ENTRYPOINT ["rails"]
CMD ["server", "-b", "0.0.0.0"]
COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle config --global frozen 1
RUN bundle install --without test
COPY . /usr/src/app/
RUN rails webpacker:install
