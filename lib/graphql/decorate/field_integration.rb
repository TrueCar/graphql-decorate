# frozen_string_literal: true

module GraphQL
  module Decorate
    # Extends default field behavior and adds extension to the field if it should be decorated.
    module FieldIntegration
      # Overridden field initializer
      # @param type [GraphQL::Schema::Object] The type to add the extension to.
      # @return [Void]
      def initialize(type:, **rest, &block)
        super
        field_type = [type].flatten(1).first
        type_attributes = GraphQL::Decorate::TypeAttributes.new(field_type)
        extension(GraphQL::Decorate::FieldExtension) if type_attributes.decoratable?
      end
    end
  end
end
