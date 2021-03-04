# frozen_string_literal: true

module GraphQL
  module Decorate
    # Wraps current value, parents, and context and extracts relevant decoration data to resolve the field.
    class UndecoratedField
      # @return [Object] Value to be decorated
      attr_reader :value

      # @param value [Object] Value to be decorated
      # @param parent_value [Object] Value of the parent field
      # @param parent_field_type [GraphQL::Schema::Object] Type class of the parent field
      # @param context [GraphQL::Query::Context] Current query context
      # @param options [Hash] Options provided to the field extension
      def initialize(value, parent_value, parent_field_type, context, options)
        @value = value
        @parent_value = parent_value
        @parent_type_attributes = GraphQL::Decorate::TypeAttributes.new(parent_field_type)
        @context = context
        @options = options
        @default_decorator_context = { graphql: true }
      end

      # @return [Class] Decorator class for the current field
      def decorator_class
        if options[:decorator_class]
          options[:decorator_class]
        elsif options[:decorator_evaluator]
          options[:decorator_evaluator].call(value)
        elsif resolve_decorator_class
          resolve_decorator_class
        elsif resolve_decorator_evaluator
          resolve_decorator_evaluator.call(value)
        end
      end

      # @return [Hash] Context to be provided to a decorator for the current field
      def decorator_context
        default_decorator_context.merge(unscoped_decoration_context, scoped_decoration_context)
      end

      private

      attr_reader :options, :context, :parent_value, :default_decorator_context, :parent_type_attributes

      def unscoped_decoration_context
        decorator_context_evaluator ? decorator_context_evaluator.call(value, context) : {}
      end

      def scoped_decoration_context
        new_scoped_decoration_contexts = [
          parent_type_attributes.scoped_decorator_context_evaluator ? parent_type_attributes.scoped_decorator_context_evaluator.call(parent_value, context) : {},
          scoped_decorator_context_evaluator ? scoped_decorator_context_evaluator.call(value, context) : {}
        ]
        new_scoped_decoration_context = {}.merge(*new_scoped_decoration_contexts)
        existing_scoped_decoration_context = context[:scoped_decorator_context] || {}
        resulting_scoped_decorator_context = existing_scoped_decoration_context.merge(new_scoped_decoration_context)
        context.scoped_set!(:scoped_decorator_context, resulting_scoped_decorator_context)
        resulting_scoped_decorator_context
      end

      def decorator_context_evaluator
        options[:decorator_context_evaluator] || resolve_decorator_context_evaluator
      end

      def scoped_decorator_context_evaluator
        options[:scoped_decorator_context_evaluator] || resolve_scoped_decorator_context_evaluator
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
        options[:unresolved_type]&.resolve_type(value, context)
      end
    end
  end
end
