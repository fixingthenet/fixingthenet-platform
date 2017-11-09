require 'hashie'
require 'singleton'
module Fxnet
  module Platform
    def self.config
      Config.instance
    end

    class Config
      include Singleton
      def self.read(config_file: '~/.fxnet/config.rb')
        eval(File.read(File.expand_path(config_file)))
      end
      def initialize
        @config=Hashie::Mash.new
        @env='dev'
      end
      def set
        yield @config
      end
      def env=(env)
        @env=env
      end
      def env
        @config[@env]
      end
      def method_missing(method)
        @config.send(method)
      end
    end
  end
end
