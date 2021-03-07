# frozen_string_literal: true

module GraphQL
  module Decorate
    # Contains methods to evaluate different types of metadata
    class Metadata
      # @return [Proc]
      attr_reader :unscoped_proc

      # @return [Proc]
      attr_reader :scoped_proc

      def initialize
        @unscoped_proc = nil
        @scoped_proc = nil
      end

      # @yield [object, graphql_context] Evaluate metadata for a single resolved field
      def unscoped(&block)
        @unscoped_proc = block
      end

      # @yield [object, graphql_context] Evaluate metadata for a resolved field and all child fields
      def scoped(&block)
        @scoped_proc = block
      end
    end
  end
end
