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
        if options[:decorator_class]
          options[:decorator_class]
        elsif options[:decorator_evaluator]
          options[:decorator_evaluator].call(value, graphql_context)
        elsif resolve_decorator_class
          resolve_decorator_class
        elsif resolve_decorator_evaluator
          resolve_decorator_evaluator.call(value, graphql_context)
        end
      end

      # @return [Hash] Context to be provided to a decorator for the current field
      def metadata
        default_metadata.merge(unscoped_metadata, scoped_metadata)
      end

      private

      attr_reader :options, :graphql_context, :parent_value, :default_metadata, :parent_type_attributes

      def unscoped_metadata
        metadata_evaluator ? metadata_evaluator.call(value, graphql_context) : {}
      end

      def scoped_metadata
        new_scoped_metadata = {}.merge(
          parent_type_attributes.scoped_metadata_evaluator ? parent_type_attributes.scoped_metadata_evaluator.call(parent_value, graphql_context) : {},
          scoped_metadata_evaluator ? scoped_metadata_evaluator.call(value, graphql_context) : {}
        )
        existing_scoped_metadata = graphql_context[:scoped_decorator_metadata] || {}
        merged_scoped_metadata = existing_scoped_metadata.merge(new_scoped_metadata)
        graphql_context.scoped_set!(:scoped_decorator_metadata, merged_scoped_metadata)
        merged_scoped_metadata
      end

      def metadata_evaluator
        @metadata_evaluator ||= options[:metadata_evaluator] || resolve_metadata_evaluator
      end

      def scoped_metadata_evaluator
        @scoped_metadata_evaluator ||= options[:scoped_metadata_evaluator] || resolve_scoped_metadata_evaluator
      end

      def resolve_decorator_class
        @resolve_decorator_class ||= resolved_type.respond_to?(:decorator_class) && resolved_type.decorator_class
      end

      def resolve_decorator_evaluator
        @resolve_decorator_evaluator ||= resolved_type.respond_to?(:decorator_evaluator) && resolved_type.decorator_evaluator
      end

      def resolve_metadata_evaluator
        @resolve_metadata_evaluator ||= resolved_type.respond_to?(:metadata_evaluator) && resolved_type.metadata_evaluator
      end

      def resolve_scoped_metadata_evaluator
        @resolve_scoped_metadata_evaluator ||= resolved_type.respond_to?(:scoped_metadata_evaluator) && resolved_type.scoped_metadata_evaluator
      end

      def resolved_type
        @resolved_type ||= options[:unresolved_type]&.resolve_type(value, graphql_context)
      end
    end
  end
end
