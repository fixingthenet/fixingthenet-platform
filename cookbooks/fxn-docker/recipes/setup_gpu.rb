bash 'install cuda repo' do
  cwd '/opt'
  code <<-EOH
    curl -L -s #{node[:docker][:gpu][:cuda_repo_package_url]} > cuda-repo-ubuntu.deb
    dpkg -i cuda-repo-ubuntu.deb
    echo "cuda-repo-ubuntu1604 hold"  | dpkg --set-selections
    apt-get update -y
  EOH
  not_if { ::File.exists?("/opt/cuda-repo-ubuntu.deb") }
end


#directory '/usr/lib/nvidia' do
#end

%w(linux-image-extra-virtual linux-source xserver-xorg-video-dummy ).each do |pkg|
  package pkg do
  end
end

# fail early until setting the link below work correctly
directory "/usr/lib/nvidia"

package node['fxn-docker'][:gpu][:nvidia_package] do
  version node['fxn-docker'][:gpu][:nvidia_package_version]
  action :install
end

package node['fxn-docker'][:gpu][:nvidia_package] do
  version node['fxn-docker'][:gpu][:nvidia_package_version]
  action :lock
end

package 'nvidia-modprobe'

bash 'load module' do
  code <<-EOH
    nvidia-modprobe -u -c=0
  EOH
  not_if 'lsmod | grep "nvidia_uvm"'
end

bash 'nvidia-docker' do
  #starting this docker container is essential to initialize the volume correctly
  cwd '/opt'
  code <<-EOH
    curl -L -s https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb > nvidia-docker.deb
    dpkg -i nvidia-docker.deb
  EOH
  not_if { ::File.exists?("/opt/nvidia-docker.deb") }
end

directory "/var/lib/nvidia-docker/volumes" do
  user "nvidia-docker"
  group "nvidia-docker"
  recursive true
end

bash 'run a cuda container with nvidia-docker' do
  code 'nvidia-docker run  -d --restart=unless-stopped --name nvidia-keepit nvidia/cuda:8.0-runtime /bin/bash -c "trap : TERM INT; sleep infinity & wait"'
  not_if 'docker ps -a | grep nvidia-keepit'
end

# to test it:
bash 'run a speed test' do
  code "nvidia-docker run nvidia/cuda:8.0-runtime nvidia-smi > /tmp/cuda_speed.txt"
end

link '/var/lib/nvidia-docker/volumes/375' do
  to "/var/lib/nvidia-docker/volumes/nvidia_driver/#{node['fxn-docker'][:gpu][:nvidia_volume_version]}"
end
