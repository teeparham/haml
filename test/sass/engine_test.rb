#!/usr/bin/env ruby

require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/sass'
require 'sass/engine'

class SassEngineTest < Test::Unit::TestCase
  EXCEPTION_MAP = {
    "!a = 1 + " => 'Constant arithmetic error: "1 +"',
    "!a = 1 + 2 +" => 'Constant arithmetic error: "1 + 2 +"',
    "!a = #aaa - a" => 'Undefined operation: "#afafaf minus a"',
    "!a = #aaa / a" => 'Undefined operation: "#afafaf div a"',
    "!a = #aaa * a" => 'Undefined operation: "#afafaf times a"',
    "!a = #aaa % a" => 'Undefined operation: "#afafaf mod a"',
    "!a = 1 - a" => 'Undefined operation: "1 minus a"',
    "!a = 1 * a" => 'Undefined operation: "1 times a"',
    "!a = 1 / a" => 'Undefined operation: "1 div a"',
    "!a = 1 % a" => 'Undefined operation: "1 mod a"',
    ":" => 'Invalid attribute: ":"',
    ": a" => 'Invalid attribute: ": a"',
    ":= a" => 'Invalid attribute: ":= a"',
    "a\n  :b" => 'Invalid attribute: ":b "',
    ":a" => 'Attributes aren\'t allowed at the root of a document.',
    "!" => 'Invalid constant: "!"',
    "!a" => 'Invalid constant: "!a"',
    "! a" => 'Invalid constant: "! a"',
    "!a b" => 'Invalid constant: "!a b"',
    "a\n\t:b c" => "Illegal Indentation: Only two space characters are allowed as tabulation.",
    "a\n :b c" => "Illegal Indentation: Only two space characters are allowed as tabulation.",
    "a\n    :b c" => "Illegal Indentation: Only two space characters are allowed as tabulation.",
  }
  
  def test_basic_render
    renders_correctly "basic"
  end
  
  def test_exceptions
    EXCEPTION_MAP.each do |key, value|
      begin
        Sass::Engine.new(key).render
      rescue Sass::SyntaxError => err
        assert_equal(value, err.message)
      else
        assert(false, "Exception not raised for '#{key}'!")
      end
    end
  end

  def test_exception_line
    to_render = "rule\n  :attr val\n  :broken\n"
    begin
      Sass::Engine.new(to_render).render
    rescue Sass::SyntaxError => err
      assert_equal(3, err.sass_line)
    else
      assert(false, "Exception not raised for '#{to_render}'!")
    end
  end
  
  private

  def renders_correctly(name)
    sass_file  = load_file(name, "sass")
    css_file   = load_file(name, "css")
    css_result = Sass::Engine.new(sass_file).render
    #puts css_result.collect { |a| a.inspect }.join("\n  ")
    assert_equal css_file, css_result
  end

  def load_file(name, type = "sass")
    @result = ''
    File.new(File.dirname(__FILE__) + "/#{type == 'sass' ? 'templates' : 'results'}/#{name}.#{type}").each_line { |l| @result += l }
    @result
  end
end
