# frozen_string_literal: true

class ReactionType < BaseObject
  decorate_with ReactionDecorator
  scoped_decorator_metadata do |_|
    {
      post_owner: 'Rod'
    }
  end

  field :post_owner, String, null: true
end
