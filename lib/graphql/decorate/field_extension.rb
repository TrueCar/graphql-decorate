# frozen_string_literal: true

module GraphQL
  module Decorate
    # Extension run after fields are resolved to decorate their value.
    class FieldExtension < GraphQL::Schema::FieldExtension
      # Extension to be called after lazy loading.
      # @param context [GraphQL::Query::Context] The current GraphQL query context.
      # @param value [Object, GraphQL::Schema::Object] The object being decorated. Can be a schema object if the field hasn't been resolved yet.
      # @return [Object, GraphQL::Decorate::ConnectionWrapper] Decorated object.
      def after_resolve(context:, value:, object:, **_rest)
        return if value.nil?

        field_context = GraphQL::Decorate::FieldContext.new(context, options)
        if value.is_a?(GraphQL::Pagination::Connection)
          GraphQL::Decorate::ConnectionWrapper.new(value, field_context)
        elsif collection_classes.any? { |c| value.is_a?(c) }
          value.map do |item|
            GraphQL::Decorate::Decoration.decorate(item, object.object, object.class, field_context)
          end
        else
          GraphQL::Decorate::Decoration.decorate(value, object.object, object.class, field_context)
        end
      end

      private

      def collection_classes
        klasses = [Array] + GraphQL::Decorate.configuration.custom_collection_classes
        klasses << ::ActiveRecord::Relation if defined?(ActiveRecord::Relation)
        klasses
      end
    end
  end
end
