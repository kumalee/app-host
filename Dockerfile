# syntax=docker/dockerfile:1
FROM registry.docker.com/library/ruby:3.2.2-slim
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log
ENV RAILS_ENV production

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        build-essential git pkg-config \
        curl libsqlite3-0 libvips nodejs npm \
        imagemagick nginx && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN gem install bundler

WORKDIR /app

ADD Gemfile* ./
RUN bundle install
COPY . .
COPY docker/nginx.conf /etc/nginx/sites-enabled/app.conf

# 编译静态文件
RUN rake assets:precompile

EXPOSE 8686

CMD /bin/bash docker/check_prereqs.sh && service nginx start && puma -C config/puma.rb
