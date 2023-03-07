#!/bin/bash

bleu="\e[1;34m"

$bdd="34.107.111.77"
$zab="35.246.188.16"
$passzabbix="passzabbix"

        echo -e "${bleu}************************************** \\ Installation des paquets Zabbix // ********************************************************"

sudo apt-get update
sudo apt-get -y install apache2 php php-mysql php-mysqlnd php-ldap php-bcmath php-mbstring php-gd php-pdo php-xml libapache2-mod-php wget
sudo apt-get -y install mariadb-server mariadb-client curl

        echo -e "${bleu}************************************** \\ Installation et configuration de Zabbix // *************************************************"

wget https://repo.zabbix.com/zabbix/6.2/debian/pool/main/z/zabbix-release/zabbix-release_6.2-4%2Bdebian11_all.deb
sudo dpkg -i zabbix-release_6.2-4%2Bdebian11_all.deb
sudo apt-get -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
sudo apt-get -y install locales-all
sudo locale-gen en_US.UTF-8
sudo service apache2 restart

apt-get update
echo "mysql-server mysql-server/root_password password password" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password password" | sudo debconf-set-selections
sudo sed -i 's/# DBPassword=/DBPassword=password/' /etc/zabbix/zabbix_server.conf
sudo sed -i '963i\date.timezone = "Europe/Paris"' /etc/php/7.4/cli/php.ini
sudo sed -i '963i\date.timezone = "Europe/Paris"' /etc/php/7.4/apache2/php.ini

        echo -e "${bleu}**************************** \\ Ajouter une base de donneés Zabbix à l'utilisateur zabbix (Mariadb) // **********************************"

#sudo mysql -u root -ppassword <<SQL_QUERY
#CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
#CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'password';
#GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
#SET GLOBAL log_bin_trust_function_creators = 1;
#SQL_QUERY
 
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql --default-character-set=utf8mb4 -h '${bdd}' -uzabbix -p'$passzabbix' zabbix

#        echo -e "${bleu}************************************************ \\ Configuration Mariadb-2 // *********************************************************"

#sudo mysql -u root -ppassword <<SQL_QUERY
#SET GLOBAL log_bin_trust_function_creators = 0;
#SQL_QUERY

        echo -e "${bleu}*************************************************** \\ Configuration-Gui-zabbix // *****************************************************"

sudo touch /etc/zabbix/web/zabbix.conf.php
sudo chmod 777 /etc/zabbix/web/zabbix.conf.php
sudo cat <<"EOF" > /etc/zabbix/web/zabbix.conf.php
<?php
$ZBX_LANG = 'fr_FR
    b. Install Zabbix server, frontend, agent
    # apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
    c. Create initial database
    Documentation

    Make sure you have database server up and running.

    Run the following on your database host.
    # mysql -uroot -p
    password
    mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;
    mysql> create user zabbix@localhost identified by 'password';
    mysql> grant all privileges on zabbix.* to zabbix@localhost;
    mysql> set global log_bin_trust_function_creators = 1;
    mysql> quit;

    On Zabbix server host import initial schema and data. You will be prompted to enter your newly created password.
    # zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

    Disable log_bin_trust_function_creators option after importing database schema.
    # mysql -uroot -p
    password
    mysql> set global log_bin_trust_function_creators = 0;
    mysql> quit;
    d. Configure the database for Zabbix server

    Edit file /etc/zabbix/zabbix_server.conf
    DBPassword=password
    e. Start Zabbix server and agent processes

    Start Zabbix server and agent processes and make it start at system boot.
    # systemctl restart zabbix-server zabbix-agent apache2
    # systemctl enable zabbix-server zabbix-agent apache2
    f. Open Zabbix UI web page

    The default URL for Zabbix UI when using Apache web server is http://host/zabbix
    Start using Zabbix

    Read in documentation: Quickstart guide
    Zabbix Server Installation
    Zabbix server installation explained
    Zabbix basic concepts
    Zabbix basic concepts
    Zabbix basic concepts
    Zabbix basic concepts, part II

Need help from Zabbix team?

    Consulting

    Get assistance in better understanding the benefits and potential from using Zabbix
    Technical Support

    Get access to the team of Zabbix experts that know every little bit of the source code
    Training

    Get theoretical and practical knowledge in 5 days in many local languages

    USA
    Europe
    Japan
    China
    Argentina
    Brazil
    Chile
    Colombia
    Mexico

USA
    +1 877-4-ZABBIX	

Europe
    +371 6778-4742	

Japan
    +81 3-4405-7338	

China
    +86 021-6978-6188

Argentina
    +54 11 3989-4060

Brazil
    +55 11 4210-5104

Chile
    +56 44 890 9410	

Colombia
    +57 1 3819310	

Mexico
    +52 55 8526 2606	

Find local partner
Contact us

';
// Zabbix GUI configuration file.
$DB['TYPE']                     = 'MYSQL';
$DB['SERVER']                   = '${db}';
$DB['PORT']                     = '0';
$DB['DATABASE']                 = 'zabbix';
$DB['USER']                     = 'zabbix';
$DB['PASSWORD']                 = 'passzabbix';
// Schema name. Used for PostgreSQL.
$DB['SCHEMA']                   = '';
// Used TLS connection.
$DB['ENCRYPTION']               = false;
$DB['KEY_FILE']                 = '';
$DB['CERT_FILE']                = '';
$DB['CA_FILE']                  = '';
$DB['VERIFY_HOST']              = false;
$DB['CIPHER_LIST']              = '';
// Use IEEE754 compatible value range 64-bit Numeric
$DB['VAULT']                    = '';
$DB['VAULT_URL']                = '';
$DB['VAULT_DB_PATH']            = '';
$DB['VAULT_TOKEN']              = '';
$DB['VAULT_CERT_FILE']          = '';
$DB['VAULT_KEY_FILE']           = '';
$DB['DOUBLE_IEEE754']           = true;
// PHP Time zone
$PHP_TZ = 'Europe/Paris';
// User  webserver
$ZBX_WEB_USER = 'www-data';
// nom de la base Zabbix hostname/IP
$ZBX_SERVER_NAME                = 'supervision_zabbix';
// Identifiant par defaut de Zabbix
$ZBX_USER = 'Admin';
$ZBX_PASSWORD = 'zabbix';
$IMAGE_FORMAT_DEFAULT   = IMAGE_FORMAT_PNG;
EOF

sudo chmod 600 /etc/zabbix/web/zabbix.conf.php
sudo chown www-data:www-data /etc/zabbix/web/zabbix.conf.php

        echo -e "${bleu}*********************************************** \\ Redemarre tout les services // ******************************************************"
sudo service apache2 restart
sudo service mariadb restart
sudo service zabbix-server restart
sudo service zabbix-agent restart
sudo systemctl enable zabbix-server zabbix-agent apache2



