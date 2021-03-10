# frozen_string_literal: true

class ReactionType < BaseObject
  decorate_with ReactionDecorator
  decorate_metadata do |metadata|
    metadata.scoped do |_reaction|
      {
        post_owner: 'Rod'
      }
    end
  end

  field :post_owner, String, null: true
end
