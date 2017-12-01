Fxnet::Platform.config.set do |config|

  config.dev!.catalog_root="/vagrant/code/fxnet-catalog"
  config.dev.rancher!.url='http://172.17.0.1:8080'
  config.dev.rancher.access_key='unset'
  config.dev.rancher.secret_key='unset'
  config.dev.rancher.environment='default'

end
