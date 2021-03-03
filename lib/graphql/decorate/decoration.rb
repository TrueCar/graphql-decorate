# frozen_string_literal: true
module GraphQL
  module Decorate
    class Decoration
      # Resolve the object with decoration.
      # @param object [Object] Object being decorated.
      # @param field_context [GraphQL::Decorate::FieldContext] Current GraphQL field context and options.
      # @return [Object] Decorated object if possible, otherwise the original object.
      def self.decorate(object, field_context)
        new(object, field_context).decorate
      end

      # @param object [Object] Object being decorated.
      # @param field_context [GraphQL::Decorate::FieldContext] Current GraphQL field context and options.
      def initialize(object, field_context)
        @object = object
        @field_context = field_context
        @default_decorator_context = { graphql: true }
      end

      def decorate
        return object unless decorator_class
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

      def scoped_decorator_context_evaluator
        field_context.options[:scoped_decorator_context_evaluator] || resolve_scoped_decorator_context_evaluator
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

      def resolve_scoped_decorator_context_evaluator
        type = resolve_type
        if type.respond_to?(:scoped_decorator_context_evaluator) && type.scoped_decorator_context_evaluator
          type.scoped_decorator_context_evaluator
        end
      end

      def resolve_type
        field_context.options[:unresolved_type]&.resolve_type(object, field_context.context)
      end
    end
  end
end
