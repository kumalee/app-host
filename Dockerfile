FROM ruby:3.2.2-slim
ENV RAILS_ENV production

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        build-essential git sqlite3 pkg-config \
        curl libsqlite3-dev libvips nodejs \
        imagemagick nginx && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN gem install bundler

WORKDIR /app

ADD Gemfile* ./
RUN bundle install
COPY . .
COPY docker/nginx.conf /etc/nginx/sites-enabled/app.conf

# 编译静态文件
RUN ./bin/rake assets:precompile

EXPOSE 8686

CMD /bin/bash docker/check_prereqs.sh && service nginx start && puma -C config/puma.rb
