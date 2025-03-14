# Guacamole podman
```shell
guacamolepodname="guacamole"
guacamolelocalpath="/rpool/podman/store/guacamole"
guacamolemysqldb="guacamoledb"
guacamolemysqluser="guacamoleuser"
guacamolemysqlpass="RandomPass"

podman pod create \
  --name $guacamolepodname \
  -p 8080:8080
  
# папка в которой будут искать скрипты для инициализации
mkdir -p "$guacamolelocalpath/db/docker-entrypoint-initdb.d"
#01_initdb.sql
echo "CREATE USER '$guacamolemysqluser'@'127.0.0.1' IDENTIFIED BY '$guacamolemysqlpass';" > $guacamolelocalpath/db/docker-entrypoint-initdb.d/01_initdb.sql
echo "CREATE DATABASE $guacamolemysqldb;" >> $guacamolelocalpath/db/docker-entrypoint-initdb.d/01_initdb.sql
echo "GRANT ALL PRIVILEGES ON $guacamolemysqldb.* TO '$guacamolemysqluser'@'127.0.0.1';" >> $guacamolelocalpath/db/docker-entrypoint-initdb.d/01_initdb.sql
#02_initdb.sql
echo "USE $guacamolemysqldb;" > $guacamolelocalpath/db/docker-entrypoint-initdb.d/02_initdb.sql
podman run --rm docker.io/guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql >> $guacamolelocalpath/db/docker-entrypoint-initdb.d/02_initdb.sql

#run db container
mkdir $guacamolelocalpath/db/data
podman run -d \
  --name=${guacamolepodname}-mysql \
  --pod=${guacamolepodname} \
  -e MARIADB_ROOT_PASSWORD=$guacamolemysqlpass \
  -v $guacamolelocalpath/db/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d \
  -v $guacamolelocalpath/db/data:/var/lib/mysql \
  docker.io/mariadb:latest
#run guacd
podman run -d \
  --name=${guacamolepodname}-guacd \
  --pod=${guacamolepodname} \
  docker.io/guacamole/guacd
#run guacamole tomcat
podman run -d \
  --name=${guacamolepodname}-tomcat \
  --pod=${guacamolepodname} \
  -e MYSQL_HOSTNAME=127.0.0.1 \
  -e MYSQL_PORT=3306 \
  -e MYSQL_DATABASE=$guacamolemysqldb \
  -e MYSQL_USER=$guacamolemysqluser \
  -e MYSQL_PASSWORD=$guacamolemysqlpass \
  -e GUACD_HOSTNAME=127.0.0.1 \
  -e GUACD_PORT=4822 \
  docker.io/guacamole/guacamole

cd /etc/systemd/system
podman generate systemd --files --name ${guacamolepodname}
systemctl daemon-reload
systemctl enable pod-${guacamolepodname}
systemctl stop pod-${guacamolepodname}
systemctl start pod-${guacamolepodname}
```
