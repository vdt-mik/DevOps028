# -*- mode: ruby -*-
# vi: set ft=ruby :
#, privileged: false
$set_environment_variables = <<SCRIPT
tee "/etc/profile.d/myvars.sh" > "/dev/null" <<EOF
# AWS environment variables.
export AWS_ACCESS_KEY_ID=#{ENV['AWS_ACCESS_KEY_ID']}
export AWS_SECRET_ACCESS_KEY=#{ENV['AWS_SECRET_ACCESS_KEY']}
export AWS_DEFAULT_REGION=#{ENV['AWS_DEFAULT_REGION']}
export AWS_DEFAULT_OUTPUT=#{ENV['AWS_DEFAULT_OUTPUT']}
export DB_USER=#{ENV['DB_USER']}
export DB_PASS=#{ENV['DB_PASS']}
export DB_INST_NAME=#{ENV['DB_INST_NAME']}
export DB_NAME=#{ENV['DB_NAME']}
EOF
SCRIPT
Vagrant.configure("2") do |config|
  config.vm.define :build_node do |build_node_config|
    build_node_config.vm.box = "centos/7"
    build_node_config.vm.network "private_network", ip: "10.0.0.12"
    build_node_config.vm.provider "virtualbox" do |vbox|
      vbox.memory = 512
      vbox.cpus = 1
    end
    build_node_config.vm.hostname = "build.node.int"
#    build_node_config.vm.synced_folder "./tmp", "/home/builder/build", type: "rsync"
    build_node_config.vm.provision :shell, inline: $set_environment_variables, run: "always"
    build_node_config.vm.provision :shell, :path => "provision_build_node.sh"
  end
  config.vm.define :app_node do |app_node_config|
    app_node_config.vm.box = "centos/7"
    app_node_config.vm.network "forwarded_port", guest:9000, host:9000
    app_node_config.vm.network "private_network", ip: "10.0.0.13"
    app_node_config.vm.provider "virtualbox" do |vbox|
      vbox.memory = 512
      vbox.cpus = 1
    end
    app_node_config.vm.hostname = "app.node.int"
#    app_node_config.vm.synced_folder "./app", "/opt/app", type: "rsync"
    app_node_config.vm.provision :shell, inline: $set_environment_variables, run: "always"
    app_node_config.vm.provision :shell, :path => "provision_app_node_v1.sh"
  end
end
