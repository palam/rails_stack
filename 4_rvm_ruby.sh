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

# Install git-core
echo -e "\n=> Installing git..."
sudo aptitude -y install git-core >> $log_file 2>&1
echo "==> done..."

#thanks wayneeseguin :)
echo -e "\n=> Installing RVM the Ruby enVironment Manager http://rvm.beginrescueend.com/rvm/install/ \n"
curl -O -L -k http://rvm.beginrescueend.com/releases/rvm-install-head
chmod +x rvm-install-head
"$PWD/rvm-install-head" >> $log_file 2>&1
[[ -f rvm-install-head ]] && rm -f rvm-install-head
echo -e "\n=> Setting up RVM to load with new shells..."
#if RVM is installed as user root it goes to /usr/local/rvm/ not ~/.rvm
echo  '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"  # Load RVM into a shell session *as a function*' >> "$HOME/.bash_profile"
echo "==> done..."
echo "=> Loading RVM..."
source ~/.bashrc
source ~/.bash_profile
source ~/.rvm/scripts/rvm
echo "==> done..."
echo -e "\n=> Installing Ruby $ruby_version_string (this will take a while)..."
echo -e "=> More information about installing rubies can be found at http://rvm.beginrescueend.com/rubies/installing/ \n"
rvm install $ruby_version >> $log_file 2>&1
echo -e "\n==> done..."
echo -e "\n=> Using 1.9.2 and setting it as default for new shells..."
echo "=> More information about Rubies can be found at http://rvm.beginrescueend.com/rubies/default/"
rvm --default use $ruby_version >> $log_file 2>&1
echo "==> done..."

echo -e "\n=> Reloading shell so ruby and rubygems are available..."
source $HOME/.bashrc
source $HOME/.bash_profile
echo "==> done..."

echo -e "\n=> Updating Rubygems..."
if [ $whichRuby -eq 1 ] ; then
  sudo gem update --system --no-ri --no-rdoc >> $log_file 2>&1
elif [ $whichRuby -eq 2 ] ; then
  gem update --system --no-ri --no-rdoc >> $log_file 2>&1
fi
echo "==> done..."

echo -e "\n=> Installing Bundler, Passenger and Rails..."
if [ $whichRuby -eq 1 ] ; then
  sudo gem install bundler passenger rails --no-ri --no-rdoc >> $log_file 2>&1
elif [ $whichRuby -eq 2 ] ; then
  gem install bundler passenger rails --no-ri --no-rdoc >> $log_file 2>&1
fi
echo "==> done..."

echo -e "\n#################################"
echo    "### Installation is complete! ###"
echo -e "#################################\n"

echo -e "\n !!! logout and back in to access Ruby !!!\n"