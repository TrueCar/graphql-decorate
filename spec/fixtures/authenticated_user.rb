# frozen_string_literal: true

class AuthenticatedUser < BaseObject
  field :name, String, null: false

  def name
    'Slob Sloberson'
  end
end
