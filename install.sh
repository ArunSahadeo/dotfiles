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
npm
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
sendmail
sshfs
streamlink
traceroute
unrar
unzip
vim
whois
xclip
zip
)

apache_config() {
    userGroups=$(echo `id -Gn $USER`)
    WEBROOT_DIR=""

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

    if [[ ! $userGroups =~ [^www-data] ]]; then
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
        sudo sed -i "\$aAcceptFilter https none\nAcceptFilter https none" /etc/apache2/apache2.conf
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

fix_npm_permissions () {
    # Fix NPM permissions
    if [[ $(command -v npm &>/dev/null) ]]; then
        mkdir -p ~/.npm-global
        npm config set prefix '~/.npm-global'
        echo "export PATH=~/.npm-global/bin:$PATH" >> ~/.bashrc
        source ~/.bashrc
    fi
}

install_global_npm_dependencies () {
    # Install global NPM dependencies
    if [[ $(command -v npm &>/dev/null) ]]; then
        npm install -g gulp ngrok webpack
    fi
}

install_composer () {
    # Install composer
    if [[ ! -f /usr/local/bin/composer ]]; then
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
        php composer-setup.php
        php -r "unlink('composer-setup.php');"
        sudo mv composer.phar /usr/local/bin/composer
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
    if [[ ! $(command -v rvm &>/dev/null) && ! $(command -v ruby &>/dev/null) ]]; then
        curl -sSL https://get.rvm.io | bash
        source ~/.rvm/scripts/rvm
        rvm use ruby --install --default
    fi
}

install_gems () {
    if [[ ! $(command -v bundle &>/dev/null) ]]; then
        gem install bundler
    fi

    if [[ ! $(command -v sass &>/dev/null) ]]; then
        gem install sass
    fi
}

install_global_pip_packages () {
    if [[ ! $(command -v youtube-dl &>/dev/null) ]]; then
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

    apache_config

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

    exit 0
fi

if [[ "$UBUNTU_RELEASE" =~ "16." ]]; then
    INSTALL_COMMAND+=" libapache2-mod-fastcgi"
fi

INSTALL_COMMAND+=" 2>/dev/null"

sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Installing packages from list."
eval "$INSTALL_COMMAND"

if [[ ! $(command -v apache2 &>/dev/null) ]]; then
    echo "Apache does not seem to be installed. Moving on."
    exit 1  
fi

apache_config
fix_npm_permissions
install_global_npm_dependencies
install_composer
install_wp
install_ruby
install_gems
install_global_pip_packages

