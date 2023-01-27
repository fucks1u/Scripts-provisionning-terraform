   # A exécuter sur zab
echo "*************** ce provision execute sur zab***********************************"
    set -ex
    apt-get update
    apt-get -y install apache2 php php-mysql php-mysqlnd php-ldap php-bcmath php-mbstring php-gd php-pdo php-xml libapache2-mod-php
    apt-get -y install mariadb-server mariadb-client curl

echo "***************************************Zabbix***************************************************"
   wget https://repo.zabbix.com/zabbix/6.2/debian/pool/main/z/zabbix-release/zabbix-release_6.2-4%2Bdebian11_all.deb
   dpkg -i zabbix-release_6.2-4+debian11_all.deb
   apt-get update
   apt-get -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
   apt-get -y install locales-all
   locale-gen en_US.UTF-8
   update-locale LANG=en_US.UTF-8
   service apache2 restart

  apt-get update
  echo "mysql-server mysql-server/root_password password password" | debconf-set-selections
  echo "mysql-server mysql-server/root_password_again password password" | debconf-set-selections
  sed -i 's/# DBPassword=/DBPassword=password/' /etc/zabbix/zabbix_server.conf
  sed -i '963i\date.timezone = "Europe/Paris"' /etc/php/7.4/cli/php.ini
  sed -i '963i\date.timezone = "Europe/Paris"' /etc/php/7.4/apache2/php.ini

echo "************************* Ajouter une base de donneés Zabbix à l utilisatuer zabbix (Mariadb) ********************************"
  mysql -u root -ppassword <<SQL_QUERY
  CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
  CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'password';
  GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
  SET GLOBAL log_bin_trust_function_creators = 1;
  SQL_QUERY

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -ppassword zabbix

    echo "***************************************Mariadb-2*******************************************"
mysql -u root -ppassword <<SQL_QUERY
SET GLOBAL log_bin_trust_function_creators = 0;
SQL_QUERY

   echo "******************************************Configuration-Gui-zabbix******************************"

   cat <<"EOF" > /etc/zabbix/web/zabbix.conf.php
<?php
$ZBX_LANG = 'fr_FR';
// Zabbix GUI configuration file.
$DB['TYPE']                     = 'MYSQL';
$DB['SERVER']                   = 'localhost';
$DB['PORT']                     = '0';
$DB['DATABASE']                 = 'zabbix';
$DB['USER']                     = 'zabbix';
$DB['PASSWORD']                 = 'password';
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

chmod 600 /etc/zabbix/web/zabbix.conf.php
chown www-data:www-data /etc/zabbix/web/zabbix.conf.php

    echo "***************************************Restart-zabbix*******************************************"
    service apache2 restart
    service mariadb restart
    service zabbix-server restart
    service zabbix-agent restart
    systemctl enable zabbix-server zabbix-agent apach
