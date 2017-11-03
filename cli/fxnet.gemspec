# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','fxnet','cli','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'fxnet-cli'
  s.version = Fxnet::Cli::VERSION
  s.author = 'Peter Schrammel'
  s.email = 'peter.schrammel@gmx.de'
  s.homepage = 'http://github.com/fixingthenet'
  s.platform = Gem::Platform::RUBY
  s.summary = 'CLI to deploy cotainers on your cluster'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','fxnet.rdoc']
  s.rdoc_options << '--title' << 'fxnet' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'fxnet'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','~>2.0')
  s.add_runtime_dependency "orchparty", "1.2.1"
  s.add_runtime_dependency "hashie", "~>3.5"
end
