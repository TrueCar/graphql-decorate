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
        extension_options = get_extension_options(field_type)
        extension(GraphQL::Decorate::FieldExtension, extension_options) if extension_options
      end

      private

      def get_extension_options(type)
        type_attributes = GraphQL::Decorate::TypeAttributes.new(type)
        return unless type_attributes.decoratable?

        {
          decorator_class: type_attributes.decorator_class,
          decorator_evaluator: type_attributes.decorator_evaluator,
          decorator_metadata: type_attributes.decorator_metadata,
          unresolved_type: type_attributes.unresolved_type
        }
      end
    end
  end
end
