# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'pathname'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"


BOX_NAME=ENV["BOX_NAME"] || "fxnet-dev"
BOX_IP=ENV["BOX_IP"] || '172.17.0.1'
BOX_IMAGE=ENV["BOX_IMAGE"] || "tknerr/baseimage-ubuntu:16.04"
PROJECT_DIR=Pathname.new(File.expand_path(File.join(__FILE__,'..')))
File.write(PROJECT_DIR.join("host","node","dev_project_base"),PROJECT_DIR)
puts "BOX_NAME: '#{BOX_NAME}' IMAGE: '#{BOX_IMAGE}' IP: '#{BOX_IP}'"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 config.vm.hostname = BOX_NAME
 config.vm.provider "docker" do |dckr|
   dckr.image = BOX_IMAGE
   dckr.has_ssh=true
   dckr.env={ }
   dckr.volumes=["/var/run/docker.sock:/var/run/docker.sock",
                 "#{PROJECT_DIR.join('host','node')}:/node"
                  ]
   dckr.name=BOX_NAME
 end

  config.omnibus.chef_version = '12.18.31'

  config.vm.provision :chef_solo do |chef|
    chef.log_level = :info #:debug
    chef.verbose_logging= true
    chef.cookbooks_path = ["cookbooks"]

    recipes=if ENV['ONLY_RECIPE'] #just used during development of recipes
              ENV["ONLY_RECIPE"].split(',')
            else
              ["dev::fix_tmp",
               "infra::update_packages",
               "infra::install_packages",
#               "dev::install_rbenv",
#               "dev::install_rubies",
               "fxn-docker::install",
               "infra::node",
               "fxn-rancher::server",
               "fxn-rancher::agent"
               #"fxn-rancher::server-setup"
              ]
            end
    recipes.each do |recipe|
      chef.add_recipe recipe
    end

    USER="vagrant"

    chef.json = {
      "ip" => BOX_IP,
      "infra" => {
        "packages" => ["joe"]
      },
      "fxn-docker" => {
        "version" => "17.06.2~ce-0~ubuntu",
        "distribution"=> "xenial",
        "options" => { "storage-driver" => "overlay", "storage-opts" => []}
      },

      "rbenv" => {
        "root" => "/home/#{USER}/.rbenv",
        "user" => USER,
        "group" => USER
      },
      "rubies" => {
        "user" => USER,
        "versions" => [
          {
            "ruby" => "2.4.1",
            "gem" => "2.7.2",
            "global" => true,
            "bundler" => "1.16.0"
          }
        ]
      },
      "fxn-rancher" => {
        "server" => {
#          "version" => "v2.0.0-alpha10", #not yet
          "version" => "v1.6.10",
          "url" => "http://#{BOX_IP}:8080",
          :auth => "key:secret",
          "project_id" => "1a5", #that's always the first project's id
          "registries" => [
          ],
          "catalogs" => [
#            "FXN=https://github.com/fixingthenet/fxnet-rancher-catalog.git"
          ]
        },
      }
    }
  end
end
