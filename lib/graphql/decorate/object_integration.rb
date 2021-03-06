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
      def decorator_metadata(&block)
        @metadata_evaluator = block
      end

      # Pass additional data to the decorator context (if supported).
      # All child fields will also receive the same context.
      # @yield [object] Gives the underlying object to the block.
      # @return [Proc] Proc to evaluate decorator context. Proc should return Hash.
      def scoped_decorator_metadata(&block)
        @scoped_metadata_evaluator = block
      end

      # @return [Class, nil] Gets the currently set decorator class.
      def decorator_class
        @decorator_class
      end

      # @return [Proc, nil] Gets the currently set decorator evaluator.
      def decorator_evaluator
        @decorator_evaluator
      end

      # @return [Proc, nil] Gets the currently set decorator context evaluator.
      def metadata_evaluator
        @metadata_evaluator
      end

      # @return [Proc, nil] Gets the currently set scoped decorator context evaluator.
      def scoped_metadata_evaluator
        @scoped_metadata_evaluator
      end
    end
  end
end
