# frozen_string_literal: true

module GraphQL
  module Decorate
    # Wraps a GraphQL::Pagination::ConnectionWrapper object to decorate values after pagination is applied.
    class ConnectionWrapper
      # @param connection [GraphQL::Pagination::Connection] ConnectionWrapper being decorated
      # @param node_type [GraphQL::Schema::Object] Type class of the connection's node
      # @param context [GraphQL::Query::Context] Current query context
      def self.wrap(connection, node_type, context)
        @connection_class = connection.class
        new(connection, node_type, context)
      end

      # @return [GraphQL::Pagination::Connection] ConnectionWrapper being decorated
      attr_reader :connection

      # @param connection [GraphQL::Pagination::Connection] ConnectionWrapper being decorated
      # # @param node_type [GraphQL::Schema::Object] Type class of the connection's node
      # @param context [GraphQL::Query::Context] Current query context
      def initialize(connection, node_type, context)
        @connection = connection
        @node_type = node_type
        @context = context
      end

      # @return [Array] Decorated nodes after pagination is applied
      def nodes
        nodes = @connection.nodes
        nodes.map do |node|
          unresolved_field = GraphQL::Decorate::UndecoratedField.new(node, node_type, connection.parent,
                                                                     connection.field.owner, context)
          GraphQL::Decorate::Decoration.decorate(unresolved_field)
        end
      end

      # @see nodes
      # @return [Array] Decorated nodes after pagination is applied
      def edge_nodes
        nodes
      end

      class << self
        private

        def method_missing(symbol, *args, &block)
          @connection_class.send(symbol, *args, &block) || super
        end

        def respond_to_missing?(method, include_private = false)
          @connection_class.respond_to?(method, include_private)
        end
      end

      private

      attr_reader :node_type, :context

      def method_missing(symbol, *args, &block)
        @connection.send(symbol, *args, &block) || super
      end

      def respond_to_missing?(method, include_private = false)
        @connection.respond_to?(method, include_private)
      end
    end
  end
end
