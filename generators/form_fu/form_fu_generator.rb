class FormFuGenerator < Rails::Generator::Base
  
  def initialize(*runtime_args)
    super
  end
  
  def manifest
    record do |m|
      m.directory File.join('app', 'views', 'form_fu', 'uni')
      m.template '_buttonset.html.erb', File.join('app', 'views', 'form_fu', 'uni', '_buttonset.html.erb')
      m.template '_fieldset.html.erb', File.join('app', 'views', 'form_fu', 'uni', '_fieldset.html.erb')
      m.template '_field.html.erb', File.join('app', 'views', 'form_fu', 'uni', '_field.html.erb')
      m.template '_date_select.html.erb', File.join('app', 'views', 'form_fu', 'uni', '_date_select.html.erb')
      if File.exists?('vendor/plugins/uni-form')
        m.file '../../../../uni-form/css/uni-form.css', File.join('public', 'stylesheets', 'uni-form.css')
        m.template 'form-fu.css', File.join('public', 'stylesheets', 'form-fu.css')
        m.file '../../../../uni-form/js/jquery.js', File.join('public', 'javascripts', 'jquery.js')
        m.file '../../../../uni-form/js/uni-form.jquery.js', File.join('public', 'javascripts', 'uni-form.jquery.js')
      end
    end
  end
    
  protected
  
  def banner
    %{Usage: #{$0} #{spec.name}\nCopies partials fieldset_wrapper and field_wrapper into app/views/form_fu/uni}
  end
end
