#!/bin/sh

# Installing Keepalived and HAProxy service on loadbalancer machines.
echo "Installing Keepalived and HAProxy"
yum install -y keepalived haproxy 

# Configuring Keepalived and HAProxy on loadbalancer machines.
echo -e "Configuring KeepAlived\n"
echo "Crating Keepaplived Check-Server Script"
cat >> /etc/keepalived/check_apiserver.sh <<EOF
#!/bin/sh

errorExit() {
  echo "*** $@" 1>&2
  exit 1
}

curl --silent --max-time 2 --insecure https://localhost:6443/ -o /dev/null || errorExit "Error GET https://localhost:6443/"
if ip addr | grep -q 192.168.5.10; then
  curl --silent --max-time 2 --insecure https://192.168.5.10:6443/ -o /dev/null || errorExit "Error GET https://192.168.5.10:6443/"
fi
EOF
chmod +x /etc/keepalived/check_apiserver.sh

echo "Setting KeepAlived configuration"
cp /etc/keepalived/keepalived.conf  /etc/keepalived/keepalived.conf_bkup
cat >> /etc/keepalived/keepalived.conf << EOF
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  timeout 10
  fall 5
  rise 2
  weight -2
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth1
    virtual_router_id 1
    priority 100
    advert_int 5
    authentication {
        auth_type PASS
        auth_pass mysecret
    }
    virtual_ipaddress {
        192.168.5.10
    }
    track_script {
        check_apiserver
    }
}
EOF
systemctl enable --now keepalived

###Configuring HA Proxy 
echo -e "Configuring HAProxy\n"
echo "Updating HAProxy config file"
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg_bkup
cat >> /etc/haproxy/haproxy.cfg << EOF
frontend kubernetes-frontend
  bind *:6443
  mode tcp
  option tcplog
  default_backend kubernetes-backend

backend kubernetes-backend
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance roundrobin
    server kmaster1 192.168.5.11:6443 check fall 3 rise 2
    server kmaster2 192.168.5.12:6443 check fall 3 rise 2
    server kmaster3 192.168.5.13:6443 check fall 3 rise 2
EOF
setsebool -P haproxy_connect_any=1
systemctl enable haproxy && systemctl restart haproxy