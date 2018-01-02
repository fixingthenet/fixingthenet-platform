# fxnet-platform

Sets up a dev environment for Fixingthenet microservices.

# Setup
Setting up a development environment is easy:
 * install docker 
 * install vagrant
 * make sure your uid is 1000 !
 * checkout this repo and run ```install.sh && vagrant up  -provider=docker```


Done. 

Visit http://172.17.0.1:8080/

# Preparing platform

```vagrant ssh``` into the vm.

Let's start with the standard dev setup. It runs the dev-fixingthe.net
domain and is a good start for your first steps:

Prepare the code base

```
cd /vagrant/code
git clone "the catalog"
```

Prepare the cli
```
fxnet init (TBD)
```

this creates  ~/.fxnet/config.rb you should alwas have a backup or move it
to /vagrant and just create a link at ~/.fxnet/config.rb to this file:

```
mv ~/.fxnet /vagrant/developer/fxnet
ln -s /vagrant/developer/fxnet ~/.fxnet
```

Now let's deploy the basic stacks:
```
fxnet -e dev deploy --confirm dev-central 
fxnet -e dev deploy --confirm fxnetfxnet-auth

TBD ...
```






