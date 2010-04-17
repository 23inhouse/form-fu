#
# This file has the module FormFu::FormOptionsHelper which is included in ActionView::Base.
#
module FormFu #:nodoc:
  #
  # Provides 2 methods for displaying dropdown select lists as check boxes or radio buttons.
  #
  module FormOptionsHelper
    
    # Just like select from ActionView::Helpers::FormOptionsHelper, except it outputs check boxes instead of a drop down select.
    # Because it is checkboxes it's like a select with multiselect = true.
    #
    # ==== Examples
    #   check_boxes("post", "category", Post::CATEGORIES)
    #
    # Could become:
    #
    #   # => <ul>
    #   # =>   <li>
    #   # =>     <input type="checkbox" value="cat_1" name="post[category][cat_1]"/><label>Cat 1</label>
    #   # =>     <input type="checkbox" value="cat_2" name="post[category][cat_2]"/><label>Cat 2</label>
    #   # =>     <input type="checkbox" value="cat_3" name="post[category][cat_3]"/><label>Cat 3</label>
    #   # =>     <input type="checkbox" value="cat_4" name="post[category][cat_4]"/><label>Cat 4</label>
    #   # =>   </li>
    #   # => </ul>
    def check_boxes(object, method, choices, options = {}, html_options = {})
      ActionView::Helpers::InstanceTag.new(object, method, self, options.delete(:object)).to_check_boxes_tag(choices, options, html_options)
    end
    
    def options_for_checks(container, name_and_id = {}, options = {}) #:nodoc:
      class_attribute = " class=\"#{options[:class]}\"" if options.has_key?(:class)
      container = container.to_a if Hash === container
      checked, disabled, inline = extract_checked_and_disabled_and_inline(options)
      options_for_checks = container.inject([]) do |checks, element|
        text, value = option_text_and_value(element)
        checked_attribute = ' checked="checked"' if option_value_checked?(value, checked)
        disabled_attribute = ' disabled="disabled"' if disabled
        inline_tag = '<br/>' unless inline == true
        checks << %(<input type="checkbox" id="#{name_and_id['id']}_#{html_escape(value.to_s.downcase)}" name="#{name_and_id['name']}[]" value="#{html_escape(value.to_s)}"#{checked_attribute}#{disabled_attribute}#{class_attribute}/><label for="#{name_and_id['id']}_#{html_escape(value.to_s.downcase)}">#{html_escape(text.to_s)}</label>#{inline_tag})
      end

      options_for_checks.join("\n") + %(<input type="hidden" name="#{name_and_id['name']}" value=""/>)
    end
    
    # Just like select from ActionView::Helpers::FormOptionsHelper, except it outputs radio buttons instead of a drop down select.
    #
    # ==== Examples
    #   radio_buttons("post", "category", Post::CATEGORIES)
    #
    # Could become:
    #
    #   # => <ul>
    #   # =>   <li>
    #   # =>     <input type="radio" value="cat_1" name="post[category]"/><label>Cat 1</label>
    #   # =>     <input type="radio" value="cat_2" name="post[category]"/><label>Cat 2</label>
    #   # =>     <input type="radio" value="cat_3" name="post[category]"/><label>Cat 3</label>
    #   # =>     <input type="radio" value="cat_4" name="post[category]"/><label>Cat 4</label>
    #   # =>   </li>
    #   # => </ul>
    def radio_buttons(object, method, choices, options = {}, html_options = {})
      ActionView::Helpers::InstanceTag.new(object, method, self, options.delete(:object)).to_radio_buttons_tag(choices, options, html_options)
    end
    
    def options_for_radios(container, name_and_id = {}, options = {}) #:nodoc:
      class_attribute = " class=\"#{options[:class]}\"" if options.has_key?(:class)
      container = container.to_a if Hash === container
      checked, disabled, inline = extract_checked_and_disabled_and_inline(options)
      options_for_radios = container.inject([]) do |radios, element|
        text, value = option_text_and_value(element)
        checked_attribute = ' checked="checked"' if option_value_checked?(value, checked)
        disabled_attribute = ' disabled="disabled"' if disabled
        inline_tag = '<br/>' unless inline == true
        radios << %(<input type="radio" id="#{name_and_id['id']}_#{html_escape(value.to_s.downcase)}" name="#{name_and_id['name']}" value="#{html_escape(value.to_s)}"#{checked_attribute}#{disabled_attribute}#{class_attribute}/><label for="#{name_and_id['id']}_#{html_escape(value.to_s.downcase)}">#{html_escape(text.to_s)}</label>#{inline_tag})
      end

      options_for_radios.join("\n")
    end
    
  private
  
    def option_value_checked?(value, checked) #:nodoc:
      if checked.respond_to?(:include?) && !checked.is_a?(String)
        checked.include? value
      else
        value == checked
      end
    end

    def extract_checked_and_disabled_and_inline(checked) #:nodoc:
      if checked.is_a?(Hash)
        [checked[:checked], checked[:disabled], checked[:inline]]
      else
        [checked, nil, false]
      end
    end
  end
  
  module InstanceTag #:nodoc:
    include FormOptionsHelper
    
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :to_check_boxes_tag, :form_fu
        alias_method_chain :to_radio_buttons_tag, :form_fu
        alias_method_chain :to_select_tag, :form_fu
      end
    end
    
    def to_check_boxes_tag(choices, options, html_options)
      class_value = html_options.delete(:class)
      disabled_value = html_options.delete(:disabled)
      html_options = html_options.stringify_keys
      name_and_id = html_options.dup
      add_default_name_and_id(name_and_id)
      value = value(object)
      selected_value = options.has_key?(:selected) ? options[:selected] : value
      inline_value = options.has_key?(:inline) ? options[:inline] : false
      
      check_box_tags = options_for_checks(choices, name_and_id, {:checked => selected_value, :disabled => disabled_value, :class => class_value, :inline => inline_value})
      check_label_pairs = add_checkbox_label_pairs(check_box_tags, options, selected_value)
      content_tag("div", check_label_pairs, html_options.merge(:class => 'form_fu_checks'))
    end
    
    def to_check_boxes_tag_with_form_fu(choices, options, html_options)
      unless options.delete(:report)
        to_check_boxes_tag_without_form_fu(choices, options, clean_html_options(html_options))
      else
        choices = choices.to_a if Hash === choices
        choices.each do |element|
          text, value = option_text_and_value(element)
          if value == value(object)
            options["value"] = value 
            options[:text] = text
          end
        end
        add_default_name_and_id(options)
        report_value_and_hidden_field('span', options)
      end
    end
    
    def to_radio_buttons_tag(choices, options, html_options)
      class_value = html_options.delete(:class)
      disabled_value = html_options.delete(:disabled)
      html_options = html_options.stringify_keys
      name_and_id = html_options.dup
      add_default_name_and_id(name_and_id)
      value = value(object)
      selected_value = options.has_key?(:selected) ? options[:selected] : value
      inline_value = options.has_key?(:inline) ? options[:inline] : false
      
      radio_button_tags = options_for_radios(choices, name_and_id, {:checked => selected_value, :disabled => disabled_value, :class => class_value, :inline => inline_value})
      radio_label_pairs = add_radio_label_pairs(radio_button_tags, options, selected_value)
      content_tag("div", radio_label_pairs, html_options.merge(:class => 'form_fu_radios'))
    end
    
    def to_radio_buttons_tag_with_form_fu(choices, options, html_options)
      unless options.delete(:report)
        to_radio_buttons_tag_without_form_fu(choices, options, clean_html_options(html_options))
      else
        choices = choices.to_a if Hash === choices
        choices.each do |element|
          text, value = option_text_and_value(element)
          if value == value(object)
            options["value"] = value 
            options[:text] = text
          end
        end
        add_default_name_and_id(options)
        report_value_and_hidden_field('span', options)
      end
    end
    
    def to_select_tag_with_form_fu(choices, options, html_options)
      unless options.delete(:report)
        to_select_tag_without_form_fu(choices, options, clean_html_options(html_options))
      else
        choices = choices.to_a if Hash === choices
        choices.each do |element|
          text, value = option_text_and_value(element)
          if value == value(object)
            options["value"] = value 
            options[:text] = text
          end
        end
        add_default_name_and_id(options)
        report_value_and_hidden_field('span', options)
      end
    end
    
  private
  
    def add_checkbox_label_pairs(check_box_tags, options, value = nil)
      if options[:include_blank]
        checked, disabled, inline = extract_checked_and_disabled_and_inline(options)
        inline_tag = '<br/>' unless inline == true
        check_box_tags = "<label><input type=\"checkbox\" value=\"\"/>#{options[:include_blank] if options[:include_blank].kind_of?(String)}</label>\n" + inline_tag + check_box_tags
      end
      check_box_tags
    end
    
    def add_radio_label_pairs(radio_button_tags, options, value = nil)
      if options[:include_blank]
        checked, disabled, inline = extract_checked_and_disabled_and_inline(options)
        inline_tag = '<br/>' unless inline == true
        radio_button_tags = "<label><input type=\"radio\" value=\"\"/>#{options[:include_blank] if options[:include_blank].kind_of?(String)}</label>\n" + inline_tag + radio_button_tags
      end
      radio_button_tags
    end
  end
  
  module FormBuilder #:nodoc:
    def check_boxes(method, choices, options = {}, html_options = {})
      @template.check_boxes(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options))
    end
    
    def radio_buttons(method, choices, options = {}, html_options = {})
      @template.radio_buttons(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options))
    end
  end
end