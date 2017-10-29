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

ruby_block 'check if server is up' do
  block do
    endpoint=node["fxn-rancher"]["server"]["url"]
    auth=node["fxn-rancher"]["server"]["auth"]
    Chef::Log.info("Waiting for Rancher server to come online...")
    sleep_counter = 0
    valid_json = false
    begin
      sleep 1
      sleep_counter = sleep_counter +1
      cmd="curl -s -u #{auth} -X GET #{endpoint}/v3/projects"
      Chef::Log.info(cmd)
      project_json = `#{cmd}`
      Chef::Log.info("got #{project_json}")
      begin
        parsed_project_json=JSON.parse(project_json)
        valid_json = true
        valid_json = false if parsed_project_json["type"] == "error" #not good as it's valid but we got an error
      rescue JSON::ParserError => e
        valid_json = false
      end
      break if sleep_counter == 150
    end until valid_json
    raise "Rancher server not running" if !valid_json
  end
end
