#https://docs.docker.com/engine/installation/linux/ubuntulinux/




%w(apt-transport-https ca-certificates).each do |pname|
  apt_package pname do
    action :install
  end
end

bash 'install repo key' do
  code <<-EOH
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  EOH
end

#TODO: linux-image-extra-*  on real servers!!!

apt_repository 'docker' do
  uri 'https://download.docker.com/linux/ubuntu'
  components ['stable']
  arch 'amd64'
  distribution node['fxn-docker'][:distribution]
  action :add
end

if node['fxn-docker'][:options] # on vagrant we use docker's default (datamapper + /dev/pool) , live it's overlay
  directory '/etc/docker' do
  end

  template "/etc/docker/daemon.json" do
    source 'daemon.json.erb'
    variables :options => node['fxn-docker'][:options]
  end
end

# look at https://apt.dockerproject.org/repo/pool/main/d/docker-engine/


apt_package 'docker-ce' do
  version "#{node['fxn-docker'][:version]}"
  options "--force-yes"
  action :install
end

if node['fxn-docker']["users"] && !node['fxn-docker']["users"].empty?
  node['fxn-docker']["users"].each do |user|
    bash 'add #{user} to docker group' do
      code "sudo usermod -a -G docker #{user}"
      action :run
      not_if "grep docker /etc/group | grep #{user}"
    end
  end
end
