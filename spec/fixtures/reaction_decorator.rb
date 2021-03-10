# frozen_string_literal: true

class ReactionDecorator < Decorator
  def post_owner
    context[:post_owner]
  end
end
