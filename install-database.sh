#!/bin/bash

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

#Mot de passe :
passwp="passwp"
passmdb="passmdb"
passzabbix="passzabbix"

ipzab="34.107.0.74"
ipwp="35.198.102.242"

set -ex
sudo apt-get update

    echo "******************** 1.  Installation des paquets MariaDB  ***************"

sudo apt-get -y install mariadb-server mariadb-client curl wget

    echo "Creation de la base de donnee WordPress et son utilisateur"

sudo mysql -uroot -e "CREATE DATABASE wpdata CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
sudo mysql -uroot -e "CREATE USER wpuser@'${ipwp}' IDENTIFIED BY '${passwp}';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON wpdata.* TO 'wpuser'@'${ipwp}';"
sudo mysql -uroot -e "FLUSH PRIVILEGES;"

    echo "Creation de la base de donnee Zabbix et son utilisateur"

sudo mysql -uroot -e "CREATE DATABASE zabbix DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
sudo mysql -uroot -e "CREATE USER 'zabbix'@'${ipzab}' IDENTIFIED BY '${passzabbix}';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'${ipzab}';"
sudo mysql -uroot -e "FLUSH PRIVILEGES;"
sudo mysql -uroot -e "SET GLOBAL log_bin_trust_function_creators = 1;"

    echo "Modification de l'acces a distance du serveur MariaDB"

sed -i 's/^bind-address.*/bind-address = */' /etc/mysql/mariadb.conf.d/50-server.cnf


    echo "Telechargement des donnees necessaires a Zabbix"

#zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p$p>
sudo mysql -uroot -e "SET GLOBAL log_bin_trust_function_creators = 0;"

    echo "******************** 3. Securiser la base de donnée MariaDB  *********************"

mysql_secure_installation <<EOF
y
#Switch to unix_socket authentication
n
#Change the root password
y
$passmdb
$passmdb
#Remove anonymous users?
y
#Disallow root login remotely?
y
#Remove test database and access to it?
y
# Reload privilege tables now?
y
EOF


# a mettre sur la machine hebergant zabbix
#zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p$passzabbix zabbix

sudo mysql -uroot -e "SET GLOBAL log_bin_trust_function_creators = 0;"


    echo "************************* 9. Redemarre les services ********************************"

sudo service mariadb restart


trap : 0

echo -e >&2 "${green}
**********************************************************
************* INSTALLATION DONE SUCCESSFULLY *************
**********************************************************
"
