require "bundler/setup"
require "graphql/decorate"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.expose_dsl_globally = true
end

class Decorator
  attr_reader :object, :context

  def initialize(object, context)
    @object = object
    @context = context
  end

  def self.decorate(object, context)
    new(object, context)
  end

  def bar
    "#{@object}bar"
  end

  def baz
    "#{@object}baz"
  end

  class << self
    private

    def method_missing(symbol, *args, &block)
      @connection.class.send(symbol, *args, &block)
    end

    def respond_to_missing?(method, include_private = false)
      @connection.class.respond_to_missing(method, include_private)
    end
  end

  private

  def method_missing(symbol, *args, &block)
    @connection.send(symbol, *args, &block)
  end

  def respond_to_missing?(method, include_private = false)
    @connection.respond_to_missing(method, include_private)
  end
end

class DifferentDecorator
  attr_reader :object

  def self.decorate_differently(object)
    new(object)
  end

  def initialize(object)
    @object = object
  end
end

module ActiveRecord
  class Relation
    def initialize(collection)
      @collection = collection
    end

    def map(&block)
      @collection.map(&block)
    end
  end
end

class CustomCollection
  def initialize(collection)
    @collection = collection
  end

  def map(&block)
    @collection.map(&block)
  end
end

class BaseField < GraphQL::Schema::Field
  include GraphQL::Decorate::FieldIntegration
end

class BaseObject < GraphQL::Schema::Object
  extend GraphQL::Decorate::ObjectIntegration

  field_class BaseField
end

class DecoratedType < BaseObject
  decorate_with Decorator
  decorate_when do |_object|
    Decorator
  end
  decorator_context do |_object|
    {}
  end

  field :bar, String, null: false
end

module BaseInterface
  include GraphQL::Schema::Interface
  field_class BaseField
end

module DecoratedInterface
  include BaseInterface

  field :bar, String, null: false

  definition_methods do
    def resolve_type(_object, _context)
      DecoratedType
    end
  end
end

class DecoratedTypeWithInterface < BaseObject
  implements DecoratedInterface
  decorate_with Decorator

  field :baz, String, null: false
end

class Query < BaseObject
  field :base_field, String, null: false
  field :decorated_object, DecoratedType, null: false
  field :decorated_array, [DecoratedType], null: false
  field :decorated_connection, DecoratedType.connection_type, null: false
  field :decorated_type_with_interface, DecoratedTypeWithInterface, null: false

  def base_field
    'base_field_value'
  end

  def decorated_object
    'foo'
  end

  def decorated_array
    ['foo']
  end

  def decorated_connection
    ['foo', 'bar', 'baz']
  end

  def decorated_type_with_interface
    'foo'
  end
end

class Schema < GraphQL::Schema
  use GraphQL::Backtrace
  query ::Query
end
