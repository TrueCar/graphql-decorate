# frozen_string_literal: true

module GraphQL
  module Decorate
    # Wraps current value, parents, and graphql_context and extracts relevant decoration data to resolve the field.
    class UndecoratedField
      # @return [Object] Value to be decorated
      attr_reader :value

      # @param value [Object] Value to be decorated
      # @param type [GraphQL::Schema::Object] Type class of value to be decorated
      # @param graphql_context [GraphQL::Query::Context] Current query graphql_context
      def initialize(value, type, graphql_context, index = nil)
        @value = value
        @type = type
        @type_attributes = GraphQL::Decorate::TypeAttributes.new(type)
        @graphql_context = graphql_context
        @default_metadata = { graphql: true }
        @path = graphql_context[:current_path].dup
        @path << index if index
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

      attr_reader :type, :type_attributes, :graphql_context, :default_metadata, :path

      def unscoped_metadata
        unscoped_metadata_proc&.call(value, graphql_context) || {}
      end

      def scoped_metadata
        insert_scoped_metadata(new_scoped_metadata)
      end

      def new_scoped_metadata
        scoped_metadata_proc&.call(value, graphql_context) || {}
      end

      # rubocop:disable Metrics/AbcSize
      def insert_scoped_metadata(metadata)
        # Save metadata at each level in the path of the current execution.
        # If a field's direct parent does not have metadata then it will
        # use the next highest metadata in the tree that matches its path.
        scoped_metadata = graphql_context[:scoped_decorator_metadata] ||= {}
        prev_value = {}

        path[0...-1].each do |step|
          # Write the parent's metadata to the child if it doesn't already exist
          scoped_metadata[step] = { value: prev_value, children: {} } unless scoped_metadata[step]
          # Update the next parent's metadata to include anything at the current level
          prev_value = prev_value.merge(scoped_metadata[step][:value])
          # Move to the child fields and repeat
          scoped_metadata = scoped_metadata[step][:children]
        end

        # The last step in the path is the current field, merge in new metadata from
        # the field itself and return it.
        merged_metadata = { value: prev_value.merge(metadata), children: {} }
        scoped_metadata[path[-1]] = merged_metadata
        merged_metadata[:value]
      end
      # rubocop:enable Metrics/AbcSize

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
            if type.respond_to?(:resolve_type)
              GraphQL::Decorate::TypeAttributes.new(type.resolve_type(value, graphql_context))
            else
              graphql_context.schema.resolve_type(type, value, graphql_context)
            end
          end
        end
      end
    end
  end
end
