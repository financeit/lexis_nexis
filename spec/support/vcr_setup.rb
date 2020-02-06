# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), '../fixtures/vcr_cassettes/')
  c.hook_into :webmock
end
