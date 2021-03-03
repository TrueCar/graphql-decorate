# frozen_string_literal: true

class UnverifiedCommentDecorator < Decorator
  def disclaimer
    'This user is not verified'
  end

  def blog_owner
    context[:owner]
  end

  def post_owner
    context[:post_owner]
  end
end
