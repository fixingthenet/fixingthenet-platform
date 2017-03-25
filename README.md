# fxnet-platform

Sets up a dev environment for Fixingthenet microservices.

# Setup
Setting up a development environment is easy:
 * install virtualbox 5.1
 * install vagrant
 * checkout this repo and run ```vagrant up```

Done. 

Visit http://192.168.33.11:8080/env/1a5/catalog?catalogId=FXN install the
following services:
 * postgreslq 9.4
 * FXN auth

# Developing the platform

```vagrant ssh``` into the vm.

In the vm:

```
cd /vagrant/code
git clone ...the app you want to develop...
TBD: restart the service you want to develop with /code mounted on the repo
TBD: develop your app

# Problems

 * adding gems
 * 



```