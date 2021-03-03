# frozen_string_literal: true

module GraphQL
  module Decorate
    # Handles decorating an value at runtime given its current field context.
    class Decoration
      # Resolve the value with decoration.
      # @param value [Object] Value being decorated.
      # @param parent_value [Object] Value of the resolved parent.
      # @param parent_class [GraphQL::Schema::Object] Type class of the resolved parent.
      # @param field_context [GraphQL::Decorate::FieldContext] Current GraphQL field context and options.
      # @return [Object] Decorated value if possible, otherwise the original value.
      def self.decorate(value, parent_value, parent_class, field_context)
        new(value, parent_value, parent_class, field_context).decorate
      end

      # @param value [Object] Value being decorated.
      # @param parent_value [Object] Value of the resolved parent.
      # @param parent_class [GraphQL::Schema::Object] Type class of the resolved parent.
      # @param field_context [GraphQL::Decorate::FieldContext] Current GraphQL field context and options.
      def initialize(value, parent_value, parent_class, field_context)
        @value = value
        @parent_value = parent_value
        @parent_type_attributes = GraphQL::Decorate::TypeAttributes.new(parent_class)
        @field_context = field_context
        @default_decorator_context = { graphql: true }
      end

      # @return [Object] Decorated value if possible, otherwise the original value.
      def decorate
        return value unless decorator_class

        GraphQL::Decorate.configuration.evaluate_decorator.call(decorator_class, value, decorator_context)
      end

      private

      attr_reader :value, :parent_value, :parent_type_attributes, :field_context, :default_decorator_context

      def decorator_context
        default_decorator_context.merge(unscoped_decoration_context, scoped_decoration_context)
      end

      def unscoped_decoration_context
        decorator_context_evaluator ? decorator_context_evaluator.call(value, field_context) : {}
      end

      def scoped_decoration_context
        new_scoped_decoration_contexts = [
          parent_type_attributes.scoped_decorator_context_evaluator ? parent_type_attributes.scoped_decorator_context_evaluator.call(parent_value, field_context) : {},
          scoped_decorator_context_evaluator ? scoped_decorator_context_evaluator.call(value, field_context) : {}
        ]
        new_scoped_decoration_context = {}.merge(*new_scoped_decoration_contexts)
        existing_scoped_decoration_context = field_context.context[:scoped_decorator_context] || {}
        resulting_scoped_decorator_context = existing_scoped_decoration_context.merge(new_scoped_decoration_context)
        field_context.context.scoped_set!(:scoped_decorator_context, resulting_scoped_decorator_context)
        resulting_scoped_decorator_context
      end

      def decorator_class
        if field_context.options[:decorator_class]
          field_context.options[:decorator_class]
        elsif field_context.options[:decorator_evaluator]
          field_context.options[:decorator_evaluator].call(value)
        elsif resolve_decorator_class
          resolve_decorator_class
        elsif resolve_decorator_evaluator
          resolve_decorator_evaluator.call(value)
        end
      end

      def decorator_context_evaluator
        field_context.options[:decorator_context_evaluator] || resolve_decorator_context_evaluator
      end

      def scoped_decorator_context_evaluator
        field_context.options[:scoped_decorator_context_evaluator] || resolve_scoped_decorator_context_evaluator
      end

      def resolve_decorator_class
        type = resolve_type
        if type.respond_to?(:decorator_class) && type.decorator_class
          type.decorator_class
        end
      end

      def resolve_decorator_evaluator
        type = resolve_type
        if type.respond_to?(:decorator_evaluator) && type.decorator_evaluator
          type.decorator_evaluator
        end
      end

      def resolve_decorator_context_evaluator
        type = resolve_type
        if type.respond_to?(:decorator_context_evaluator) && type.decorator_context_evaluator
          type.decorator_context_evaluator
        end
      end

      def resolve_scoped_decorator_context_evaluator
        type = resolve_type
        if type.respond_to?(:scoped_decorator_context_evaluator) && type.scoped_decorator_context_evaluator
          type.scoped_decorator_context_evaluator
        end
      end

      def resolve_type
        field_context.options[:unresolved_type]&.resolve_type(value, field_context.context)
      end
    end
  end
end
