# frozen_string_literal: true

module GraphQL
  module Decorate
    # Wraps a GraphQL::Pagination::ConnectionWrapper object to decorate values after pagination is applied.
    class ConnectionWrapper
      # @return [GraphQL::Pagination::Connection] ConnectionWrapper being decorated
      attr_reader :connection

      # @return [GraphQL::Decorate::UndecoratedField] Current field context
      attr_reader :context
      attr_reader :options

      def initialize(connection, context, options)
        @connection = connection
        @context = context
        @options = options
      end

      # @return [Array] Decorated nodes after pagination is applied
      def nodes
        nodes = @connection.nodes
        nodes.map do |node|
          unresolved_field = GraphQL::Decorate::UndecoratedField.new(node, connection.parent, connection.field.owner, context, options)
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
