consul agent \
  -node=agent-two \
  -bind=192.168.33.12 \
  -enable-script-checks=true \
  -data-dir=/tmp/consul \
  -config-dir=/etc/consul.d
