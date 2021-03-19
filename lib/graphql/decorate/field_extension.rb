# frozen_string_literal: true

module GraphQL
  module Decorate
    # Extension run after fields are resolved to decorate their value.
    class FieldExtension < GraphQL::Schema::FieldExtension
      include ExtractType

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

      def resolve_decorated_value(value, parent, context)
        type = extract_type(context.to_h[:current_field].type)
        parent_value = extract_parent_value(parent)
        parent_type = extract_parent_type(parent)

        if collection?(value)
          value.each_with_index.map do |item, index|
            decorate(item, type, parent_value, parent_type, context, index)
          end
        else
          decorate(value, type, parent_value, parent_type, context)
        end
      end

      # rubocop:disable Metrics/ParameterLists
      def decorate(value, type, parent_value, parent_type, context, index = nil)
        undecorated_field = GraphQL::Decorate::UndecoratedField.new(value, type, parent_value, parent_type, context,
                                                                    index)
        GraphQL::Decorate::Decoration.decorate(undecorated_field)
      end
      # rubocop:enable Metrics/ParameterLists

      def collection?(value)
        collection_classes.any? { |c| value.is_a?(c) }
      end

      def collection_classes
        klasses = [Array] + GraphQL::Decorate.configuration.custom_collection_classes
        klasses << ::ActiveRecord::Relation if defined?(ActiveRecord::Relation)
        klasses
      end

      def extract_parent_value(parent)
        parent_object = parent.object
        case parent_object
        when GraphQL::Pagination::Connection
          parent_object.parent.respond_to?(:object) ? parent_object.parent.object : parent_object.parent
        when GraphQL::Pagination::Connection::Edge
          parent_object.parent
        else
          parent_object
        end
      end

      def extract_parent_type(parent)
        parent_object = parent.object
        case parent_object
        when GraphQL::Pagination::Connection
          parent_object.field.owner
        when GraphQL::Pagination::Connection::Edge
          nil
        else
          parent_object.class
        end
      end
    end
  end
end
