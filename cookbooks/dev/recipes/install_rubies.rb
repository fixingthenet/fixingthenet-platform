%w(build-essential libssl-dev libreadline-dev zlib1g-dev bzip2).each do |pkg|
  package pkg
end

Chef::Resource::Bash.send(:include, ::AsUser)

#bash "installing mri  2.1.5" do
#  code as_user(node.devenv.user,'rbenv install 2.1.5')
#  not_if as_user(node.devenv.user,'rbenv versions | grep "2.1.5"')
#  action :run
#end
node["rubies"]["versions"].each do |version|
  bash "installing ruby: #{version["ruby"]} for user #{node["rubies"]["user"]}" do
    code as_user(node["rubies"]["user"],"rbenv install #{version["ruby"]}")
    not_if as_user(node["rubies"]["user"],"rbenv versions | grep '#{version["ruby"]}'")
    action :run
  end
  if version["global"]
    bash "set global: #{version["ruby"]}" do
      code as_user(node["rubies"]["user"], "rbenv global  #{version["ruby"]}")
      action :run
    end
  end  
  bash "installing rubygem: #{version["gem"]}" do
    code as_user(node["rubies"]["user"], "rbenv shell #{version["ruby"]} && gem update --system '#{version["gem"]}' && rbenv rehash")
    action :run
  end  
  bash "installing bundler: #{version["bundler"]}" do
    code as_user(node["rubies"]["user"], "rbenv shell #{version["ruby"]} && gem install bundler --force -v #{version["bundler"]}")
    action :run
  end
end
