# frozen_string_literal: true

module GraphQL
  module Decorate
    # Extension run after fields are resolved to decorate their value.
    class FieldExtension < GraphQL::Schema::FieldExtension
      # Extension to be called after lazy loading.
      # @param context [GraphQL::Query::Context] The current GraphQL query context.
      # @param value [Object, GraphQL::Schema::Object, GraphQL::Pagination::Connection] The object being decorated. Can
      # be a schema object if the field hasn't been resolved yet or a connection.
      # @return [Object, GraphQL::Decorate::ConnectionWrapper] Decorated object.
      def after_resolve(context:, value:, object:, **_rest)
        return if value.nil?

        if value.is_a?(GraphQL::Pagination::Connection)
          GraphQL::Decorate::ConnectionWrapper.wrap(value, context, options)
        elsif collection?(value)
          value.map do |item|
            decorate(item, object.object, object.class, context, options)
          end
        else
          decorate(value, object.object, object.class, context, options)
        end
      end

      private

      def decorate(item, parent_object, parent_field_type, context, options)
        undecorated_field = GraphQL::Decorate::UndecoratedField.new(item, parent_object, parent_field_type, context,
                                                                    options)
        GraphQL::Decorate::Decoration.decorate(undecorated_field)
      end

      def collection?(value)
        collection_classes.any? { |c| value.is_a?(c) }
      end

      def collection_classes
        klasses = [Array] + GraphQL::Decorate.configuration.custom_collection_classes
        klasses << ::ActiveRecord::Relation if defined?(ActiveRecord::Relation)
        klasses
      end
    end
  end
end
