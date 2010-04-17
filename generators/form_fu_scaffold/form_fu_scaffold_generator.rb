class FormFuScaffoldGenerator < Rails::Generator::ScaffoldGenerator
  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} form_fu_scaffold [options] ModelName [field:type, field:type]"
    end

    def scaffold_views
      %w[ index show new edit _fields]
    end
    
    # Override to add your options to the parser:
    #   def add_options!(opt)
    #     opt.on('-v', '--verbose') { |value| options[:verbose] = value }
    #   end
    def add_options!(opt)
      opt.on('-r', '--resources', 'Generate the routes as nested resources.') { |value| options[:resources] = value }
      opt.on('-n', '--namespace', 'Generate the routes and app files within a namespace.') { |value| options[:namespace] = value }
      # opt.on('-c', '--custom_form_builder', 'Generate the forms with custom form builder.') { |value| options[:custom_form_builder] = value }
    end
    
end

module Rails
  module Generator
    module Commands
      class Create < Base
        def route_resources(*resources)
          resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
          sentinel = 'ActionController::Routing::Routes.draw do |map|'

          logger.route "map.resources #{resource_list}"
          if options[:namespace]
            # puts '-----------'
            # puts resource_list
          end
          unless options[:pretend]
            gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
              "#{match}\n  map.resources #{resource_list}\n"
            end
          end
        end
      end
    end
  end
end
