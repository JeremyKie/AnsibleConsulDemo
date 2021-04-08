consul agent \
  -node=agent-three \
  -bind=192.168.33.13 \
  -enable-script-checks=true \
  -data-dir=/tmp/consul \
  -config-dir=/etc/consul.d
