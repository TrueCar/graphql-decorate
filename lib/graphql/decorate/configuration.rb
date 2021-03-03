# frozen_string_literal: true

module GraphQL
  module Decorate
    # Allows overriding default decoration and custom collection class behavior.
    class Configuration
      # @return [Proc] Proc that decorates a given object and context with a given decorator class.
      attr_reader :evaluate_decorator

      # @return [Array] Controls which classes are treated as collections to be decorated.
      attr_accessor :custom_collection_classes

      def initialize
        @evaluate_decorator = lambda do |decorator_class, object, context|
          decorator_class.decorate(object, context: context)
        end
        @custom_collection_classes = []
      end

      # @yield [decorator_class, object, decorator_context] Override default decoration behavior with the given block.
      # @return [Void]
      def decorate(&block)
        @evaluate_decorator = block
      end
    end
  end
end
