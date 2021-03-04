# frozen_string_literal: true

module GraphQL
  module Decorate
    # Handles decorating an value at runtime given its current field.
    class Decoration
      # Resolve the undecorated_field.value with decoration.
      # @param undecorated_field [GraphQL::Decorate::UndecoratedField]
      # @return [Object] Decorated undecorated_field.value if possible, otherwise the original undecorated_field.value.
      def self.decorate(undecorated_field)
        new(undecorated_field).decorate
      end

      # @param undecorated_field [GraphQL::Decorate::UndecoratedField]
      def initialize(undecorated_field)
        @undecorated_field = undecorated_field
      end

      # @return [Object] Decorated undecorated_field.value if possible, otherwise the original undecorated_field.value.
      def decorate
        if undecorated_field.decorator_class
          GraphQL::Decorate.configuration.evaluate_decorator.call(undecorated_field.decorator_class, undecorated_field.value, undecorated_field.decorator_context)
        else
          undecorated_field.value
        end
      end

      private

      attr_reader :undecorated_field
    end
  end
end
