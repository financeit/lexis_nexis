# frozen_string_literal: true

require 'pry'
require 'savon/mock/spec_helper'
require 'bundler/setup'
require 'nokogiri'
require 'support/vcr_setup'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Lexis Nexis Credentials
  LexisNexis::LEXIS_NEXIS_CLIENT_ID = ''
  LexisNexis::LEXIS_NEXIS_USERNAME = ''
  LexisNexis::LEXIS_NEXIS_PASSWORD = ''
end
