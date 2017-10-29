package 'curl'

directory "/node"

ruby_block 'node setup' do
  block do
      instance = (search("aws_opsworks_instance", "self:true").first rescue nil) # nil in case of local install
      nodename=File.read("/etc/hostname").strip
      if instance
        public_ip=`curl -s -f http://169.254.169.254/latest/meta-data/public-ipv4`
        private_ip = instance['private_ip']
      else
        public_ip=node[:ip]
        private_ip=node[:ip]
      end
      File.write("/node/metric_url", "udp://#{private_ip}:5230") #deprecated
      File.write("/node/private_ip", private_ip)
      File.write("/node/public_ip", public_ip)
      File.write("/node/nodename", nodename )
metrics_config = <<EOF
{
  "endpoint": "udp://#{private_ip}:5232", 
  "telegraf_endpoint": "udp://#{private_ip}:5234", 
  "mdc": { 
     "@node_name": "#{nodename}" 
  }
}
EOF

      File.write("/node/metrics_config", metrics_config)
  end
end

bash "set max_map_count" do #remove as soon as ranch-cli can do sysctl!
  code <<-EOF
    echo "vm.max_map_count = 262144" > /etc/sysctl.d/50-elasticsearch.conf
    sysctl --system
    sysctl -p
  EOF
end
