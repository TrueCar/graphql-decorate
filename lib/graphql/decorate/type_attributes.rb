# frozen_string_literal: true
module GraphQL
  module Decorate
    # Extracts configured decorator attributes from a GraphQL::Schema::Object type.
    class TypeAttributes
      # @return [GraphQL::Schema::Object] type to extract decorator attributes from
      attr_reader :type

      # @param [GraphQL::Schema::Object] type to extract decorator attributes from
      def initialize(type)
        @type = type
      end

      # @return [Class, nil] Decorator class for the type if available
      def decorator_class
        get_attribute(:decorator_class)
      end

      # @return [Proc, nil] Decorator evaluator for the type if available
      def decorator_evaluator
        get_attribute(:decorator_evaluator)
      end

      # @return [Proc, nil] Decorator context evaluator for the type if available
      def decorator_context_evaluator
        get_attribute(:decorator_context_evaluator)
      end

      # @return [GraphQL::Schema::Object, nil] Decorator evaluator for the type if available
      def unresolved_type
        unresolved_type? ? type : nil
      end

      # @return [Boolean] True if type is not yet resolved, false if it is resolved
      def unresolved_type?
        type.respond_to?(:resolve_type)
      end

      # @return [Boolean] True if type is resolved, false if it is not resolved
      def resolved_type?
        !unresolved_type?
      end

      # @return [Boolean] True if type is a connection, false if it is resolved
      def connection?
        resolved_type? && type.respond_to?(:node_type)
      end

      private

      def get_attribute(name)
        if connection?
          type.node_type.respond_to?(name) && type.node_type.public_send(name)
        elsif resolved_type?
          type.respond_to?(name) ? type.public_send(name) : nil
        end
      end
    end
  end
end
