# frozen_string_literal: true
module GraphQL
  module Decorate
    # Extension run after fields are resolved to decorate their value.
    class FieldExtension < GraphQL::Schema::FieldExtension
      # Extension to be called after lazy loading.
      # @param context [GraphQL::Query::Context] The current GraphQL query context.
      # @param value [Object, GraphQL::Schema::Object] The object being decorated. Can be a schema object if the field hasn't been resolved yet.
      # @return [Object, GraphQL::Decorate::ConnectionWrapper] Decorated object.
      def after_resolve(context:, value:, **_rest)
        return if value.nil?

        field_context = GraphQL::Decorate::FieldContext.new(context, options)
        if value.is_a?(GraphQL::Pagination::Connection)
          GraphQL::Decorate::ConnectionWrapper.new(value, field_context)
        elsif collection_classes.any? { |c| value.is_a?(c) }
          value.map { |item| decorate(item, field_context) }
        else
          decorate(value, field_context)
        end
      end

      private

      def collection_classes
        klasses = [Array] + GraphQL::Decorate.configuration.custom_collection_classes
        klasses << ::ActiveRecord::Relation if defined?(ActiveRecord::Relation)
        klasses
      end

      def decorate(object, field_context)
        GraphQL::Decorate::ObjectDecorator.new(object, field_context).decorate
      end
    end
  end
end
