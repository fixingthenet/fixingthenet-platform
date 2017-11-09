Fxnet::Platform.config.set do |config|
  live_api_key='test'
  config.dev!.api_key=live_api_key
end
