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

require_relative 'fixtures/decorator.rb'
require_relative 'fixtures/active_record.rb'
require_relative 'fixtures/custom_collection'
require_relative 'fixtures/base_field.rb'
require_relative 'fixtures/base_interface.rb'
require_relative 'fixtures/base_object.rb'
require_relative 'fixtures/reaction_decorator.rb'
require_relative 'fixtures/reaction_type.rb'
require_relative 'fixtures/verified_comment_decorator'
require_relative 'fixtures/unverified_comment_decorator'
require_relative 'fixtures/comment_type.rb'
require_relative 'fixtures/icon.rb'
require_relative 'fixtures/file_type.rb'
require_relative 'fixtures/image_decorator.rb'
require_relative 'fixtures/place_holder_image_decorator.rb'
require_relative 'fixtures/image_type.rb'
require_relative 'fixtures/missing_decorator.rb'
require_relative 'fixtures/missing_type.rb'
require_relative 'fixtures/post_decorator'
require_relative 'fixtures/post_type.rb'
require_relative 'fixtures/blog_decorator.rb'
require_relative 'fixtures/blog_type.rb'
require_relative 'fixtures/query.rb'
require_relative 'fixtures/schema.rb'
