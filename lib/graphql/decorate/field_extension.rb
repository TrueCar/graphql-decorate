# frozen_string_literal: true

module GraphQL
  module Decorate
    # Extension run after fields are resolved to decorate their value.
    class FieldExtension < GraphQL::Schema::FieldExtension
      include ExtractType

      # Extension to be called after lazy loading.
      # @param context [GraphQL::Query::Context] The current GraphQL query context.
      # @param value [Object, Array, GraphQL::Schema::Object] The object being decorated. Can
      #   be a schema object if the field hasn't been resolved yet or a connection.
      # @return [Object] Decorated object.
      def after_resolve(context:, value:, **_rest)
        return if value.nil?

        resolve_decorated_value(value, context)
      end

      private

      def resolve_decorated_value(value, context)
        type = extract_type(context.to_h[:current_field].type)

        if collection?(value)
          value.each_with_index.map do |item, index|
            decorate(item, type, context, index)
          end
        else
          decorate(value, type, context)
        end
      end

      def decorate(value, type, context, index = nil)
        undecorated_field = GraphQL::Decorate::UndecoratedField.new(value, type, context, index)
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
