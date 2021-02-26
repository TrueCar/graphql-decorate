# frozen_string_literal: true
module GraphQL
  module Decorate
    class Resolution
      # @param object [Object] Object being resolved.
      # @param graphql_context [GraphQL::Query::Context] CurrentGraphQL query context.
      # @param extension_options [Hash] Options provided from the field extension.
      def initialize(object, graphql_context, extension_options)
        @object = object
        @graphql_context = graphql_context
        @extension_options = extension_options
        @default_decorator_context = { graphql: true }
      end

      # Resolve the object with decoration.
      # @return [Object] Decorated object if possible, otherwise the original object.
      def resolve
        if decorator_class
          GraphQL::Decorate.configuration.evaluate_decorator.call(decorator_class, object, decorator_context)
        else
          object
        end
      end

      private

      attr_reader :object, :graphql_context, :extension_options, :default_decorator_context

      def decorator_class
        if extension_options[:decorator_class]
          extension_options[:decorator_class]
        elsif extension_options[:decorator_evaluator]
          extension_options[:decorator_evaluator].call(object)
        else
          resolve_decorator_class
        end
      end

      def decorator_context_evaluator
        extension_options[:decorator_context_evaluator] || resolve_decorator_context_evaluator
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
        extension_options[:unresolved_type]&.resolve_type(object, graphql_context)
      end
    end
  end
end
