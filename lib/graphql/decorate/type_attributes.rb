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

      # @return [Boolean] True if the type can be decorated, false otherwise
      def decoratable?
        !!(decorator_class || decorator_evaluator || unresolved_type?)
      end

      # @return [Class, nil] Decorator class for the type if available
      def decorator_class
        get_attribute(:decorator_class)
      end

      # @return [Proc, nil] Decorator evaluator for the type if available
      def decorator_evaluator
        get_attribute(:decorator_evaluator)
      end

      # @return [Proc, nil] Decorator metadata evaluator for the type if available
      def decorator_metadata
        get_attribute(:decorator_metadata)
      end

      # @return [GraphQL::Schema::Object, nil] Decorator evaluator for the type if available
      def unresolved_type
        unresolved_type? ? type : nil
      end

      # @return [Boolean] True if type is not yet resolved, false if it is resolved
      def unresolved_type?
        type.respond_to?(:kind) && [GraphQL::TypeKinds::INTERFACE, GraphQL::TypeKinds::UNION].include?(type.kind)
      end

      # @return [Boolean] True if type is resolved, false if it is not resolved
      def resolved_type?
        !unresolved_type?
      end

      private

      def get_attribute(name)
        type.respond_to?(name) ? type.public_send(name) : nil
      end
    end
  end
end
