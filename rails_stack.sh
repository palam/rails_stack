#!/bin/bash
#
# Work in progress based on Rails Ready (https://github.com/joshfng/railsready) and Rails Ready Ready (https://github.com/3months/railsready-ready)
#

shopt -s nocaseglob
set -e
set -u

script_runner=$(whoami)
railsready_path=$(cd && pwd)/railsready
log_file="$railsready_path/install.log"
distro_sig=$(cat /etc/issue)
admin_user_name="admin"
user_home="/home/$admin_user_name"
repository_url="https://github.com/palam/rails_stack"
templates_url="https://raw.github.com/palam/rails_stack/master/templates"
ssh_port="30000"



control_c()
{
    echo -n "\n\n*** Exiting ***\n"
    exit 1
}

# Intercept any keyboard interrupts
trap control_c SIGINT

# Check the distro is supported
if [[ $distro_sig =~ ubuntu ]] ; then
    distro="ubuntu"
else
    echo -e "\nOnly for Ubuntu!\n"
    exit 1
fi

# Check user is root
if [ $script_runner =! "root" ] ; then
    echo -e "\nThis script must be run as root\n"
    exit 1
fi

echo "run tail -f $log_file in a new terminal to watch the install"

echo -e "\n"
echo "What this script creates:"
echo " * An $admin_user_name user that is permitted to sudo"
echo " * A secure SSH configuration preconfigured to prefer public key authenitcation"
echo " * A webserver-oriented IP Tables configuration allowing web and SSH traffic only"

echo -e "\n"
echo -e "\n=> Creating log file..."
cd && mkdir -p rails_stack && touch install.log
echo "==> done."


echo "Installing sudo..."
aptitude -y install sudo
echo "==> done."
echo -e "Adding admin user $admin_user_name"
echo "Enter admin password: "
read admin_password
useradd $admin_user_name -g admin --create-home
echo "${admin_user_name}:${admin_password}" | chpasswd
echo "==> done."

echo -e "\n=> Installing OpenSSH server, if it isn't already installed..."
apt-get install openssh-server
echo "==> done."

if [[ -d "$user_home/.ssh" ]] ; then
    echo -e "\n=> Don't need to create user's .ssh directory, it already exists"
else
    echo -e "\n=> Creating SSH config folder structure at $user_home/.ssh..."
    mkdir -p $user_home/.ssh
fi
echo "==> done."

echo "Replacing system-default SSHD config file with more secure version. Summary of changes:"
echo "=> 1. Root login disabled"
echo "=> 2. Only user $admin_user_name is permitted to login."
echo "=> 3. Unused authentication mechanisms are disabled."
echo "=> 4. Some other minor performance and security enhancements."
echo "!!! NOTE: This script will set up public key authentication, but will not disable password authentication - just something to keep in mind !!!"
echo -e "=> Replacing default SSHD config with template from $templates_url/sshd_config..."
echo "Backed up old sshd_config to sshd_config.old"
wget --no-check-certificate $templates_url/sshd_config -O /etc/ssh/sshd_config
sed s/SSH_PORT/$ssh_port/ </etc/ssh/sshd_config >/etc/ssh/sshd_config_t
mv /etc/ssh/sshd_config_t /etc/ssh/sshd_config
sed s/ADMIN_USER_NAME/$admin_user_name/ </etc/ssh/sshd_config >/etc/ssh/sshd_config_t
mv /etc/ssh/sshd_config_t /etc/ssh/sshd_config
echo "==> done."

echo "Adding IP Tables ruleset for a Rails web server. Summary of changes:"
echo "=> 1. Web server ports 80 and 443 are enabled for all traffic"
echo "=> 2. Your configured SSH port is open for incoming traffic"
echo "=> 3. Incoming ping requests are allowed."
echo "=> 4. All other incoming ports are blocked, but outgoing traffic is permitted on any port"
echo -e "=> Adding configuration for IP Tables from $templates_url/iptables.up.rules"
echo "Flush existing rules..."
/sbin/iptables -F
echo "Placing rules file in /etc"
wget --no-check-certificate $templates_url/iptables.up.rules -O /etc/iptables.up.rules
sed s/SSH_PORT/$ssh_port/ </etc/iptables.up.rules >/etc/iptables.up.rules_t
mv /etc/iptables.up.rules_t /etc/iptables.up.rules
echo "Adding network interface boot script to load rules into iptables"
echo -e '#!/bin/sh
    /sbin/iptables-restore < /etc/iptables.up.rules' > /etc/network/if-pre-up.d/iptables
echo "Making new script executable"
chmod +x /etc/network/if-pre-up.d/iptables
echo "==> done."