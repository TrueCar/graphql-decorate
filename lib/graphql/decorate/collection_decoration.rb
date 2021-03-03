# frozen_string_literal: true
module GraphQL
  module Decorate
    class CollectionDecoration < Decoration
      def decorate
        decorated_collection = object.zip(decorator_contexts).map do |item, decorator_context|
          GraphQL::Decorate.configuration.evaluate_decorator.call(decorator_class(item), item, decorator_context)
        end
        set_scoped_decoration_context! if field_context.context[:scoped_collection_decorator_context].empty?
        decorated_collection
      end

      private

      def decorator_contexts
        object.zip(scoped_decoration_contexts).map do |item, scoped_decoration_context|
          default_decorator_context.merge(unscoped_decoration_context(item), scoped_decoration_context)
        end
      end

      def unscoped_decoration_context(item)
        decorator_context_evaluator(item) ? decorator_context_evaluator(item).call(item, field_context) : {}
      end

      def scoped_decoration_contexts
        @scoped_decoration_contexts ||= begin
          field_context.context[:scoped_collection_decorator_context] ||= []
          existing_contexts = [
            field_context.context[:scoped_decorator_context] || {},
            field_context.context[:scoped_collection_decorator_context].shift || {}
          ]
          existing_scoped_decorator_context = {}.merge(*existing_contexts)
          object.map do |item|
            new_scoped_decorator_context = scoped_decorator_context_evaluator(item) ? scoped_decorator_context_evaluator(item).call(item, field_context) : {}
            new_scoped_decorator_context.merge(existing_scoped_decorator_context)
          end
        end
      end

      def set_scoped_decoration_context!
        field_context.context.scoped_set!(:scoped_collection_decorator_context, scoped_decoration_contexts)
      end

      def decorator_class(item)
        if field_context.options[:decorator_class]
          field_context.options[:decorator_class]
        elsif field_context.options[:decorator_evaluator]
          field_context.options[:decorator_evaluator].call(item)
        else
          resolve_decorator_class(item)
        end
      end

      def decorator_context_evaluator(item)
        field_context.options[:decorator_context_evaluator] || resolve_decorator_context_evaluator(item)
      end

      def scoped_decorator_context_evaluator(item)
        field_context.options[:scoped_decorator_context_evaluator] || resolve_scoped_decorator_context_evaluator(item)
      end

      def resolve_decorator_class(item)
        type = resolve_type(item)
        if type.respond_to?(:decorator_class) && type.decorator_class
          type.decorator_class
        end
      end

      def resolve_decorator_context_evaluator(item)
        type = resolve_type(item)
        if type.respond_to?(:decorator_context_evaluator) && type.decorator_context_evaluator
          type.decorator_context_evaluator
        end
      end

      def resolve_scoped_decorator_context_evaluator(item)
        type = resolve_type(item)
        if type.respond_to?(:scoped_decorator_context_evaluator) && type.scoped_decorator_context_evaluator
          type.scoped_decorator_context_evaluator
        end
      end

      def resolve_type(item)
        field_context.options[:unresolved_type]&.resolve_type(item, field_context.context)
      end
    end
  end
end
