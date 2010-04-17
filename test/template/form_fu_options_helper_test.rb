%w(set rubygems action_controller action_view test/form_fut mocha ).each { |x| require x }

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/test_helper.rb'

class FormFuOptionsHelper < FormFu::TestCase
  include ActionController::TestCase::Assertions,
          ActionView::Helpers::FormHelper,
          ActionView::Helpers::FormOptionsHelper,
          ActionView::Helpers::TextHelper,
          FormFu::FormOptionsHelper
  
  Post = Struct.new('Post', :title, :author_name, :body, :secret, :written_on, :category, :origin)
  Album = Struct.new('Album', :id, :title, :genre)
  
  # tests for check_boxes
  
  def test_array_options_for_checks
    assert_dom_equal(
      %(<input type="checkbox" id="_&lt;denmark&gt;" name="[]" value="&lt;Denmark&gt;"/><label for="_&lt;denmark&gt;">&lt;Denmark&gt;</label><br />\n<input type="checkbox" id="_usa" name="[]" value="USA"/><label for="_usa">USA</label><br />\n<input type="checkbox" id="_sweden" name="[]" value="Sweden"/><label for="_sweden">Sweden</label><br /><input type="hidden" name="" value=""/>),
      options_for_checks([ "<Denmark>", "USA", "Sweden" ])
    )
  end
  
  def test_array_options_for_checks_with_selection
    assert_dom_equal(
      %(<input type="checkbox" id="_denmark" name="[]" value="Denmark"/><label for="_denmark">Denmark</label><br />\n<input type="checkbox" id="_&lt;usa&gt;" name="[]" value="&lt;USA&gt;" checked="checked"/><label for="_&lt;usa&gt;">&lt;USA&gt;</label><br />\n<input type="checkbox" id="_sweden" name="[]" value="Sweden"/><label for="_sweden">Sweden</label><br /><input type="hidden" name="" value=""/>),
      options_for_checks([ "Denmark", "<USA>", "Sweden" ], {}, {:checked => "<USA>"})
    )
  end
  
  def test_array_options_for_checks_with_selection_array
    assert_dom_equal(
      %(<input type="checkbox" id="_denmark" name="[]" value="Denmark"/><label for="_denmark">Denmark</label><br />\n<input type="checkbox" id="_&lt;usa&gt;" name="[]" value="&lt;USA&gt;" checked="checked"/><label for="_&lt;usa&gt;">&lt;USA&gt;</label><br />\n<input type="checkbox" id="_sweden" name="[]" value="Sweden" checked="checked"/><label for="_sweden">Sweden</label><br /><input type="hidden" name="" value=""/>),
      options_for_checks([ "Denmark", "<USA>", "Sweden" ], {}, {:checked => [ "<USA>", "Sweden" ]})
    )
  end
  
  def test_hash_options_for_checks
    assert_dom_equal(
      %(<input name="[]" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="checkbox" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br /><input name="" value="" type="hidden" />\n<input name="[]" id="_dollar" value="Dollar" type="checkbox" /><label for="_dollar">$</label><br />),
      options_for_checks("$" => "Dollar", "<DKR>" => "<Kroner>").split("\n").sort.join("\n")
    )
    assert_dom_equal(
      %(<input name="[]" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="checkbox" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br /><input name="" value="" type="hidden" />\n<input checked="checked" name="[]" id="_dollar" value="Dollar" type="checkbox" /><label for="_dollar">$</label><br />),
      options_for_checks({ "$" => "Dollar", "<DKR>" => "<Kroner>" }, {}, {:checked => "Dollar"}).split("\n").sort.join("\n")
    )
    assert_dom_equal(
      %(<input checked="checked" name="[]" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="checkbox" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br /><input name="" value="" type="hidden" />\n<input checked="checked" name="[]" id="_dollar" value="Dollar" type="checkbox" /><label for="_dollar">$</label><br />),
      options_for_checks({ "$" => "Dollar", "<DKR>" => "<Kroner>" }, {}, {:checked => [ "Dollar", "<Kroner>" ]}).split("\n").sort.join("\n")
    )
  end

  def test_ducktyped_options_for_checks
    quack = Struct.new(:first, :last)
    assert_dom_equal(
      %(<input name="[]" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="checkbox" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br />\n<input name="[]" id="_dollar" value="Dollar" type="checkbox" /><label for="_dollar">$</label><br /><input name="" value="" type="hidden" />),
      options_for_checks([quack.new("<DKR>", "<Kroner>"), quack.new("$", "Dollar")])
    )
    assert_dom_equal(
      %(<input name="[]" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="checkbox" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br />\n<input checked="checked" name="[]" id="_dollar" value="Dollar" type="checkbox" /><label for="_dollar">$</label><br /><input name="" value="" type="hidden" />),
      options_for_checks([quack.new("<DKR>", "<Kroner>"), quack.new("$", "Dollar")], {}, {:checked => "Dollar"})
    )
    assert_dom_equal(
      %(<input checked="checked" name="[]" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="checkbox" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br />\n<input checked="checked" name="[]" id="_dollar" value="Dollar" type="checkbox" /><label for="_dollar">$</label><br /><input name="" value="" type="hidden" />),
      options_for_checks([quack.new("<DKR>", "<Kroner>"), quack.new("$", "Dollar")], {}, {:checked => ["Dollar", "<Kroner>"]})
    )
  end
  
  def test_check_boxes
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_checks"><input name="post[category][]" class="" id="post_category_abe" value="abe" type="checkbox" /><label for="post_category_abe">abe</label><br />\n<input checked="checked" name="post[category][]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="checkbox" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category][]" class="" id="post_category_hest" value="hest" type="checkbox" /><label for="post_category_hest">hest</label><br /><input name="post[category]" value="" type="hidden" /></div>),
      check_boxes("post", "category", %w( abe <mus> hest))
    )
  end

  def test_check_boxes_under_fields_for
    @post = Post.new
    @post.category = "<mus>"

    fields_for :post, @post do |f|
      concat f.check_boxes(:category, %w( abe <mus> hest))
    end
  
    assert_dom_equal(
      %(<div class="form_fu_checks"><input name="post[category][]" class="" id="post_category_abe" value="abe" type="checkbox" /><label for="post_category_abe">abe</label><br />\n<input checked="checked" name="post[category][]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="checkbox" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category][]" class="" id="post_category_hest" value="hest" type="checkbox" /><label for="post_category_hest">hest</label><br /><input name="post[category]" value="" type="hidden" /></div>),
      output_buffer
    )
  end
  
  def test_check_boxes_under_fields_for_with_auto_index
    @post = Post.new
    @post.category = "<mus>"
    def @post.to_param; 108; end

    fields_for "post[]", @post do |f|
      concat f.check_boxes(:category, %w( abe <mus> hest))
    end

    assert_dom_equal(
      %(<div class="form_fu_checks"><input name="post[108][category][]" class="" id="post_108_category_abe" value="abe" type="checkbox" /><label for="post_108_category_abe">abe</label><br />\n<input checked="checked" name="post[108][category][]" class="" id="post_108_category_&lt;mus&gt;" value="&lt;mus&gt;" type="checkbox" /><label for="post_108_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[108][category][]" class="" id="post_108_category_hest" value="hest" type="checkbox" /><label for="post_108_category_hest">hest</label><br /><input name="post[108][category]" value="" type="hidden" /></div>),
      output_buffer
    )
  end

  def test_check_boxes_with_blank
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_checks"><label><input value="" type="checkbox" /></label>\n<input name="post[category][]" class="" id="post_category_abe" value="abe" type="checkbox" /><label for="post_category_abe">abe</label><br />\n<input checked="checked" name="post[category][]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="checkbox" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category][]" class="" id="post_category_hest" value="hest" type="checkbox" /><label for="post_category_hest">hest</label><br /><input name="post[category]" value="" type="hidden" /></div>),
      check_boxes("post", "category", %w( abe <mus> hest), :include_blank => true)
    )
  end
  
  def test_check_boxes_with_blank_as_string
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_checks"><label><input value="" type="checkbox" />None</label>\n<input name="post[category][]" class="" id="post_category_abe" value="abe" type="checkbox" /><label for="post_category_abe">abe</label><br />\n<input checked="checked" name="post[category][]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="checkbox" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category][]" class="" id="post_category_hest" value="hest" type="checkbox" /><label for="post_category_hest">hest</label><br /><input name="post[category]" value="" type="hidden" /></div>),
      check_boxes("post", "category", %w( abe <mus> hest), :include_blank => 'None')
    )
  end
  
  def test_check_boxes_with_default_prompt
    @post = Post.new
    @post.category = ""
    assert_dom_equal(
      %(<div class="form_fu_checks"><input name="post[category][]" class="" id="post_category_abe" value="abe" type="checkbox" /><label for="post_category_abe">abe</label><br />\n<input name="post[category][]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="checkbox" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category][]" class="" id="post_category_hest" value="hest" type="checkbox" /><label for="post_category_hest">hest</label><br /><input name="post[category]" value="" type="hidden" /></div>),
      check_boxes("post", "category", %w( abe <mus> hest), :prompt => true)
    )
  end
  
  def test_check_boxes_no_prompt_when_check_boxes_has_value
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_checks"><input name="post[category][]" class="" id="post_category_abe" value="abe" type="checkbox" /><label for="post_category_abe">abe</label><br />\n<input checked="checked" name="post[category][]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="checkbox" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category][]" class="" id="post_category_hest" value="hest" type="checkbox" /><label for="post_category_hest">hest</label><br /><input name="post[category]" value="" type="hidden" /></div>),
      check_boxes("post", "category", %w( abe <mus> hest), :prompt => true)
    )
  end
  
  def test_check_boxes_with_given_prompt
    @post = Post.new
    @post.category = ""
    assert_dom_equal(
      %(<div class="form_fu_checks"><input name="post[category][]" class="" id="post_category_abe" value="abe" type="checkbox" /><label for="post_category_abe">abe</label><br />\n<input name="post[category][]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="checkbox" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category][]" class="" id="post_category_hest" value="hest" type="checkbox" /><label for="post_category_hest">hest</label><br /><input name="post[category]" value="" type="hidden" /></div>),
      check_boxes("post", "category", %w( abe <mus> hest), :prompt => 'The prompt')
    )
  end
  
  def test_check_boxes_with_prompt_and_blank
    @post = Post.new
    @post.category = ""
    assert_dom_equal(
      %(<div class="form_fu_checks"><label><input value="" type="checkbox" /></label>\n<input name="post[category][]" class="" id="post_category_abe" value="abe" type="checkbox" /><label for="post_category_abe">abe</label><br />\n<input name="post[category][]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="checkbox" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category][]" class="" id="post_category_hest" value="hest" type="checkbox" /><label for="post_category_hest">hest</label><br /><input name="post[category]" value="" type="hidden" /></div>),
      check_boxes("post", "category", %w( abe <mus> hest), :prompt => true, :include_blank => true)
    )
  end
  
  def test_check_boxes_with_selected_value
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_checks"><input checked="checked" name="post[category][]" class="" id="post_category_abe" value="abe" type="checkbox" /><label for="post_category_abe">abe</label><br />\n<input name="post[category][]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="checkbox" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category][]" class="" id="post_category_hest" value="hest" type="checkbox" /><label for="post_category_hest">hest</label><br /><input name="post[category]" value="" type="hidden" /></div>),
      check_boxes("post", "category", %w( abe <mus> hest ), :selected => 'abe')
    )
  end
  
  def test_check_boxes_with_index_option
    @album = Album.new
    @album.id = 1
  
    assert_dom_equal(
      %(<div class="form_fu_checks"><input name="album[][genre][]" class="" id="album__genre_rap" value="rap" type="checkbox" /><label for="album__genre_rap">rap</label><br />\n<input name="album[][genre][]" class="" id="album__genre_rock" value="rock" type="checkbox" /><label for="album__genre_rock">rock</label><br />\n<input name="album[][genre][]" class="" id="album__genre_country" value="country" type="checkbox" /><label for="album__genre_country">country</label><br /><input name="album[][genre]" value="" type="hidden" /></div>),
      check_boxes("album[]", "genre", %w[rap rock country], {}, { :index => nil })
    )
  end
  
  def test_check_boxes_with_selected_nil
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_checks"><input name="post[category][]" class="" id="post_category_abe" value="abe" type="checkbox" /><label for="post_category_abe">abe</label><br />\n<input name="post[category][]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="checkbox" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category][]" class="" id="post_category_hest" value="hest" type="checkbox" /><label for="post_category_hest">hest</label><br /><input name="post[category]" value="" type="hidden" /></div>),
      check_boxes("post", "category", %w( abe <mus> hest ), :selected => nil)
    )
  end
  
  # tests for radios
  
  def test_array_options_for_radios
    assert_dom_equal(
      %(<input type="radio" id="_&lt;denmark&gt;" name="" value="&lt;Denmark&gt;"/><label for="_&lt;denmark&gt;">&lt;Denmark&gt;</label><br />\n<input type="radio" id="_usa" name="" value="USA"/><label for="_usa">USA</label><br />\n<input type="radio" id="_sweden" name="" value="Sweden"/><label for="_sweden">Sweden</label><br />),
      options_for_radios([ "<Denmark>", "USA", "Sweden" ])
    )
  end
  
  def test_array_options_for_radios_with_selection
    assert_dom_equal(
      %(<input type="radio" id="_denmark" name="" value="Denmark"/><label for="_denmark">Denmark</label><br />\n<input type="radio" id="_&lt;usa&gt;" name="" value="&lt;USA&gt;" checked="checked"/><label for="_&lt;usa&gt;">&lt;USA&gt;</label><br />\n<input type="radio" id="_sweden" name="" value="Sweden"/><label for="_sweden">Sweden</label><br />),
      options_for_radios([ "Denmark", "<USA>", "Sweden" ], {}, {:checked => "<USA>"})
    )
  end
  
  def test_array_options_for_radios_with_selection_array
    assert_dom_equal(
      %(<input type="radio" id="_denmark" name="" value="Denmark"/><label for="_denmark">Denmark</label><br />\n<input type="radio" id="_&lt;usa&gt;" name="" value="&lt;USA&gt;" checked="checked"/><label for="_&lt;usa&gt;">&lt;USA&gt;</label><br />\n<input type="radio" id="_sweden" name="" value="Sweden" checked="checked"/><label for="_sweden">Sweden</label><br />),
      options_for_radios([ "Denmark", "<USA>", "Sweden" ], {}, {:checked => [ "<USA>", "Sweden" ]})
    )
  end
  
  def test_hash_options_for_radios
    assert_dom_equal(
      %(<input name="" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="radio" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br />\n<input name="" id="_dollar" value="Dollar" type="radio" /><label for="_dollar">$</label><br />),
      options_for_radios("$" => "Dollar", "<DKR>" => "<Kroner>").split("\n").sort.join("\n")
    )
    assert_dom_equal(
      %(<input name="" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="radio" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br />\n<input checked="checked" name="" id="_dollar" value="Dollar" type="radio" /><label for="_dollar">$</label><br />),
      options_for_radios({ "$" => "Dollar", "<DKR>" => "<Kroner>" }, {}, {:checked => "Dollar"}).split("\n").sort.join("\n")
    )
    assert_dom_equal(
      %(<input checked="checked" name="" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="radio" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br />\n<input checked="checked" name="" id="_dollar" value="Dollar" type="radio" /><label for="_dollar">$</label><br />),
      options_for_radios({ "$" => "Dollar", "<DKR>" => "<Kroner>" }, {}, {:checked => [ "Dollar", "<Kroner>" ]}).split("\n").sort.join("\n")
    )
  end

  def test_ducktyped_options_for_radios
    quack = Struct.new(:first, :last)
    assert_dom_equal(
      %(<input name="" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="radio" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br />\n<input name="" id="_dollar" value="Dollar" type="radio" /><label for="_dollar">$</label><br />),
      options_for_radios([quack.new("<DKR>", "<Kroner>"), quack.new("$", "Dollar")])
    )
    assert_dom_equal(
      %(<input name="" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="radio" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br />\n<input checked="checked" name="" id="_dollar" value="Dollar" type="radio" /><label for="_dollar">$</label><br />),
      options_for_radios([quack.new("<DKR>", "<Kroner>"), quack.new("$", "Dollar")], {}, {:checked => "Dollar"})
    )
    assert_dom_equal(
      %(<input checked="checked" name="" id="_&lt;kroner&gt;" value="&lt;Kroner&gt;" type="radio" /><label for="_&lt;kroner&gt;">&lt;DKR&gt;</label><br />\n<input checked="checked" name="" id="_dollar" value="Dollar" type="radio" /><label for="_dollar">$</label><br />),
      options_for_radios([quack.new("<DKR>", "<Kroner>"), quack.new("$", "Dollar")], {}, {:checked => ["Dollar", "<Kroner>"]})
    )
  end
  
  def test_radio_buttons
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_radios"><input name="post[category]" class="" id="post_category_abe" value="abe" type="radio" /><label for="post_category_abe">abe</label><br />\n<input checked="checked" name="post[category]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="radio" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category]" class="" id="post_category_hest" value="hest" type="radio" /><label for="post_category_hest">hest</label><br /></div>),
      radio_buttons("post", "category", %w( abe <mus> hest))
    )
  end

  def test_radio_buttons_under_fields_for
    @post = Post.new
    @post.category = "<mus>"

    fields_for :post, @post do |f|
      concat f.radio_buttons(:category, %w( abe <mus> hest))
    end
  
    assert_dom_equal(
      %(<div class="form_fu_radios"><input name="post[category]" class="" id="post_category_abe" value="abe" type="radio" /><label for="post_category_abe">abe</label><br />\n<input checked="checked" name="post[category]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="radio" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category]" class="" id="post_category_hest" value="hest" type="radio" /><label for="post_category_hest">hest</label><br /></div>),
      output_buffer
    )
  end
  
  def test_radio_buttons_under_fields_for_with_auto_index
    @post = Post.new
    @post.category = "<mus>"
    def @post.to_param; 108; end

    fields_for "post[]", @post do |f|
      concat f.radio_buttons(:category, %w( abe <mus> hest))
    end

    assert_dom_equal(
      %(<div class="form_fu_radios"><input name="post[108][category]" class="" id="post_108_category_abe" value="abe" type="radio" /><label for="post_108_category_abe">abe</label><br />\n<input checked="checked" name="post[108][category]" class="" id="post_108_category_&lt;mus&gt;" value="&lt;mus&gt;" type="radio" /><label for="post_108_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[108][category]" class="" id="post_108_category_hest" value="hest" type="radio" /><label for="post_108_category_hest">hest</label><br /></div>),
      output_buffer
    )
  end

  def test_radio_buttons_with_blank
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_radios"><label><input value="" type="radio" /></label>\n<input name="post[category]" class="" id="post_category_abe" value="abe" type="radio" /><label for="post_category_abe">abe</label><br />\n<input checked="checked" name="post[category]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="radio" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category]" class="" id="post_category_hest" value="hest" type="radio" /><label for="post_category_hest">hest</label><br /></div>),
      radio_buttons("post", "category", %w( abe <mus> hest), :include_blank => true)
    )
  end
  
  def test_radio_buttons_with_blank_as_string
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_radios"><label><input value="" type="radio" />None</label>\n<input name="post[category]" class="" id="post_category_abe" value="abe" type="radio" /><label for="post_category_abe">abe</label><br />\n<input checked="checked" name="post[category]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="radio" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category]" class="" id="post_category_hest" value="hest" type="radio" /><label for="post_category_hest">hest</label><br /></div>),
      radio_buttons("post", "category", %w( abe <mus> hest), :include_blank => 'None')
    )
  end
  
  def test_radio_buttons_with_default_prompt
    @post = Post.new
    @post.category = ""
    assert_dom_equal(
      %(<div class="form_fu_radios"><input name="post[category]" class="" id="post_category_abe" value="abe" type="radio" /><label for="post_category_abe">abe</label><br />\n<input name="post[category]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="radio" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category]" class="" id="post_category_hest" value="hest" type="radio" /><label for="post_category_hest">hest</label><br /></div>),
      radio_buttons("post", "category", %w( abe <mus> hest), :prompt => true)
    )
  end
  
  def test_radio_buttons_no_prompt_when_radio_buttons_has_value
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_radios"><input name="post[category]" class="" id="post_category_abe" value="abe" type="radio" /><label for="post_category_abe">abe</label><br />\n<input checked="checked" name="post[category]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="radio" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category]" class="" id="post_category_hest" value="hest" type="radio" /><label for="post_category_hest">hest</label><br /></div>),
      radio_buttons("post", "category", %w( abe <mus> hest), :prompt => true)
    )
  end
  
  def test_radio_buttons_with_given_prompt
    @post = Post.new
    @post.category = ""
    assert_dom_equal(
      %(<div class="form_fu_radios"><input name="post[category]" class="" id="post_category_abe" value="abe" type="radio" /><label for="post_category_abe">abe</label><br />\n<input name="post[category]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="radio" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category]" class="" id="post_category_hest" value="hest" type="radio" /><label for="post_category_hest">hest</label><br /></div>),
      radio_buttons("post", "category", %w( abe <mus> hest), :prompt => 'The prompt')
    )
  end
  
  def test_radio_buttons_with_prompt_and_blank
    @post = Post.new
    @post.category = ""
    assert_dom_equal(
      %(<div class="form_fu_radios"><label><input value="" type="radio" /></label>\n<input name="post[category]" class="" id="post_category_abe" value="abe" type="radio" /><label for="post_category_abe">abe</label><br />\n<input name="post[category]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="radio" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category]" class="" id="post_category_hest" value="hest" type="radio" /><label for="post_category_hest">hest</label><br /></div>),
      radio_buttons("post", "category", %w( abe <mus> hest), :prompt => true, :include_blank => true)
    )
  end
  
  def test_radio_buttons_with_selected_value
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_radios"><input checked="checked" name="post[category]" class="" id="post_category_abe" value="abe" type="radio" /><label for="post_category_abe">abe</label><br />\n<input name="post[category]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="radio" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category]" class="" id="post_category_hest" value="hest" type="radio" /><label for="post_category_hest">hest</label><br /></div>),
      radio_buttons("post", "category", %w( abe <mus> hest ), :selected => 'abe')
    )
  end
  
  def test_radio_buttons_with_index_option
    @album = Album.new
    @album.id = 1
  
    assert_dom_equal(
      %(<div class="form_fu_radios"><input name="album[][genre]" class="" id="album__genre_rap" value="rap" type="radio" /><label for="album__genre_rap">rap</label><br />\n<input name="album[][genre]" class="" id="album__genre_rock" value="rock" type="radio" /><label for="album__genre_rock">rock</label><br />\n<input name="album[][genre]" class="" id="album__genre_country" value="country" type="radio" /><label for="album__genre_country">country</label><br /></div>),
      radio_buttons("album[]", "genre", %w[rap rock country], {}, { :index => nil })
    )
  end
  
  def test_radio_buttons_with_selected_nil
    @post = Post.new
    @post.category = "<mus>"
    assert_dom_equal(
      %(<div class="form_fu_radios"><input name="post[category]" class="" id="post_category_abe" value="abe" type="radio" /><label for="post_category_abe">abe</label><br />\n<input name="post[category]" class="" id="post_category_&lt;mus&gt;" value="&lt;mus&gt;" type="radio" /><label for="post_category_&lt;mus&gt;">&lt;mus&gt;</label><br />\n<input name="post[category]" class="" id="post_category_hest" value="hest" type="radio" /><label for="post_category_hest">hest</label><br /></div>),
      radio_buttons("post", "category", %w( abe <mus> hest ), :selected => nil)
    )
  end
  
  
end
