#https://docs.docker.com/engine/installation/linux/ubuntulinux/




%w(apt-transport-https ca-certificates).each do |pname|
  apt_package pname do
    action :install
  end
end

#TODO: linux-image-extra-*  on real servers!!!

apt_repository 'docker' do
  uri 'https://apt.dockerproject.org/repo'
  keyserver 'hkp://p80.pool.sks-keyservers.net:80'
  key '58118E89F3A912897C070ADBF76221572C52609D'
  components ['main']
  distribution node['fxn-docker'][:distribution]
  action :add
end

if node['fxn-docker'][:options] 
  directory '/etc/docker' do
  end
  
  template "/etc/docker/daemon.json" do
    source 'daemon.json.erb'
    variables :options => node['fxn-docker'][:options]
  end  
end

#https://apt.dockerproject.org/repo/pool/main/d/docker-engine/docker-engine_1.9.1-0~trusty_amd64.deb 

apt_package 'docker-engine' do
  version "#{node['fxn-docker'][:version]}"
  options "--force-yes"
  action :install
end


