require 'active_support/test_case'

%w(set rubygems action_controller action_view test/form_fut mocha ).each { |x| require x }

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'form_fu_options_helper'
ActionView::Base.send                 :include, FormFu::FormOptionsHelper
ActionView::Helpers::InstanceTag.send :include, FormFu::InstanceTag
ActionView::Helpers::FormBuilder.send :include, FormFu::FormBuilder

require 'form_fu_helper'
ActionView::Base.send                 :include, FormFu::FormHelper
ActionView::Helpers::InstanceTag.send :include, FormFu::InstanceTag

require 'form_fu_builder' # loads the builder classes

class FormFu::TestCase < ActiveSupport::TestCase
  
  setup :setup_with_helper_class

  def setup_with_helper_class
    self.output_buffer = ''
  end
  
protected
  attr_accessor :output_buffer
end