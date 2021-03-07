# frozen_string_literal: true

module GraphQL
  module Decorate
    # Wraps current value, parents, and graphql_context and extracts relevant decoration data to resolve the field.
    class UndecoratedField
      # @return [Object] Value to be decorated
      attr_reader :value

      # @param value [Object] Value to be decorated
      # @param parent_value [Object] Value of the parent field
      # @param parent_field_type [GraphQL::Schema::Object] Type class of the parent field
      # @param graphql_context [GraphQL::Query::Context] Current query graphql_context
      # @param options [Hash] Options provided to the field extension
      def initialize(value, parent_value, parent_field_type, graphql_context, options)
        @value = value
        @parent_value = parent_value
        @parent_type_attributes = GraphQL::Decorate::TypeAttributes.new(parent_field_type)
        @graphql_context = graphql_context
        @options = options
        @default_metadata = { graphql: true }
      end

      # @return [Class] Decorator class for the current field
      def decorator_class
        resolved_class = options[:decorator_class] || resolve_decorator_class
        return resolved_class if resolved_class

        class_evaluator = options[:decorator_evaluator] || resolve_decorator_evaluator
        class_evaluator&.call(value, graphql_context)
      end

      # @return [Hash] Metadata to be provided to a decorator for the current field
      def metadata
        default_metadata.merge(unscoped_metadata, scoped_metadata)
      end

      private

      attr_reader :options, :graphql_context, :parent_value, :default_metadata, :parent_type_attributes

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

      def existing_scoped_metadata
        graphql_context[:scoped_decorator_metadata] || {}
      end

      def unscoped_metadata_proc
        @unscoped_metadata_proc ||= options[:decorator_metadata]&.unscoped_proc || resolve_unscoped_proc
      end

      def scoped_metadata_proc
        @scoped_metadata_proc ||= options[:decorator_metadata]&.scoped_proc || resolve_scoped_proc
      end

      def resolve_decorator_class
        @resolve_decorator_class ||= resolved_type.respond_to?(:decorator_class) ? resolved_type.decorator_class : nil
      end

      def resolve_decorator_evaluator
        @resolve_decorator_evaluator ||= begin
          resolved_type.respond_to?(:decorator_evaluator) ? resolved_type.decorator_evaluator : nil
        end
      end

      def resolve_unscoped_proc
        @resolve_unscoped_proc ||= begin
          resolved_type.respond_to?(:decorator_metadata) ? resolved_type.decorator_metadata&.unscoped_proc : nil
        end
      end

      def resolve_scoped_proc
        @resolve_scoped_proc ||= begin
          resolved_type.respond_to?(:decorator_metadata) ? resolved_type.decorator_metadata&.scoped_proc : nil
        end
      end

      def resolved_type
        @resolved_type ||= options[:unresolved_type]&.resolve_type(value, graphql_context)
      end
    end
  end
end
