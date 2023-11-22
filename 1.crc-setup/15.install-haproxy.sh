#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

#Checking if running as root
if [[ "$(whoami)" == "root" ]]; then
    echo "Those scripts can not be run as root!"
    exit
fi

set -x
sudo yum install -y haproxy
sudo systemctl enable haproxy
sudo firewall-cmd --add-port=80/tcp --permanent
sudo firewall-cmd --add-port=6443/tcp --permanent
sudo firewall-cmd --add-port=443/tcp --permanent
sudo firewall-cmd --add-port=9000/tcp --permanent
sudo firewall-cmd --zone libvirt --add-port=80/tcp --permanent
sudo firewall-cmd --zone libvirt --add-port=443/tcp --permanent
sudo firewall-cmd --zone libvirt --add-port=6443/tcp --permanent
sudo systemctl restart firewalld
sudo semanage port -a -t http_port_t -p tcp 6443

sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.$(date "+%Y-%m-%d_%H-%M-%S").bak
CRC_IP_INTERNAL=$(crc ip)
sudo cp ./haproxy/haproxy.cfg /tmp/haproxy.cfg
sudo sed -i "s/SERVER_IP/$CRC_IP/g" /tmp/haproxy.cfg
sudo sed -i "s/CRC_IP/$CRC_IP_INTERNAL/g" /tmp/haproxy.cfg
sudo mv /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg

#sudo semanage permissive -a haproxy_t
sudo semanage fcontext -a -t haproxy_exec_t /etc/haproxy/haproxy.cfg
sudo restorecon -v /etc/haproxy/haproxy.cfg

sudo systemctl restart haproxy
set +x
