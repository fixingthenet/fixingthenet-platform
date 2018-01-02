require 'pathname'
module Fxnet
  module Platform
    class Release
# args: stack_name
# options: dev, service, confirm, test
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
        if options['service'] # this has to be #1
          rancher_opts << options['service'].split(',').join(' ')
        end
        rancher_opts << '--confirm-upgrade' if options[:confirm]
        bash_cmd_test=["cd #{stack_path}"]
        bash_cmd=[]
        
        bash_cmd_test << "GLI_DEBUG=true FXNET_ENV=#{env} DEV_MODE=#{!!options[:dev]} orchparty generate rancher_v2 -f stack.rb -d docker-compose.yml -r rancher-compose.yml -a #{stack_name}"
        bash_cmd_test << "cp docker-compose.yml docker-compose-#{env}.yml"
        bash_cmd_test << "cp rancher-compose.yml rancher-compose-#{env}.yml"
        
        
        bash_cmd << ["rancher",
                       "--access-key #{ce.rancher.access_key}",
                       "--secret-key #{ce.rancher.secret_key}",
                       "--url #{ce.rancher.url}",
                       "--environment #{ce.rancher.environment}",
                       "up #{rancher_opts.join(' ')}",
                       "--force-upgrade",
                       "--stack #{stack_name} -d"].join(' ')

        full_cmd=(bash_cmd_test + bash_cmd).join(' && ')

        if options[:test]
         cmd=bash_cmd_test.join(' && ')
        else  
         cmd=full_cmd
        end  

        puts full_cmd
        puts `#{cmd}`

      end
    end
  end
end
