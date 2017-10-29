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
      cmd="curl -s -u #{auth} -X GET #{endpoint}/v3/clusters"
      Chef::Log.info(cmd)
      json = `#{cmd}`
      Chef::Log.info("got #{json}")
      begin
        parsed_json=JSON.parse(json)
        valid_json = true
        valid_json = false if parsed_json["type"] == "error" #not good as it's valid but we got an error
      rescue JSON::ParserError => e
        valid_json = false
      end
      break if sleep_counter == 150
    end until valid_json
    raise "Rancher server not running" if !valid_json
	  cluster_id = parsed_json["data"][0]["id"]

	  cluster_json = `curl -s -u #{auth} #{endpoint}/v3/clusters/#{cluster_id}`
	  cluster_json = JSON.parse(cluster_json)
	  Chef::Log.info("got: #{cluster_json}")

	  command = cluster_json["registrationToken"]["hostCommand"]
    Chef::Log.info("got registration: #{command}")

	  Chef::Log.info "Installing Agent with: #{command}"
	  `#{command}`
  end
  action :run
end
