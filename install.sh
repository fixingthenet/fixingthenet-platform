#!/bin/bash

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"
     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     $( cd -P "$( dirname "$SOURCE" )" )
     pwd
}

VAGRANT_DIR=$(get_script_dir)
cd $VAGRANT_DIR

if [ ! -d developer ]; then
  mkdir developer
fi

sudo apt install docker-ce=17.06.2~ce-0~ubuntu
sudo bash -c "echo '{ \"storage-driver\": \"overlay\", \"storage-opts\": [] }' > /etc/docker/daemon.json"
sudo service docker restart

omnibus_installed=`vagrant plugin list | grep omnibus`
if [[ $omnibus_installed == '' ]]; then
  vagrant plugin install vagrant-omnibus
fi

vagrant up --provider=docker



