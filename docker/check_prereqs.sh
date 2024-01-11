#!/bin/bash
cd /app

RAILS_ENV=production

mkdir -p shared/tmp/pids
mkdir -p shared/log
mkdir -p shared/public/uploads

rm -rf tmp && ln -s /app/shared/tmp .
rm -rf log && ln -s /app/shared/log .

ln -sf /app/shared/public/uploads public/uploads

#build secret_key_base
secret_file="config/secrets.yml"
flag="SECRET_KEY_BASE"
existing=$(cat $secret_file | grep "$flag")
if [[ $existing != "" ]]; then
  secret_key_base=$(ruby -e "require 'securerandom';puts SecureRandom.hex(64)")
  secret_text=$(sed -e "s/$flag/$secret_key_base/" $secret_file)
  echo "$secret_text" > $secret_file
fi

rm -rf storage/production.sqlite3
rm -rf storage/production.sqlite3-shim
rm -rf storage/production.sqlite3-wal
if [[ ! -f /app/shared/production.sqlite3 ]]; then
  ./bin/bundle exec rake db:migrate
  mv storage/production.sqlite3 /app/shared/production.sqlite3
  if [[ -f storage/production.sqlite3-shim ]]; then
    mv storage/production.sqlite3-shim /app/shared/production.sqlite3-shim
  fi
  if [[ -f storage/production.sqlite3-wal ]]; then
    mv storage/production.sqlite3-wal /app/shared/production.sqlite3-wal
  fi
fi

ln -sf /app/shared/production.sqlite3 storage/production.sqlite3
if [[ ! -f /app/shared/production.sqlite3-shim ]]; then
  ln -sf /app/shared/production.sqlite3-shim storage/production.sqlite3-shim
fi
if [[ ! -f /app/shared/production.sqlite3-wal ]]; then
  ln -sf /app/shared/production.sqlite3-wal storage/production.sqlite3-wal
fi