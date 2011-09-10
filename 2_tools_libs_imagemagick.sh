#!/bin/bash

shopt -s nocaseglob
set -e

railsready_path=$(cd && pwd)/railsready
log_file="$railsready_path/install.log"

echo -e "\n=> Installing build tools..."
sudo aptitude -y install \
    wget curl build-essential clang \
    bison openssl zlib1g \
    libxslt1.1 libssl-dev libxslt1-dev \
    libxml2 libffi-dev libyaml-dev \
    libxslt-dev autoconf libc6-dev \
    libreadline6-dev zlib1g-dev libcurl4-openssl-dev >> $log_file 2>&1
echo "==> done..."

echo -e "\n=> Installing libs needed for sqlite and mysql..."
sudo aptitude -y install libsqlite3-0 sqlite3 libsqlite3-dev libmysqlclient16-dev libmysqlclient16 >> $log_file 2>&1
echo "==> done..."

echo -e "\n=> Installing imagemagick (this may take a while)..."
sudo aptitude -y install imagemagick libmagick9-dev >> $log_file 2>&1
echo "==> done..."