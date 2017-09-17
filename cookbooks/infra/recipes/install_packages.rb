node["infra"]["packages"].each do |pck|
  package pck
end

%w(mlocate).each do |pname|
  apt_package pname do
    action :purge
  end
end
  