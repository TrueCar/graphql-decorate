# frozen_string_literal: true
module GraphQL
  module Decorate
    # Wraps a GraphQL::Pagination::ConnectionWrapper object to decorate values after pagination is applied.
    class ConnectionWrapper
      # @return [GraphQL::Pagination::Connection] ConnectionWrapper being decorated
      attr_reader :connection

      # @return [GraphQL::Decorate::FieldContext] Current field context
      attr_reader :field_context

      def initialize(connection, field_context)
        @connection = connection
        @field_context = field_context
      end

      # @return [Array] Decorated nodes after pagination is applied
      def nodes
        nodes = @connection.nodes
        nodes.map { |node| GraphQL::Decorate::Decoration.decorate(node, connection.parent, connection.field.owner, field_context) }
      end

      # @see nodes
      # @return [Array] Decorated nodes after pagination is applied
      def edge_nodes
        nodes
      end

      class << self
        private

        def method_missing(symbol, *args, &block)
          @connection.class.send(symbol, *args, &block) || super
        end

        def respond_to_missing?(method, include_private = false)
          @connection.class.respond_to?(method, include_private)
        end
      end

      private

      def method_missing(symbol, *args, &block)
        @connection.send(symbol, *args, &block) || super
      end

      def respond_to_missing?(method, include_private = false)
        @connection.respond_to?(method, include_private)
      end
    end
  end
end
