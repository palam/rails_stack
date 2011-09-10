#!/bin/bash

shopt -s nocaseglob
set -e

script_runner=$(whoami)
echo "Enter domain name: "
read domain_name

cd ~/repos
mkdir $domain_name.git
cd $domain_name.git
git init --bare

echo -e "#!/bin/sh
GIT_WORK_TREE=/home/$script_runner/sites/$domain_name/public git checkout -f" > hooks/post-receive

chmod +x hooks/post-receive