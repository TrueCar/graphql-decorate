# frozen_string_literal: true

module GraphQL
  module Decorate
    # Extension run after fields are resolved to decorate their value.
    class FieldExtension < GraphQL::Schema::FieldExtension
      # Extension to be called after lazy loading.
      # @param context [GraphQL::Query::Context] The current GraphQL query context.
      # @param value [Object, GraphQL::Schema::Object, GraphQL::Pagination::Connection] The object being decorated. Can
      #   be a schema object if the field hasn't been resolved yet or a connection.
      # @param object [Object] Object the field is being resolved on.
      # @return [Object, GraphQL::Decorate::ConnectionWrapper] Decorated object.
      def after_resolve(context:, value:, object:, **_rest)
        return if value.nil?

        resolve_decorated_value(value, object, context)
      end

      private

      def resolve_decorated_value(value, parent_object, context)
        type = extract_type(context.to_h[:current_field].type)
        if value.is_a?(GraphQL::Pagination::Connection)
          GraphQL::Decorate::ConnectionWrapper.wrap(value, type, context)
        elsif collection?(value)
          value.map do |item|
            decorate(item, type, parent_object.object, parent_object.class, context)
          end
        else
          decorate(value, type, parent_object.object, parent_object.class, context)
        end
      end

      def decorate(value, type, parent_object, parent_type, context)
        undecorated_field = GraphQL::Decorate::UndecoratedField.new(value, type, parent_object, parent_type, context)
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

      def extract_type(field)
        if field.respond_to?(:of_type)
          extract_type(field.of_type)
        else
          field
        end
      end
    end
  end
end
