#!/bin/bash

red='\033[31m'
green='\033[32m'
bleu='\e[1;34m'

abort()
{
    echo -e >&2 "${red}
**********************************************************
****************** INSTALLATION ABORTED ******************
**********************************************************
"
    echo "An error occurred. Exiting..." >&2
    exit 1
}

trap 'abort' 0

set -e

user="wpuser"
pass="passwp"
ip_bdd="34.107.111.77"

    # A exécuter sur wordpress
    echo -e "${bleu}******************************* 1. Installation du service Apache2 ******************************************"
   
sudo apt-get update
sudo apt-get -y install apache2 locales-all wget
sudo systemctl start apache2

    echo -e "${bleu}*************************** 2. Activé le service Apache2 au redémarrage du système **************************"

sudo systemctl enable apache2
sudo systemctl restart apache2

    echo -e "${bleu}************************ 3. Activé le mode rewrite 'url plus structurée' ************************************"

sudo a2enmod rewrite

    echo "${bleu}************************************ 4.   Activé le mode ssl 'Https' *******************************************"

sudo a2enmod ssl

    echo -e "${bleu}************************ 5. Activé le mode deflate 'compression du site/plus rapide'**************************"

sudo a2enmod deflate

    echo -e "${bleu}****************************** 6. Activé le mode headers 'en-tete http' **************************************"
    
sudo a2enmod headers

    echo -e "${bleu}***************************** 7. masqué la version du serveur apache2' ***************************************"

echo 'ServerTokens Prod' >> /etc/apache2/apache2.conf

    echo -e "${bleu}********************************** 8. Configuration apache2 **************************************************"

sudo cat <<"EOF" > /etc/apache2/sites-available/000-default.conf
NameVirtualHost *:80
<VirtualHost *:80>
    UseCanonicalName Off
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    Options All
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

    echo -e "${bleu}****************************** 9.  Installation zabbix Agent  ********************************"

sudo apt-get -y install zabbix-agent

    echo -e "${bleu}************************* 10. Configuration zabbix agent *******************************************"

sudo sed -i "s/# DBHost=localhost/DBHost=$ip_bdd/" /etc/zabbix/zabbix_agentd.conf 


    echo -e "${bleu}******************** 11.  PHP *****************"



    echo -e "${bleu}********************* 12. Installation du PHP et de ses modules nécessaire  ************************************"

sudo apt-get -y install php libapache2-mod-php php-fpm php-curl php-cli php-zip php-mysql php-xml php-mbstring php-gd php-xmlrpc php-imagick php-intl php-soap 

    echo -e "${bleu}********************************* 13. Telechargement du CMS Wordpress ******************************************"

wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

    echo -e "${bleu}********************** 14. Deplacer tout les fichiers wordpress dans la racine html ****************************"

sudo mv wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/

        echo -e "${bleu}********************** 15. Augmenter la taille des fichiers téléversés sur WordPress ***********************"
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 3G/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/memory_limit = 128M/memory_limit = 256M/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/post_max_size = 8M/post_max_size = 3G/g' /etc/php/7.4/fpm/php.ini
sudo service php7.4-fpm restart
sudo service apache2 restart


    echo -e "${bleu}**************************** 16. configuration du fichier wp-confing.php ***************************************"

sudo touch  /var/www/html/wp-config.php

sudo cat <<"EOF" > /var/www/html/wp-config.php
<?php
# Created by setup-mysql
define('DB_NAME', 'wpdata');
define('DB_USER', 'user_to_replace');
define('DB_PASSWORD', 'password_to_replace');
define('DB_HOST', 'host_to_replace');
$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF

#remplacement des valeurs par les variables
sudo sed -i "s/user_to_replace/$user/" /var/www/html/wp-config.php
sudo sed -i "s/password_to_replace/$pass/" /var/www/html/wp-config.php
sudo sed -i "s/host_to_replace/$ip_bdd/" /var/www/html/wp-config.php

    echo  -e "${bleu}*********************** 17. Droit de lecture seule au fichier wp-confing.php **********************************"

sudo chmod 400 /var/www/html/wp-config.php
sudo chown -R www-data:www-data /var/www/html/wp-config.php

    echo -e "${bleu}************************************ 18. Supprimer les fichiers par defaut *************************************"
    
sudo rm -rf /var/www/html/index.html
sudo rm -rf /var/www/html/wp-config-sample.php
sudo rm -rf /var/www/html/wp-content/themes/twentytwentythree/
sudo rm -rf /var/www/html/wp-content/themes/twentytwentytwo/


    echo -e "${bleu}************************************* 19. Recharger les services ***********************************************"
    
sudo service php7.4-fpm restart
sudo service apache2 restart
sudo service zabbix-agent restart
sudo a2enmod rewrite
sudo a2enmod vhost_alias

trap : 0

echo -e >&2 "${green}
**********************************************************
************* INSTALLATION DONE SUCCESSFULLY *************
**********************************************************
"

