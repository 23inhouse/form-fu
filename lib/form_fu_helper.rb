#
# This file has the module FormFu::FormHelper which is included in ActionView::Base.
#
module FormFu #:nodoc:
  module FormHelper
    # Very similar to the default label method, except it uses validation reflection to add a
    # <tt>*</tt> if the column has <tt>validates_presence_of</tt> set.
    # note: validation_refelection plugin is required for this to work.
    #
    # ==== Examples
    #   field_label("post", "category")
    #   # => <label for="post_category">Category</label>
    #
    # Setting the label to "My text"
    #
    #   field_label("post", "category", "My text")
    #   # => <label for="post_category">My text</label>
    #
    # If the Model has validations set:
    # Post.validates_presence_of :category
    #
    #   field_label("post", "category")
    #   # => <label for="post_category">category <em>*</em></label>
    #
    # Using translations from config/locales, this also works for making non friendly column names friendly by adding "transaltions" into en.yml
    #
    #   field_label("post", "category")
    #   # => <label for="post_category">categorie</label>
    #
    # Passing options such as <tt>:required => true</tt>
    # note: pass nil, so you can pass the options hash after it, without modifying the text value
    #
    #   field_label("post", "category", nil, :required => true)
    #   # => <label for="post_category">Category <em>*</em></label>
    def field_label(object_name, method, text = nil, options = {})
      ActionView::Helpers::InstanceTag.new(object_name, method, self, options.delete(:object)).to_field_label_tag(text, options)
    end
  end
  
  module InstanceTag #:nodoc:
    include ActionView::Helpers::JavaScriptHelper
    
    def self.included(klass)
      klass.class_eval do
        # @@field_error_proc = Proc.new{ |html_tag, instance| html_tag }
        alias_method_chain :error_wrapping, :form_fu
        
        alias_method_chain :to_check_box_tag, :form_fu
        alias_method_chain :to_date_select_tag, :form_fu
        alias_method_chain :to_datetime_select_tag, :form_fu
        alias_method_chain :to_input_field_tag, :form_fu
        alias_method_chain :to_text_area_tag, :form_fu
        alias_method_chain :to_time_select_tag, :form_fu
      end
    end
    
    def error_wrapping_with_form_fu(html_tag, has_error)
      error_wrapping_without_form_fu(html_tag, nil)
    end
    
    def to_add_default_name_and_id(options = {})
      add_default_name_and_id(options)
      options
    end
    
    def to_field_label_tag(text = nil, options = {})
      text ||= object.class.human_attribute_name(@method_name)
      required = options.delete(:required) && !options.delete(:report)
      options.reject! { |k,v| ![:accesskey, :class, :dir, :for, :id, :lang, :onblur, :onchange, :onclick, :ondblclick, :onfocus, :onkeydown, :onkeypress, :onkeyup, :onload, :onload, :onmousedown, :onmousemove, :onmouseout, :onmouseover, :onmouseup, :onreset, :onselect, :onsubmit, :onunload, :onunload, :style, :title].include?(k) }
      
      options = options.stringify_keys
      name_and_id = options.dup
      add_default_name_and_id(name_and_id)
      options.delete("index")
      options["for"] ||= name_and_id["id"]
      label_tag(name_and_id["id"], "#{text}#{(required) ? "<em>*</em>" : ""}", options)
    end
    
    def to_report_field_tag(options = {})
      tag = options.delete(:tag) || 'span'
      options.delete(:class)
      options = options.stringify_keys
      options = ActionView::Helpers::InstanceTag::DEFAULT_FIELD_OPTIONS.merge(options)
      options["value"] ||= value_before_type_cast(object)
      options["value"] &&= html_escape(options["value"])
      options[:text] = options["value"]
      add_default_name_and_id(options)
      report_value_and_hidden_field(tag, options)
    end
    
    def to_check_box_tag_with_form_fu(options = {}, checked_value = "1", unchecked_value = "0")
      unless options.delete(:report)
        to_check_box_tag_without_form_fu(clean_html_options(options), checked_value, unchecked_value)
      else
        options = options.stringify_keys
        options["value"] ||= value_before_type_cast(object)
        options["value"] &&= html_escape(options["value"])
        unless options["value"].blank?
          options[:text] = ['0', 0, 'f'].include?(options["value"]) ? 'No' : 'Yes' unless options["value"].blank?
        end
        add_default_name_and_id(options)
        report_value_and_hidden_field('span', options)
      end
    end
    
    def to_date_select_tag_with_form_fu(options = {}, html_options = {})
      unless options.delete(:report)
        to_date_select_tag_without_form_fu(options, clean_html_options(html_options))
      else
        to_report_field_tag(options)
      end
    end

    def to_datetime_select_tag_with_form_fu(options = {}, html_options = {})
      unless options.delete(:report)
        to_datetime_select_tag_without_form_fu(options, clean_html_options(html_options))
      else
        to_report_field_tag(options)
      end
    end

    def to_input_field_tag_with_form_fu(fieldtype, options = {})
      unless options.delete(:report)
        to_input_field_tag_without_form_fu(fieldtype, clean_html_options(options))
      else
        to_report_field_tag(options)
      end
    end
    
    def to_text_area_tag_with_form_fu(options = {})
      unless options.delete(:report)
        to_text_area_tag_without_form_fu(clean_html_options(options))
      else
        to_report_field_tag(options.merge(:tag => 'p'))
      end
    end
    
    def to_time_select_tag_with_form_fu(options = {}, html_options = {})
      unless options.delete(:report)
        to_time_select_tag_without_form_fu(options, clean_html_options(html_options))
      else
        to_report_field_tag(options)
      end
    end

  private
    
    def report_value_and_hidden_field(tag, options)
      display_tag = content_tag(tag, options.delete(:text), nil)
    end
    
    def html_attrs
      [:abbr, 'accept-charset', :accept, :accesskey, :action, :align, :alink, :alt, :archive, :archive, :axis, :background, :bgcolor, :border, :cellpadding, :cellspacing, :char, :charoff, :charset, :checked, :cite, :class, :classid, :clear, :code, :codebase, :codetype, :color, :cols, :colspan, :compact, :content, :contenteditable, :coords, :data, :datafld, :dataformatas, :datasrc, :datetime, :declare, :defer, :dir, :disabled, :enctype, :face, :for, :frame, :frameborder, :headers, :height, :hidefocus, :href, :hreflang, :hspace, 'http-equiv', :id, :ismap, :label, :lang, :language, :link, :longdesc, :longdesc, :marginheight, :marginwidth, :maxlength, :media, :method, :multiple, :name, :nohref, :noresize, :noshade, :nowrap, :object, :onblur, :onchange, :onclick, :ondblclick, :onfocus, :onkeydown, :onkeypress, :onkeyup, :onload, :onload, :onmousedown, :onmousemove, :onmouseout, :onmouseover, :onmouseup, :onreset, :onselect, :onsubmit, :onunload, :onunload, :profile, :prompt, :readonly, :rel, :rev, :rows, :rowspan, :rules, :scheme, :scope, :scrolling, :selected, :shape, :size, :span, :src, :standby, :start, :style, :summary, :tabindex, :target, :text, :title, :type, :unselectable, :usemap, :valign, :value, :valuetype, :version, :vlink, :vspace, :width]
    end
    
    def clean_html_options(options = {}) #:nodoc:
      options.reject { |k,v| !html_attrs.include?(k) }
    end
  end
end