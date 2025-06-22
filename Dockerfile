FROM ruby:3.2

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3006

CMD ["ruby", "app.rb", "-o", "0.0.0.0", "-p", "3006"]
