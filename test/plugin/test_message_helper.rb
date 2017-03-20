# coding: utf-8
require "helper"
require "fluent/plugin/logentries_ssl/message_helper.rb"

class MessageHelperTest < Test::Unit::TestCase

  include Fluent::Plugin::LogentriesSSL
  TEST_TOKEN = "aaaa-bbbb-cccc-dddd"

  def generate_parts(str,size, limit)
    MessageHelper.split_record(TEST_TOKEN, "#{TEST_TOKEN} #{str*size} \n", limit)
  end

  test "Large json payload" do
    parts = generate_parts("a", 120, 100)
    assert  parts.size > 1
  end


  test "split multibyte messages" do
    parts = generate_parts("ä", 120, 100)
    assert parts.size > 1
    assert_equal "ä", parts[0].chomp.rstrip[-1]
  end

  test "edges" do
    parts = generate_parts("a",
                           MessageHelper::MAX_SIZE - TEST_TOKEN.size - 3,
                           MessageHelper::MAX_SIZE)
    assert parts.size==1

    parts = generate_parts("a", 1000, 100)
    assert parts.size > 10
  end

end
