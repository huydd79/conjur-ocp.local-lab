#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

node_name=mysqldb
sudo podman ps -a | grep $node_name >/dev/null 2>&1
if [ $? -eq 1 ]; then
    echo "Container $node_name is not existed. Creating new one..."
else
    echo "Container $node_name existed. Deleting old one..."
    sudo podman stop $node_name
    sudo podman container rm $(sudo podman ps -a | grep $node_name | awk '{print $1}')
fi

#db_dir=/var/run/mysql/db
db_dir=$(pwd)/mysql/db
set -x
sudo mkdir -p $db_dir 
sudo cp ./mysql/world.sql.gz $db_dir
sudo gunzip $db_dir/world.sql.gz

sudo podman run --name $node_name -v $db_dir:/docker-entrypoint-initdb.d \
     -d --restart=always \
     -e MYSQL_ROOT_PASSWORD=Cyberark1 \
     -e MYSQL_DATABASE=world \
     -e MYSQL_USER=cityapp \
     -e MYSQL_PASSWORD=Cyberark1 \
     -p "3306:3306" -d docker.io/library/mysql:5.7.29

sudo -- sh -c "grep -v 'mysql.$LAB_DOMAIN' /etc/hosts > /tmp/hosts"
sudo -- sh -c "echo '$CONJUR_IP mysql.$LAB_DOMAIN' >> /tmp/hosts"
sudo -- sh -c "cp /etc/hosts /etc/hosts.bk"
sudo -- sh -c "cp /tmp/hosts /etc/hosts"

set +x

