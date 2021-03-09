# frozen_string_literal: true

module GraphQL
  module Decorate
    # Wraps current value, parents, and graphql_context and extracts relevant decoration data to resolve the field.
    class UndecoratedField
      # @return [Object] Value to be decorated
      attr_reader :value

      # @param value [Object] Value to be decorated
      # @param type [GraphQL::Schema::Object] Type class of value to be decorated
      # @param parent_value [Object] Value of the parent field
      # @param parent_type [GraphQL::Schema::Object] Type class of the parent field
      # @param graphql_context [GraphQL::Query::Context] Current query graphql_context
      def initialize(value, type, parent_value, parent_type, graphql_context)
        @value = value
        @type_attributes = GraphQL::Decorate::TypeAttributes.new(type)
        @parent_value = parent_value
        @parent_type = parent_type
        @graphql_context = graphql_context
        @default_metadata = { graphql: true }
      end

      # @return [Class] Decorator class for the current field
      def decorator_class
        resolved_class = type_attributes.decorator_class || resolve_decorator_class
        return resolved_class if resolved_class

        class_evaluator = type_attributes.decorator_evaluator || resolve_decorator_evaluator
        class_evaluator&.call(value, graphql_context)
      end

      # @return [Hash] Metadata to be provided to a decorator for the current field
      def metadata
        default_metadata.merge(unscoped_metadata, scoped_metadata)
      end

      private

      attr_reader :type_attributes, :graphql_context, :parent_value, :parent_type, :default_metadata

      def unscoped_metadata
        unscoped_metadata_proc&.call(value, graphql_context) || {}
      end

      def scoped_metadata
        merged_scoped_metadata = existing_scoped_metadata.merge(new_scoped_metadata)
        graphql_context.scoped_set!(:scoped_decorator_metadata, merged_scoped_metadata)
        merged_scoped_metadata
      end

      def new_scoped_metadata
        scoped_metadata = scoped_metadata_proc&.call(value, graphql_context) || {}
        parent_scoped_metadata.merge(scoped_metadata)
      end

      def parent_scoped_metadata
        parent_type_attributes.decorator_metadata&.scoped_proc&.call(parent_value, graphql_context) || {}
      end

      def parent_type_attributes
        GraphQL::Decorate::TypeAttributes.new(parent_type)
      end

      def existing_scoped_metadata
        graphql_context[:scoped_decorator_metadata] || {}
      end

      def unscoped_metadata_proc
        type_attributes.decorator_metadata&.unscoped_proc || resolve_unscoped_proc
      end

      def scoped_metadata_proc
        type_attributes.decorator_metadata&.scoped_proc || resolve_scoped_proc
      end

      def resolve_decorator_class
        resolved_type_attributes&.decorator_class
      end

      def resolve_decorator_evaluator
        resolved_type_attributes&.decorator_evaluator
      end

      def resolve_unscoped_proc
        resolved_type_attributes&.decorator_metadata&.unscoped_proc
      end

      def resolve_scoped_proc
        resolved_type_attributes&.decorator_metadata&.scoped_proc
      end

      def resolved_type_attributes
        @resolved_type_attributes ||= begin
          if type_attributes.unresolved_type?
            GraphQL::Decorate::TypeAttributes.new(type_attributes.type.resolve_type(value, graphql_context))
          end
        end
      end
    end
  end
end
