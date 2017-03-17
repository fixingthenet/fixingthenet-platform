require 'json'

ruby_block 'setup Metoda catalogs in rancher' do 
	block do 
	        server_url=node['fxn-rancher'][:server][:url]
		settings_json = `curl -s -X GET #{server_url}/v1/settings`
		settings_json = JSON.parse(settings_json)

		activesetting_id = ''

		settings_json["data"].each do |setting|
		  if setting["name"] == "catalog.url"
		    activesetting_id = setting["id"]
		    break
		  end
		end

		catalogs = node['fxn-rancher'][:server]['catalogs']

		catalogs_string = ''
		catalogs.each do |catalog|
		   catalogs_string << ",#{catalog}"
		end

		#Adds default rancher catalog and catalogs specified in Vagrantfile
		
		     `curl -s --header "Content-Type:application/json" \
		 	--header "Accept: application/json" \
		 	--request PUT \
		 	--data '{"id":"#{activesetting_id}","type":"activeSetting","name":"catalog.url","activeValue":"library=https://github.com/rancher/rancher-catalog.git,community=https://github.com/rancher/community-catalog.git","inDb":true,"source":"Database","value":"library=https://github.com/rancher/rancher-catalog.git,community=https://github.com/rancher/community-catalog.git#{catalogs_string}"}' \
			 #{server_url}/v1/activesettings/#{activesetting_id}`

	end
	action :run
end

ruby_block 'setup registries in rancher' do
  block do
    server_url=node['fxn-rancher'][:server][:url]
    project_id=node['fxn-rancher'][:server][:project_id]
    node['fxn-rancher'][:server][:registries].each do |reg|
      url=reg[:url]
      #auth=reg[:auth] #TBD: how to set this?
      name=reg[:name]
      description=reg[:description]
      email=reg[:email]
                  
      settings_json = `curl -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' \
      -d '{"description":"#{description}", "name":"#{name}", "serverAddress":"#{url}"}' \
      '#{server_url}/v1/projects/#{project_id}/registries/'`
      settings_json = JSON.parse(settings_json)
      registry_id = settings_json["id"]
      `curl -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' \ 
      -d '{"description":"#{name} credentials", "publicValue":"#{name}", "registryId":"#{registry_id}", "email":"#{email}"}' \
      '#{server_url}/v1/projects/#{project_id}/registrycredentials'`
      end
  end
end
	