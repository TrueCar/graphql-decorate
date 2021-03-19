# frozen_string_literal: true

class UnauthenticatedUser < BaseObject
  field :generated_username, String, null: false

  def generated_username
    'Unauthenticated User'
  end
end
