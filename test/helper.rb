$LOAD_PATH.unshift(File.expand_path("../../", __FILE__))
require "simplecov"
require "coveralls"

SimpleCov.formatter =SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter 'test/'
end

require "test-unit"
require "mocha/test_unit"
require "fluent/test"
require "fluent/test/driver/output"
require "fluent/test/helpers"

Test::Unit::TestCase.include(Fluent::Test::Helpers)
Test::Unit::TestCase.extend(Fluent::Test::Helpers)
