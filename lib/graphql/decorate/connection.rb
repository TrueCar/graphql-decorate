# frozen_string_literal: true
module GraphQL
  module Decorate
    class Connection
      attr_reader :connection, :field_context

      def initialize(connection, field_context)
        @connection = connection
        @field_context = field_context
      end

      def nodes
        nodes = @connection.nodes
        nodes.map { |node| GraphQL::Decorate::Object.new(node, field_context).decorate }
      end

      def edge_nodes
        nodes
      end

      class << self
        def method_missing(symbol, *args, &block)
          @connection.class.send(symbol, *args, &block)
        end

        def respond_to_missing?(method, include_private = false)
          @connection.class.respond_to_missing(method, include_private)
        end
      end

      def method_missing(symbol, *args, &block)
        @connection.send(symbol, *args, &block)
      end

      def respond_to_missing?(method, include_private = false)
        @connection.respond_to_missing(method, include_private)
      end
    end
  end
end
