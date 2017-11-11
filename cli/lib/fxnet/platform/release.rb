require 'pathname'
module Fxnet
  module Platform
    class Release
      def self.run(args, options, global_options)
        stack_name=args[0]
        service=options[:service]
        env = global_options[:environment]

        ce=Fxnet::Platform.config.env
        catalog=Pathname.new(File.expand_path(ce.catalog_root))

        stack_path=catalog.join('stacks',stack_name)
        bash_cmd=["cd #{stack_path}"]

        bash_cmd << "GLI_DEBUG=true ENV=#{env} orchparty generate rancher_v2 -f stack.rb -d docker-compose.yml -r rancher-compose.yml -a #{stack_name}"
        bash_cmd << "cp docker-compose.yml docker-compose-#{env}.yml"
        bash_cmd << "cp rancher-compose.yml rancher-compose-#{env}.yml"
        puts `#{bash_cmd.join(' && ')}`

      end
    end
  end
end
