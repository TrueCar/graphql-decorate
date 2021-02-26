# frozen_string_literal: true
module GraphQL
  module Decorate
    class TypeAttributes
      attr_reader :type

      def initialize(type)
        @type = type
      end

      def decorator_class
        get_attribute(:decorator_class)
      end

      def decorator_evaluator
        get_attribute(:decorator_evaluator)
      end

      def decorator_context_evaluator
        get_attribute(:decorator_context_evaluator)
      end

      def unresolved_type
        unresolved_type? ? type : nil
      end

      def unresolved_type?
        type.respond_to?(:resolve_type)
      end

      def resolved_type?
        !unresolved_type?
      end

      def connection?
        resolved_type? && type.respond_to?(:node_type)
      end

      private

      def get_attribute(name)
        if connection?
          type.node_type.respond_to?(name) && type.node_type.public_send(name)
        elsif resolved_type?
          type.respond_to?(name) && type.public_send(name)
        end
      end
    end
  end
end
