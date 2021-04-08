# -*- mode: ruby -*-
# vi: set ft=ruby :

$install_python = <<-SCRIPT
yum install -y python
SCRIPT

$install_bind_utils = <<-SCRIPT
sudo yum install -y bind-utils
SCRIPT

$install_ansible = <<-SCRIPT
yum install -y epel-release
yum install -y ansible
SCRIPT

$copy_sshd_config = <<-SCRIPT
mv /tmp/sshd_config /etc/ssh/sshd_config
systemctl restart sshd
SCRIPT

$configure_ssh = <<-SCRIPT
ssh-keygen -t rsa -q -f "/tmp/id_rsa" -N ""
ssh-keygen -R 192.168.33.12
ssh-keygen -R 192.168.33.13
ssh-keyscan -t rsa -H 192.168.33.12 >> /home/vagrant/.ssh/known_hosts
ssh-keyscan -t rsa -H 192.168.33.13 >> /home/vagrant/.ssh/known_hosts
mv /tmp/id_rsa /home/vagrant/.ssh/id_rsa
mv /tmp/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub
sudo chown vagrant:vagrant /home/vagrant/.ssh/id_rsa
sudo chown vagrant:vagrant /home/vagrant/.ssh/id_rsa.pub
sudo chown vagrant:vagrant /home/vagrant/.ssh/known_hosts
SCRIPT

$copy_ssh_keys = <<-SCRIPT
sshpass -p 'vagrant' ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub vagrant@192.168.33.12
sshpass -p 'vagrant' ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub vagrant@192.168.33.13
SCRIPT

$install_consul = <<-SCRIPT
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum install -y consul
SCRIPT

$install_consul_template = <<-SCRIPT
mkdir bin
cd bin
tar -zxvf /vagrant/consul-template_0.25.2_linux_386.tgz 
SCRIPT

$register_web_service = <<-SCRIPT
cp -v /tmp/beer.json /etc/consul.d/beer.json
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.define "managed-node2" do |centos7|
    centos7.vm.box = "centos/7"
    centos7.vm.hostname = "managed-node2"
    centos7.vm.network "private_network", ip: "192.168.33.13"

    centos7.vm.provision "file", source: "./etc/ssh/sshd_config", destination: "/tmp/sshd_config"
    centos7.vm.provision "shell", inline: $copy_sshd_config
    centos7.vm.provision "shell", inline: $install_python
    centos7.vm.provision "shell", inline: $install_consul
    centos7.vm.provision "shell", inline: $install_bind_utils
    centos7.vm.provision "file", source: "./etc/consul.d/beer.json", destination: "/tmp/beer.json"
    centos7.vm.provision "shell", inline: $register_web_service
  end

  config.vm.define "managed-node1" do |centos7|
    centos7.vm.box = "centos/7"
    centos7.vm.hostname = "managed-node1"
    centos7.vm.network "private_network", ip: "192.168.33.12"

    centos7.vm.provision "file", source: "./etc/ssh/sshd_config", destination: "/tmp/sshd_config"
    centos7.vm.provision "shell", inline: $copy_sshd_config
    centos7.vm.provision "shell", inline: $install_python
    centos7.vm.provision "shell", inline: $install_consul
    centos7.vm.provision "shell", inline: $install_bind_utils
    centos7.vm.provision "file", source: "./etc/consul.d/beer.json", destination: "/tmp/beer.json"
    centos7.vm.provision "shell", inline: $register_web_service
  end

  config.vm.define "control-node" do |centos7|
    centos7.vm.box = "centos/7"
    centos7.vm.hostname = "control-node"
    centos7.vm.network "private_network", ip: "192.168.33.11"

    centos7.vm.provision "shell", inline: $install_ansible
    centos7.vm.provision "shell", inline: $configure_ssh
    centos7.vm.provision "shell", privileged: false, inline: $copy_ssh_keys
    centos7.vm.provision "shell", inline: $install_consul
    centos7.vm.provision "shell", inline: $install_bind_utils
    centos7.vm.provision "shell", privileged: false, inline: $install_consul_template
  end
end
