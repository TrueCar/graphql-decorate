# frozen_string_literal: true
class ReactionType < BaseObject
  decorate_with ReactionDecorator

  field :post_owner, String, null: true
end
