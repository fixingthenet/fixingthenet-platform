# -*- mode: ruby -*-
# vi: set ft=ruby :

FXN_BOX_IP=ENV["FXN_BOX_IP"] || "192.168.33.11"
FXN_BOX_HOSTNAME=ENV["FXN_BOX_HOSTNAME"] || "fxn-dev"
FXN_BOX_DISCSIZE=ENV["FXN_BOX_DISCSIZE"] || "50GB"
FXN_BOX_MEMORY=ENV["FXN_VM_MEMORY"] || 5800
FXN_BOX_CPU=ENV["FXN_BOX_CPU"] || 2

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = FXN_BOX_HOSTNAME
  config.vm.box = "bento/ubuntu-16.04"
  config.disksize.size=FXN_BOX_DISCSIZE
  config.vm.box_check_update = false
  config.vm.network "private_network", ip: FXN_BOX_IP

  config.vm.synced_folder "config", "/config"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = FXN_BOX_MEMORY
    vb.cpus = FXN_BOX_CPU
  end

  config.omnibus.chef_version = '12.18.31'

  config.vm.provision :chef_solo do |chef|
    chef.log_level = :info #:debug
    chef.verbose_logging= true
    chef.cookbooks_path = ["cookbooks"]

    if ENV['ONLY_RECIPE'] #just used during development of recipes
      ENV["ONLY_RECIPE"].split(',').each do |recipe|
        chef.add_recipe recipe
      end
    else
      chef.add_recipe "fxn-docker::install"
      chef.add_recipe "fxn-docker::vagrant-user"
      chef.add_recipe "fxn-rancher::server"
      chef.add_recipe "fxn-rancher::server-setup"

      chef.add_recipe "fxn-rancher::agent"
      chef.add_recipe "fxn-rancher::cli"
    end

    USER="vagrant"

    chef.json = {
        "fxn-docker" => {
          "version" => "17.03.0~ce-0~ubuntu-xenial", 
          "distribution"=> "ubuntu-xenial",
          "options" => { "storage-driver" => "overlay", "storage-opts" => [] }
        },
        
        "fxn-rancher" => {
          "server" => {
           "version" => "1.5.1",
           "url" => "http://#{FXN_BOX_IP}:8080",
           :auth => "key:secret",
           "project_id" => "1a5", #that's always the first project's id
           "registries" => [],
           "catalogs" => []
          },
        }
    }
  end
end
