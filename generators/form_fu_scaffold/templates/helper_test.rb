require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../test_helper'

class <%= controller_class_name %>HelperTest < ActionView::TestCase
end
