# frozen_string_literal: true
module GraphQL
  module Decorate
    # Handles decorating an object given its current field context.
    class ObjectDecoration < Decoration
      # Resolve the object with decoration.
      # @return [Object] Decorated object if possible, otherwise the original object.
      def decorate
        super
        GraphQL::Decorate.configuration.evaluate_decorator.call(decorator_class, object, decorator_context)
      end

      private

      def decorator_context
        default_decorator_context.merge(unscoped_decoration_context, scoped_decoration_context)
      end

      def unscoped_decoration_context
        decorator_context_evaluator ? decorator_context_evaluator.call(object, field_context) : {}
      end

      def scoped_decoration_context
        new_scoped_decorator_context = scoped_decorator_context_evaluator ? scoped_decorator_context_evaluator.call(object, field_context) : {}
        existing_scoped_decorator_context = field_context.context[:scoped_decorator_context] || {}
        scoped_decorator_context = existing_scoped_decorator_context.merge(new_scoped_decorator_context)
        field_context.context.scoped_set!(:scoped_decorator_context, scoped_decorator_context)
        scoped_decorator_context
      end
    end
  end
end
