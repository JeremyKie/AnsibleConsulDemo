# Vagrant/Ansible/Consul Sandbox - README
Quick Vagrant Multi-Machine environment to experiment with Ansible and Consul

## Setup
```
% git clone git@github.com:JeremyKie/AnsibleConsulDemo.git

% cd AnsibleConsulDemo

% vagrant init

% mv Vagrantfile.rb Vagrantfile

% vagrant up
```

## Run Consul Agent on Control Node
Log onto _control-node_
```
% vagrant ssh control-node
```
From the _control-node_ VM
```
[vagrant] % sh /vagrant/scripts/run_agent_one.sh
```
Log onto _control-node_ in another terminal
```
% vagrant ssh control-node
```
Attempt to find the beer service
```
[vagrant] % digg @127.0.0.1 -p 8600 beer.service.consul

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.4 <<>> @127.0.0.1 -p 8600 beer.service.consul
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 53668
;; flags: qr aa rd; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;beer.service.consul.		IN	A

;; AUTHORITY SECTION:
consul.			0	IN	SOA	ns.consul. hostmaster.consul. 1617904258 3600 600 86400 0

;; Query time: 1 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Thu Apr 08 17:50:58 UTC 2021
;; MSG SIZE  rcvd: 98
```
The next step is to get Consul running on another node.

## Run Consul Agent on Managed Node 1
Log onto _managed-node1_ VM
```
% vagrant ssh managed-node1
```
From the _managed-node1_ VM
```
[vagrant] % sh /vagrant/scripts/run_agent_two.sh
```

## Join Managed Node 1 to Cluster
From the _managed-node1_ VM
```
[vagrant] % consul join 192.168.33.13
```
From the _control-node_ VM re-attempt to find the beer service
```
[vagrant] % digg @127.0.0.1 -p 8600 beer.service.consul

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.4 <<>> @127.0.0.1 -p 8600 beer.service.consul
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 48065
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;beer.service.consul.		IN	A

;; ANSWER SECTION:
beer.service.consul.	0	IN	A	192.168.33.12

;; Query time: 0 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Thu Apr 08 18:16:39 UTC 2021
;; MSG SIZE  rcvd: 64
```

## Run Consul Agent on Managed Node 2
Log onto _managed-node2_ VM
```
% vagrant ssh managed-node2
```
From the _managed-node2_ VM
```
[vagrant] % sh /vagrant/scripts/run_agent_three.sh
```
## Join Managed Node 2 to Cluster
From _managed-node2_ VM
```
[vagrant] % consul join 192.168.33.13
```
From the _control-node_ VM re-attempt to find the beer service
```
[vagrant] % digg @127.0.0.1 -p 8600 beer.service.consul

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.4 <<>> @127.0.0.1 -p 8600 beer.service.consul
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 32066
;; flags: qr aa rd; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;beer.service.consul.		IN	A

;; ANSWER SECTION:
beer.service.consul.	0	IN	A	192.168.33.12
beer.service.consul.	0	IN	A	192.168.33.13

;; Query time: 0 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Thu Apr 08 18:48:49 UTC 2021
;; MSG SIZE  rcvd: 80
```

## Use Anisble to ping managed nodes
From _control-node_ VM

```
[vagrant] % sh /vagrant/scripts/create_inventory.sh
[vagrant] % sh /vagrant/scripts/test.sh
192.168.33.12 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
192.168.33.13 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

## Clean Up
Log out of all your VM sessions
```
[vagrant] % logout
```
Shutdown all the VMs and reclaim resources
```
% vagrant halt && vagrant destroy -f
```
