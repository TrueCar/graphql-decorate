# frozen_string_literal: true

require 'graphql'
require_relative 'decorate/version'
require_relative 'decorate/configuration'
require_relative 'decorate/extract_type'
require_relative 'decorate/object_integration'
require_relative 'decorate/field_extension'
require_relative 'decorate/decoration'
require_relative 'decorate/type_attributes'
require_relative 'decorate/undecorated_field'
require_relative 'decorate/metadata'

# Matching the graphql-ruby namespace
module GraphQL
  # Entry point for graphql-decorate. Handles configuration.
  module Decorate
    extend ExtractType

    # @return [Configuration] Returns a new instance of GraphQL::Decorate::Configuration.
    def self.configuration
      @configuration ||= Configuration.new
    end

    # @yield [configuration] Gives the configuration to the block.
    def self.configure
      yield(configuration)
    end

    # @return [Configuration] Resets the configuration to its defaults.
    def self.reset_configuration!
      @configuration = Configuration.new
    end

    # @param schema_defn [GraphQL::Schema] Current schema class
    # @return [nil]
    def self.use(schema_defn)
      schema_defn.types.each do |_name, type|
        next unless type.respond_to?(:fields)

        type.fields.each do |_name, field|
          field_type = extract_type(field.type)
          type_attributes = GraphQL::Decorate::TypeAttributes.new(field_type)
          field.extension(GraphQL::Decorate::FieldExtension) if type_attributes.decoratable?
        end
      end
    end
  end
end
