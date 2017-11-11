#!/bin/bash

sudo apt install docker-ce=17.06.2~ce-0~ubuntu
sudo bash -c "echo '{ \"storage-driver\": \"overlay\", \"storage-opts\": [] }' > /etc/docker/daemon.json"
sudo service docker restart
vagrant plugin install vagrant-omnibus
vagrant up --provider=docker



