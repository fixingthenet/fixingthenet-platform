bash 'install cuda repo' do
  cwd '/opt'
  code <<-EOH
    wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.44-1_amd64.deb
    dpkg -i cuda-repo-ubuntu1604_8.0.44-1_amd64.deb
    echo "cuda-repo-ubuntu1604 hold"  | dpkg --set-selections
    apt-get update -y
  EOH
  not_if { ::File.exists?("/opt/cuda-repo-ubuntu1404_6.5-14_amd64.deb") }
end


#directory '/usr/lib/nvidia' do
#end

%w(linux-image-extra-virtual linux-source xserver-xorg-video-dummy nvidia-340 nvidia-modprobe ).each do |pkg|
  package pkg do
  end
end


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
    wget https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.0/nvidia-docker_1.0.0-1_amd64.deb
    dpkg -i nvidia-docker*.deb

  EOH
  not_if { ::File.exists?("/opt/nvidia-docker_1.0.0-1_amd64.deb") }
end

bash 'run a cuda container with nvidia-docker' do
  code "nvidia-docker run  -d --restart=unless-stopped --name nvidia-keepit nvidia/cuda:6.5-runtime  nc -l 4000"
  not_if 'docker ps | grep nvidia-keepit'
end

# to test it:
bash 'run a speed test' do
  code "nvidia-docker run nvidia/cuda:6.5-runtime nvidia-smi > /tmp/cuda_speed.txt"
end
