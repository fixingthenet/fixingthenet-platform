# fxnet-platform

Sets up a dev environment for Fixingthenet microservices.

# Setup
Setting up a development environment is easy:
 * install docker 
 * install vagrant
 * checkout this repo and run ```install.sh && vagrant up```


Done. 

Visit http://172.17.0.1:8080/

# Developing the platform

```vagrant ssh``` into the vm.

In the vm:

```
cd /vagrant/code
git clone ...the app you want to develop...
TBD: restart the service you want to develop with /code mounted on the repo
TBD: develop your app
```






