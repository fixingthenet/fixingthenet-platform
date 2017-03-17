bash 'rancher-cli download' do
  code <<-EOH
     wget  https://github.com/rancher/cli/releases/download/v0.4.1/rancher-linux-amd64-v0.4.1.tar.gz
     tar xvf rancher-linux-amd64-v0.4.1.tar.gz
     rm rancher-linux-amd64-v0.4.1.tar.gz
     mv rancher-v0.4.1/rancher /usr/local/bin/rancher
     rm -rf rancher-v0.4.1
  EOH
  action :run
  not_if { ::File.exists?('/usr/local/bin/rancher')}
end

                                                    