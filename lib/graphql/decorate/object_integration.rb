# frozen_string_literal: true

module GraphQL
  module Decorate
    # Extends GraphQL::Schema::Object classes with methods to set the desired decorator class and context.
    module ObjectIntegration
      # Decorate the type with a decorator class.
      # @param klass [Class] Class the object should be decorated with.
      def decorate_with(klass = nil, &block)
        @decorator_class = klass
        @decorator_evaluator = block
      end

      # Pass additional data to the decorator context (if supported).
      # @yield [object] Gives the underlying object to the block.
      # @return [Proc] Proc to evaluate decorator context. Proc should return Hash.
      def decorate_metadata
        @decorator_metadata ||= GraphQL::Decorate::Metadata.new
        yield(@decorator_metadata)
      end

      # @return [Class, nil] Gets the currently set decorator class.
      attr_reader :decorator_class

      # @return [Proc, nil] Gets the currently set decorator evaluator.
      attr_reader :decorator_evaluator

      attr_reader :decorator_metadata
    end
  end
end
