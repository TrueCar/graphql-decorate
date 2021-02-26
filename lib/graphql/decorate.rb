require 'graphql'
require_relative 'decorate/version'
require_relative 'decorate/configuration'
require_relative 'decorate/object_integration'
require_relative 'decorate/field_integration'
require_relative 'decorate/field_extension'
require_relative 'decorate/resolution'
require_relative 'decorate/type_attributes'

module GraphQL
  module Decorate
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
  end
end
