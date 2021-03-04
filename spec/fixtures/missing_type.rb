# frozen_string_literal: true
class MissingType < BaseObject
  decorate_with MissingDecorator

  field :missing, String, null: false
end
