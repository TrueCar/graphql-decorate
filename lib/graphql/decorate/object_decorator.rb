# frozen_string_literal: true

module GraphQL
  module Decorate
    # Handles decorating an object given its current field context.
    class ObjectDecorator
      # @param object [Object] Object being decorated.
      # @param field_context [GraphQL::Decorate::FieldContext] Current GraphQL field context and options.
      def initialize(object, field_context)
        @object = object
        @field_context = field_context
        @default_decorator_context = { graphql: true }
      end

      # Resolve the object with decoration.
      # @return [Object] Decorated object if possible, otherwise the original object.
      def decorate
        if decorator_class
          GraphQL::Decorate.configuration.evaluate_decorator.call(decorator_class, object, decorator_context)
        else
          object
        end
      end

      private

      attr_reader :object, :field_context, :default_decorator_context

      def decorator_class
        if field_context.options[:decorator_class]
          field_context.options[:decorator_class]
        elsif field_context.options[:decorator_evaluator]
          field_context.options[:decorator_evaluator].call(object)
        else
          resolve_decorator_class
        end
      end

      def decorator_context_evaluator
        field_context.options[:decorator_context_evaluator] || resolve_decorator_context_evaluator
      end

      private

      def evaluate_decoration_context
        decorator_context_evaluator ? decorator_context_evaluator.call(object) : {}
      end

      def decorator_context
        evaluate_decoration_context.merge(default_decorator_context)
      end

      def resolve_decorator_class
        type = resolve_type
        if type.respond_to?(:decorator_class) && type.decorator_class
          type.decorator_class
        end
      end

      def resolve_decorator_context_evaluator
        type = resolve_type
        if type.respond_to?(:decorator_context_evaluator) && type.decorator_context_evaluator
          type.decorator_context_evaluator
        end
      end

      def resolve_type
        field_context.options[:unresolved_type]&.resolve_type(object, field_context.context)
      end
    end
  end
end
