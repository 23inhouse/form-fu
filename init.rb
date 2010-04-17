# Form Builders
require 'form_fu_options_helper'
ActionView::Base.send                 :include, FormFu::FormOptionsHelper
ActionView::Helpers::InstanceTag.send :include, FormFu::InstanceTag
ActionView::Helpers::FormBuilder.send :include, FormFu::FormBuilder

require 'form_fu_helper'
ActionView::Base.send                 :include, FormFu::FormHelper
ActionView::Helpers::InstanceTag.send :include, FormFu::InstanceTag

require 'form_fu_builder'
