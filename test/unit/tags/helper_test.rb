require File.expand_path('../../test_helper', File.dirname(__FILE__))

class HelperTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:method_name }}'
    )
    assert_equal 'method_name', tag.identifier
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:method-name }}'
    )
    assert_equal 'method-name', tag.identifier
  end
  
  def test_initialize_tag_with_parameters
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:method_name:param1:param2 }}'
    )
    assert_equal 'method_name', tag.identifier
    assert_equal ['param1', 'param2'], tag.params
  end

  def test_initialize_tag_with_complex_parameters
    assert tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{ cms:helper:method_name:param1:"param:2" }}'
    )
    assert_equal 'method_name', tag.identifier
    assert_equal ['param1', 'param:2'], tag.params

  end
  
  def test_initialize_tag_failure
    [
      '{{cms:helper}}',
      '{{cms:not_helper:method_name}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::Helper.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:method_name}}'
    )
    assert_equal "<%= method_name() %>", tag.content
    assert_equal "<%= method_name() %>", tag.render
    
    tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
      cms_pages(:default), '{{cms:helper:method_name:param1:param2}}'
    )
    assert_equal "<%= method_name('param1', 'param2') %>", tag.content
    assert_equal "<%= method_name('param1', 'param2') %>", tag.render
  end
  
  def test_protected_methods_with_irb_enabled
    ComfortableMexicanSofa.config.allow_irb = true
    ComfortableMexicanSofa::Tag::Helper::PROTECTED_METHODS.each do |method|
      tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
        cms_pages(:default), "{{ cms:helper:#{method}:Rails.env }}"
      )
      assert_equal "<%= #{method}('Rails.env') %>", tag.content
      assert_equal "<%= #{method}('Rails.env') %>", tag.render
    end
  end
  
  def test_protected_methods_with_irb_disabled
    ComfortableMexicanSofa::Tag::Helper::PROTECTED_METHODS.each do |method|
      tag = ComfortableMexicanSofa::Tag::Helper.initialize_tag(
        cms_pages(:default), "{{ cms:helper:#{method}:Rails.env }}"
      )
      assert_equal "<%= #{method}('Rails.env') %>", tag.content
      assert_equal nil, tag.render
    end
  end
  
end
