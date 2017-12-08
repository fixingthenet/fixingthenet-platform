require 'pathname'
module Fxnet
  module Platform
    class Release
      def self.run(args, options, global_options)
        stack_name=args[0]
        service=options[:service]
        env = global_options[:environment]

        if stack_name.nil? || stack_name.empty?
          puts "No such path or stack name not given: #{stack_name}"
          exit 1
        end
      
        ce=Fxnet::Platform.config.env
        catalog=Pathname.new(File.expand_path(ce.catalog_root))

        stack_path=catalog.join('stacks',stack_name)
        rancher_opts=[]
     
        bash_cmd=["cd #{stack_path}"]
        
        bash_cmd << "GLI_DEBUG=true ENV=#{env} orchparty generate rancher_v2 -f stack.rb -d docker-compose.yml -r rancher-compose.yml -a #{stack_name}"
        bash_cmd << "cp docker-compose.yml docker-compose-#{env}.yml"
        bash_cmd << "cp rancher-compose.yml rancher-compose-#{env}.yml"
        bash_cmd << ["rancher",
                       "--access-key #{ce.rancher.access_key}",
                       "--secret-key #{ce.rancher.secret_key}",
                       "--url #{ce.rancher.url}",
                       "--environment #{ce.rancher.environment}",
                       "up #{rancher_opts.join(' ')}",
                       "--force-upgrade", 
                       "--stack #{stack_name} -d"].join(' ')

        puts bash_cmd.join(' && ')
        puts `#{bash_cmd.join(' && ')}`

      end
    end
  end
end
