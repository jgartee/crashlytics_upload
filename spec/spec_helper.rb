require "gimme"
require "simplecov"

SimpleCov.start do
    add_filter "/spec"
end

require_relative  '../upload_file_tracker'
require 'yaml'

RSpec.configure do |config|
    config.mock_framework = Gimme::RSpecAdapter
end