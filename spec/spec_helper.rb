# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  minimum_coverage 100
end

require 'bundler/setup'
require 'graphql/decorate'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.expose_dsl_globally = true
end

require_relative 'fixtures/decorator'
require_relative 'fixtures/active_record'
require_relative 'fixtures/custom_collection'
require_relative 'fixtures/base_field'
require_relative 'fixtures/base_interface'
require_relative 'fixtures/base_object'
require_relative 'fixtures/reaction_decorator'
require_relative 'fixtures/reaction_type'
require_relative 'fixtures/verified_comment_decorator'
require_relative 'fixtures/unverified_comment_decorator'
require_relative 'fixtures/comment_type'
require_relative 'fixtures/icon'
require_relative 'fixtures/file_type'
require_relative 'fixtures/image_decorator'
require_relative 'fixtures/place_holder_image_decorator'
require_relative 'fixtures/image_type'
require_relative 'fixtures/missing_decorator'
require_relative 'fixtures/missing_type'
require_relative 'fixtures/post_decorator'
require_relative 'fixtures/post_type'
require_relative 'fixtures/blog_decorator'
require_relative 'fixtures/blog_type'
require_relative 'fixtures/query'
require_relative 'fixtures/schema'
