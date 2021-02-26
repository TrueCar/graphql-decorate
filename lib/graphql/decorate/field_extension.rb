# frozen_string_literal: true
module GraphQL
  module Decorate
    class FieldExtension < GraphQL::Schema::FieldExtension
      # Extension to be called after lazy loading.
      # @param context [GraphQL::Query::Context] The current GraphQL query context.
      # @param value [Object, GraphQL::Schema::Object] The object being decorated. Can be a schema object if the field hasn't been resolved yet.
      # @return [Object] Decorated object.
      def after_resolve(context:, value:, **_rest)
        return if value.nil?

        collection = collection_classes.any? { |c| value.is_a?(c) }
        if collection
          value.map { |item| decorate(item, context) }
        else
          decorate(value, context)
        end
      end

      private

      def collection_classes
        klasses = [Array] + GraphQL::Decorate.configuration.custom_collection_classes
        klasses << ::ActiveRecord::Relation if defined?(ActiveRecord::Relation)
        klasses
      end

      def decorate(object, context)
        GraphQL::Decorate::Resolution.new(object, context, options).resolve
      end
    end
  end
end
