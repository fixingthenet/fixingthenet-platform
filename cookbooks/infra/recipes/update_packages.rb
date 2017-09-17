execute "apt-get update" do
  action :nothing
end.run_action(:run)
