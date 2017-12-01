bash "install docker-compose" do
  dc_version=node["fxn-docker"]["docker_compose"]["version"]
  code "curl -L https://github.com/docker/compose/releases/download/#{dc_version}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && " \
       "chmod +x /usr/local/bin/docker-compose"
  not_if "docker-compose -v | grep #{dc_version}"
end
