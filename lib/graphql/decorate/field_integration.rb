module GraphQL
  module Decorate
    module FieldIntegration
      # Overridden field initializer
      # @param type [GraphQL::Schema::Object] The type to add the extension to.
      # @return [Void]
      def initialize(type:, **rest, &block)
        super
        field_type = [type].flatten(1).first
        extension_options = get_extension_options(field_type)
        extend_with_decorator(extension_options) if extension_options
      end

      private

      def get_extension_options(type)
        type_attributes = GraphQL::Decorate::TypeAttributes.new(type)
        return unless type_attributes.decorator_class

        {
          decorator_class: type_attributes.decorator_class,
          decorator_evaluator: type_attributes.decorator_evaluator,
          decorator_context_evaluator: type_attributes.decorator_context_evaluator,
          unresolved_type: type_attributes.unresolved_type
        }
      end

      def extend_with_decorator(options)
        extension(GraphQL::Decorate::FieldExtension, options)
        # ext = GraphQL::Decorate::FieldExtension.new(field: self, options: options)
        # @extensions = @extensions.dup
        # @extensions.unshift(ext)
        # @extensions.freeze
      end
    end
  end
end
