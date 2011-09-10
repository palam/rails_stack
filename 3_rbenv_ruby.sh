#!/bin/bash

shopt -s nocaseglob
set -e

ruby_version="1.9.2"
ruby_version_string="1.9.2-p290"
ruby_source_url="http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz"
ruby_source_tar_name="ruby-1.9.2-p290.tar.gz"
ruby_source_dir_name="ruby-1.9.2-p290"
script_runner=$(whoami)
railsready_path=$(cd && pwd)/railsready
log_file="$railsready_path/install.log"
distro_sig=$(cat /etc/issue)
rbenv_path=$(cd && pwd)/.rbenv/versions

# Install git-core
echo -e "\n=> Installing git..."
sudo aptitude -y install git-core >> $log_file 2>&1
echo "==> done..."

echo -e "\n=> Installing rbenv..."
git clone git://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"' >> .bashrc
echo "==> done..."
echo -e "\n=> Reloading shell so rbenv is available..."
source $HOME/.bashrc
echo "==> done..."

echo -e "\n=> Downloading Ruby $ruby_version_string \n"
mkdir $rbenv_path && cd $rbenv_path && wget $ruby_source_url
echo -e "\n==> done..."
echo -e "\n=> Extracting Ruby $ruby_version_string"
tar -xzf $ruby_source_tar_name >> $log_file 2>&1
echo "==> done..."
echo -e "\n=> Installing Ruby $ruby_version_string"
cd $ruby_source_dir_name
echo "configure..."
./configure --prefix=$HOME/.rbenv/versions/$ruby_version_string >> $log_file 2>&1
echo "make..."
make >> $log_file 2>&1
echo "make install..."
make install >> $log_file 2>&1
rbenv rehash
echo "==> done..."

echo -e "\n=> Making Ruby $ruby_version_string the global default"
rbenv global $ruby_version_string

echo -e "\n=> Reloading shell so ruby and rubygems are available..."
source $HOME/.bashrc
echo "==> done..."

echo -e "\n=> Updating Rubygems..."
gem update --system --no-ri --no-rdoc >> $log_file 2>&1
echo "==> done..."

echo -e "\n=> Installing Bundler, Passenger and Rails..."
gem install bundler passenger rails --no-ri --no-rdoc >> $log_file 2>&1
echo "==> done..."

echo -e "\n !!! logout and back in to access Ruby !!!\n"