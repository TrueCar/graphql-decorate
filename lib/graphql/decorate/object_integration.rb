module GraphQL
  module Decorate
    module ObjectIntegration
      # Decorate the type with a decorator class.
      # @param klass [Class] Class the object should be decorated with.
      def decorate_with(klass)
        @decorator_class = klass
      end

      # Dynamically choose the decorator class based on the underlying object.
      # @yield [object] Gives the underlying object to the block.
      # @return [Proc] Proc to evaluate decorator class. Proc should return a decorator class.
      def decorate_when(&block)
        @decorator_evaluator = block
      end

      # Pass additional data to the decorator context (if supported).
      # @yield [object] Gives the underlying object to the block.
      # @return [Proc] Proc to evaluate decorator context. Proc should return Hash.
      def decorator_context(&block)
        @decorator_context_evaluator = block
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
      def decorator_context_evaluator
        @decorator_context_evaluator
      end
    end
  end
end
