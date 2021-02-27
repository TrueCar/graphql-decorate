# frozen_string_literal: true
module GraphQL
  module Decorate
    class FieldContext
      attr_reader :context, :options

      def initialize(context, options)
        @context = context
        @options = options
      end
    end
  end
end
