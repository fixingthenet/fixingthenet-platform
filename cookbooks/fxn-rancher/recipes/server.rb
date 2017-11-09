bash 'install rancher server start' do
  sdc=(node["fxn-rancher"]["server"]["db"] rescue nil)
  server_env=[]
  if sdc
    server_env << "--db-host #{sdc["host"]}"
    server_env << "--db-name #{sdc["name"]}"
    server_env << "--db-user #{sdc["user"]}"
    server_env << "--db-pass #{sdc["pass"]}"
    server_env << "--db-port #{sdc["port"]}"
  end
  
  #awsopsworks chef 12 support
  instance = (search("aws_opsworks_instance", "self:true").first rescue nil) #for local installs
  if instance
    server_env << "--advertise-address #{instance['private_ip']}"
  end
  
  code <<-EOH
    sudo docker run -d --restart=unless-stopped -p 9345:9345 -p 8080:8080 rancher/server:#{node["fxn-rancher"]["server"]["version"]}  #{server_env.join(" ")} 
  EOH
  action :run
  not_if "docker ps -a | grep rancher/server"
end
