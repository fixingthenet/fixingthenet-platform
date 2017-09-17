
package 'git-core'

git 'rbenv' do
  destination node["rbenv"]["root"]
  repository 'https://github.com/sstephenson/rbenv.git'
  #revision "7e0e85bdda092d94aef0374af720682c6ea8999d"
  user node["rbenv"]["user"]
  group node["rbenv"]["group"]
  action :sync
end

%w(plugins downloads).each do |dir|
  directory "#{node["rbenv"]["root"]}/#{dir}" do
    action :create
    owner node["rbenv"]["user"]
    group node["rbenv"]["group"]
    mode 00775
  end
end

# TODO: this should be config!
plugins=[ 
 { "name" => "ruby-build",
   "repo" => 'git://github.com/sstephenson/ruby-build.git' #,
   #"revision" => "8ef0c34cdb7da6e6e692f4a3110a37f8d302cb4d"
  },

  { "name" =>  "rbenv-gem-rehash",
    "repo" => 'https://github.com/sstephenson/rbenv-gem-rehash.git' #,
    #"revision" =>  "4d7b92de4bdf549df59c3c8feb1890116d2ea985"
  }
]

plugins.each do |details|
  git "installing rbenv plugin #{details["name"]}" do
    destination "#{node["rbenv"]["root"]}/plugins/#{details["name"]}"
    repository details["repo"]
    revision details["revision"] if details["revision"]
    user node["rbenv"]["user"]
    group node["rbenv"]["group"]
    action :sync
  end
end

cookbook_file "/home/#{node["rbenv"]["user"]}/.rbenv_bashrc" do
  source 'rbenv_bashrc'
  mode 0755
  owner node["rbenv"]["user"]
  group node["rbenv"]["group"]
end

ruby_block 'Install .bashrc hook to .rbenv_bashrc' do
  # bashrc as bashrc works also for ssh commands (interactive shell), bash_profile usually reads .bashrc
  filename = "/home/#{node["rbenv"]["user"]}/.bashrc"

  block do

    hook = '. ~/.rbenv_bashrc  # rbenv_bashrc v001'

    content = if File.exist?(filename)
                File.read(filename)
                                  else
                                    ''
                                                                end
    File.open(filename, 'w') do | fd|
      fd.puts hook
      fd.write content
    end
  end
  not_if %(grep "# rbenv_bashrc v001" #{filename}) # don't update if hook is there
end
