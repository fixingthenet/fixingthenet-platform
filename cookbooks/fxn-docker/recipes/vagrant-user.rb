bash 'add vagrant to docker group' do
  code "sudo usermod -a -G docker vagrant"
  action :run
  not_if "grep docker /etc/group | grep vagrant"
end
