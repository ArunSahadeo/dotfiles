#!/usr/bin/env bash

PACKAGES=(
apache2
cowsay
etckeeper
ffmpeg
git
git-extras
htop
irssi
jpegtran
jq
make
mpv
mysql-server
ncftp
nodejs
nmap
optipng
p7zip-full
php
php-curl
php-cli
php-dev
php-fpm
php-intl
php-json
php-mbstring
php-mysql
php-gd
php-xml
php-zip
php5.6
php5.6-curl
php5.6-dev
php5.6-fpm
php5.6-intl
php5.6-json
php5.6-mcrypt
php5.6-mbstring
php5.6-mysql
php5.6-gd
php5.6-xml
php5.6-zip
php7.1
php7.1-curl
php7.1-dev
php7.1-fpm
php7.1-intl
php7.1-json
php7.1-mcrypt
php7.1-mbstring
php7.1-mysql
php7.1-gd
php7.1-xml
php7.1-zip
php7.2
php7.2-curl
php7.2-dev
php7.2-fpm
php7.2-intl
php7.2-json
php7.2-mcrypt
php7.2-mbstring
php7.2-mysql
php7.2-gd
php7.2-xml
php7.2-zip
python3
python3-pip
rename
sendmail
sshfs
streamlink
tmux
traceroute
unrar
unzip
vim
whois
xclip
zip
)

apache_config () {
    userGroups=$(echo `id -Gn $USER`)
    WEBROOT_DIR=""

    if [[ $userGroups =~ (www-data) ]]; then
        echo "Apache already set up"
        return 0
    fi

    case "$UBUNTU_RELEASE" in
        '18.'*) sudo a2enmod actions alias proxy_fcgi;;
        '16.'*) sudo a2enmod actions fastcgi alias proxy_fcgi;;
    esac

    if grep -qe "[Microsoft|WSL]" /proc/version &> /dev/null; then
        echo "You are running Windows Subsystem for Linux."
        WEBROOT_DIR="/mnt/c/projects/www"
        WSL=true
    else
        WEBROOT_DIR="/var/www"
    fi

    if [[ ! -d $WEBROOT_DIR ]]; then
        mkdir -p $WEBROOT_DIR
    fi

    if [[ ! $userGroups =~ (www-data) ]]; then
        sudo usermod -a -G www-data $USER
    fi 

    # Activate default Apache virtual host if exists
    if [[ -f /etc/apache2/sites-available/000-default.conf ]]; then
        sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.orig
        sudo sed -i 's/CustomLog.*/&\n\n\t<FilesMatch \\.php\$>\n\t\tSetHandler "proxy:unix:\/var\/run\/php\/php7.2-fpm.sock|fcgi:\/\/localhost\/"\n\t<\/FilesMatch>/g' /etc/apache2/sites-available/000-default.conf

        if [[ $WSL ]]; then
            SEARCH_STRING="/var/www/html"
            REPLACEMENT="$WEBROOT_DIR/default"
            sudo sed -i "s,$SEARCH_STRING,$REPLACEMENT,g" /etc/apache2/sites-available/000-default.conf
        fi

        cd /etc/apache2/sites-available
        sudo a2ensite * 
        sudo service apache2 reload
    fi

    if [[ $WSL && -f /etc/apache2/apache2.conf ]]; then
        sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.orig
        sudo sed -i "\$aAcceptFilter http none\nAcceptFilter https none" /etc/apache2/apache2.conf
        sudo sed -i "s/<Directory \/var\/www\/html>/<Directory \/mnt\/c\/projects\/www>g" /etc/apache2/sites-available/000-default.conf
        sudo a2enmod rewrite
        sudo service apache2 restart
    fi

    sudo a2dismod mpm-prefork php && sudo a2enmod mpm-event
    sudo usermod -d /var/lib/mysql mysql
    source /etc/apache2/envvars
    sudo service apache2 start
    sudo service mysql start
    sudo a2enconf php5.6-fpm && sudo a2enconf php7.1-fpm && sudo a2enconf php7.2-fpm
    sudo service apache2 reload
    sudo service php5.6-fpm start
    sudo service php7.1-fpm start
    sudo service php7.2-fpm start
}

configure_mail () {
    sudo sendmailconfig
    sudo service apache2 restart
}

fix_npm_permissions () {
    # Check if NPM installed

    if [[ ! $(command -v npm) || $(which npm) =~ /mnt/ ]]; then
        echo "NPM does not seem to be installed."
        return 1
    fi

    # Fix NPM permissions
    if [[ $(command -v npm) && $(npm config get prefix) == "/usr" ]]; then
        mkdir -p ~/.npm-global
        npm config set prefix "~/.npm-global"
        echo "export PATH=~/.npm-global/bin:$PATH" >> ~/.bashrc
        source ~/.bashrc
    fi
}

