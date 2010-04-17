#
# This file dynamically defines the User created form builders.  You the user create these form builders by
# adding view partials inside the <tt>app/views/form_fu</tt> folder.  Each folder becomes a form builder.
# Each new form builder defines the convinience methods <tt>..._form_for</tt>, <tt>..._fields_for</tt>,
# <tt>..._form_remote_for</tt> and <tt>..._remote_fields_for</tt>.
#
# See the README for more details.

require 'form_fu_builder_methods'

Dir[File.expand_path("#{RAILS_ROOT}/app/views/form_fu/*")].uniq.each do |dir|
  dir = Pathname.new(dir).basename.to_s
  
  FormFu.module_eval %(
    class #{dir.camelize}FormBuilder < ActionView::Helpers::FormBuilder #:nodoc:
      include FormFu::FormFuBuilderMethods
    
    private
      def fieldset_wrapper(fields, options = {}, html_options = {})
        @template.render :partial => (options[:partial] || '/form_fu/#{dir}/fieldset.html.erb'),
          :locals => {
            :fields => fields,
            :options => @options.except(:builder).merge(options),
            :html_options => html_options || {}
          }
      end
      
      def field_wrapper(method, options = {}, field_tag = nil)
        error_tag = field_error(method)
        builder, selector = get_partial(options)
        unless builder
          return @template.render(:text => field_tag)
        end
        locals = {
          :field_label => field_label(method, options.delete(:label), options),
          :field_error => error_tag,
          :field_input => field_tag,
          :html_options => options[:html] || {},
          :options => @options.except(:builder).merge(options[:report].blank? ? clean_options(options) : {})
        }
        begin
          @template.render(:partial => "/form_fu/#\{builder\}/#\{selector\}.html.erb", :locals => locals)
        rescue ActionView::MissingTemplate
          begin
            @template.render :partial => "/form_fu/#\{builder\}/field.html.erb", :locals => locals
          rescue ActionView::MissingTemplate
            @template.render :partial => '/form_fu/#{dir}/field.html.erb', :locals => locals
          end
        end
      end
      
      def buttonset_wrapper(buttons, options = {}, html_options = {})
        @template.render :partial => (options[:partial] || '/form_fu/#{dir}/buttonset.html.erb'),
          :locals => {
            :buttons => buttons,
            :options => @options.except(:builder).merge(options),
            :html_options => html_options || {}
          }
      end
      
      def get_partial(options = {})
        selector = options.delete(:selector)
        builder = options.delete(:builder)
        if [Class, FalseClass].include? builder.class
          begin
            builder = /FormFu::(.+?)FormBuilder/.match(builder.to_s)[1].underscore
          rescue NoMethodError
            return [false, selector]
          end
        elsif [String, Symbol].include? builder.class
          builder = builder.to_s
          if builder.mb_chars[0...1] == '/'
            dirs = builder.reverse[0...-1].reverse.split('/')
            selector = dirs.pop
            builder = dirs.join('/')
          else
            selector = builder
            builder = '#{dir}'
          end
        else
          builder = '#{dir}'
        end
        [builder, selector]
      end
    end
  ), __FILE__, __LINE__
end
