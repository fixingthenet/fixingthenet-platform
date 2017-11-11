require 'json'

# node["fxn-rancher"]["server"]["url"] = http://<host>:<port>
# node["fxn-rancher"]["server"]["auth"]= <api_key>:<api_secret>
# the host labels are defined by opsworks.instance.layers (temporary solution)


ruby_block 'rancher agent setup' do
  block do
        endpoint=node["fxn-rancher"]["server"]["url"]
        auth=node["fxn-rancher"]["server"]["auth"]
        Chef::Log.info("Waiting for Rancher server to come online...")
        sleep_counter = 0
        valid_json = false
        begin
          sleep 1
          sleep_counter = sleep_counter +1
          Chef::Log.info(". (curl -s -u #{auth} -X GET #{endpoint}/v1/projects)")
          project_json = `curl -s -u #{auth} -X GET #{endpoint}/v1/projects`
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

        project_json = JSON.parse(project_json)

	project_id = project_json["data"][0]["id"]

	registration_token_json = `curl -s -u #{auth} --data "return_content=yes&projectId=#{project_id}" #{endpoint}/v1/registrationtokens`
	Chef::Log.info(%{curl -s -u #{auth} --data "return_content=yes&projectId=#{project_id}"})
	registration_token_json = JSON.parse(registration_token_json)
	Chef::Log.info("got: #{registration_token_json}")
	
	registration_token_id = registration_token_json["id"]
        Chef::Log.info("got registration: #{registration_token_json} #{registration_token_id}")
	state_json = {}
        
	loop do 
          sleep 10
	  state_json = `curl -s -u #{auth} -X GET #{endpoint}/v1/registrationtokens/#{registration_token_id}`
	  Chef::Log.info("curl -s -u #{auth} -X GET #{endpoint}/v1/registrationtokens/#{registration_token_id}")
	  Chef::Log.info("got state_json: #{state_json}")
	  state_json = JSON.parse(state_json)		
	  break if  state_json["state"] == "active"
	end
	
	command = state_json["command"]
        Chef::Log.info("command: #{command}")
	#command is sth like:
	# sudo docker run -e CATTLE_HOST_LABELS='com.metoda.host.network=public'  \
	# -d --privileged -v /var/run/docker.sock:/var/run/docker.sock \
	# -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.0.2 \
	# https://staging-rancher.metoda.com/v1/scripts/314204A689040E0A463E:1470304800000:brpkMGlsyWGsAD9dF3pyFS0Gm7c

        private_ip=File.read("/node/private_ip").strip
        agent_private_ip ="-e CATTLE_AGENT_IP=#{private_ip}"
        labels=[]
        joined_labels=''
#        labels = labels.push("io.rancher.host.external_dns_ip=#{public_ip}")
#        labels = labels.push("com.metoda.host.network=private")

    unless labels.empty?
      joined_labels="-e CATTLE_HOST_LABELS='#{labels.join("&")}'"
    end  
    command=command.gsub("--rm", %{--rm #{joined_labels} #{agent_private_ip}} )
    Chef::Log.info "Installing Agent with: #{command}"
    `#{command}` 
  end
  action :run
end
