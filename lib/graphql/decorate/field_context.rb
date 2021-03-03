# frozen_string_literal: true

module GraphQL
  module Decorate
    # Wraps current GraphQL::Query::Context and options provided to a field for portability.
    class FieldContext
      # @return [GraphQL::Query::Context] Current GraphQL query context
      attr_reader :context

      # @return [Hash] Options provided to the field being decorated
      attr_reader :options

      def initialize(context, options)
        @context = context
        @options = options
      end
    end
  end
end
