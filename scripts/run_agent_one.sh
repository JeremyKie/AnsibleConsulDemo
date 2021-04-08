consul agent \
  -server \
  -bootstrap-expect=1 \
  -node=agent-one \
  -bind=192.168.33.11 \
  -data-dir=/tmp/consul \
  -config-dir=/etc/consul.d