install_global_npm_dependencies () {
    # Install global NPM dependencies
    if [[ $(command -v npm) ]]; then
        npm install -g gulp ngrok webpack
    fi
}

install_composer () {
    # Add /usr/local/bin to $PATH if not already
    if ! grep -qe "/usr/local/bin" <<< $PATH; then
        echo "export PATH=$PATH:/usr/local/bin" >> ~/.bashrc
        source ~/.bashrc
    fi

    # Add COMPOSER_HOME environment variable if not already exists
    if ! grep -qe "COMPOSER_HOME" <<< $(printenv); then
        echo "export COMPOSER_HOME=\"$HOME/.config/composer\"" >> ~/.bashrc
        source ~/.bashrc
    fi

    # Install composer
    if [[ ! -f /usr/local/bin/composer ]]; then
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
        php composer-setup.php
        php -r "unlink('composer-setup.php');"
        chmod +x composer.phar
        sudo mv ./composer.phar /usr/local/bin/composer
        (crontab -l 2>/dev/null; echo '0 10 * * * composer self-update') | crontab
    else
        composer self-update
    fi
}

install_wp () {
    if [[ ! -f /usr/local/bin/wp ]]; then
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        sudo mv ./wp-cli.phar /usr/local/bin/wp
    fi
}

install_ruby () {
    if [[ ! $(command -v rvm) && ! $(command -v ruby) ]]; then
        curl -sSL https://get.rvm.io | bash
        source ~/.rvm/scripts/rvm
        rvm use ruby --install --default
    fi
}

install_gems () {
    if [[ ! $(command -v bundle) ]]; then
        gem install bundler
    fi

    if [[ ! $(command -v sass) ]]; then
        gem install sass
    fi
}

install_global_pip_packages () {
    if [[ ! $(command -v youtube-dl) ]]; then
        pip3 install --user youtube-dl
    fi
}

UNINSTALLED_PACKAGES=""
INSTALL_COMMAND="sudo apt-get install -y"
WSL=false
UBUNTU_RELEASE=`lsb_release -sr 2>/dev/null`
WEBROOT_DIR=""

for package in "${PACKAGES[@]}"; do
    PACKAGE_STATUS=$(sudo apt-cache policy $package)
    echo "Checking if $package is already installed."
    if grep -q "Installed: (none)" <<< "$PACKAGE_STATUS"; then
        echo "$package does not seem to be installed."
        UNINSTALLED_PACKAGES+="$package "
        INSTALL_COMMAND+=" $package"
    else
        echo "$package is already installed."
    fi
done

if [[ ${#UNINSTALLED_PACKAGES} == 0 ]]; then
    echo "No uninstalled packages."

    # Source Apache env vars to avoid startup errors
    source /etc/apache2/envvars 
    apache_config

    if [ "$?" != 0 ]; then
        exit 1  
    fi 

    configure_mail

    if [ "$?" != 0 ]; then
        exit 1  
    fi 

    fix_npm_permissions

    if [ "$?" != 0 ]; then
        exit 1  
    fi 

    install_global_npm_dependencies

    if [ "$?" != 0 ]; then
        exit 1   
    fi

    install_composer

    if [ "$?" != 0 ]; then
        exit 1   
    fi

    install_wp

    if [ "$?" != 0 ]; then
        exit 1   
    fi
    
    install_ruby

    if [ "$?" != 0 ]; then
        exit 1   
    fi
    
    install_gems

    if [ "$?" != 0 ]; then
        exit 1   
    fi
    
    install_global_pip_packages

    # Start PHP-FPM services
    sudo service php5.6-fpm start
    sudo service php7.1-fpm start
    sudo service php7.2-fpm start

    exit 0
fi

if [[ "$UBUNTU_RELEASE" =~ "16." ]]; then
    INSTALL_COMMAND+=" libapache2-mod-fastcgi"
fi

echo "The uninstalled packages are $UNINSTALLED_PACKAGES"

INSTALL_COMMAND+=" 2>/dev/null"

sudo add-apt-repository -y ppa:ondrej/php
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Installing packages from list."
eval "$INSTALL_COMMAND"

# Source Apache env vars to avoid startup errors
source /etc/apache2/envvars 

if [[ ! $(command -v apache2) ]]; then
    echo "Apache does not seem to be installed. Moving on."
    exit 1  
fi

apache_config
configure_mail
fix_npm_permissions
install_global_npm_dependencies
install_composer
install_wp
install_ruby
install_gems
install_global_pip_packages
