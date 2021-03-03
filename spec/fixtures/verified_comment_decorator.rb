# frozen_string_literal: true
class VerifiedCommentDecorator < Decorator
  def disclaimer
    'This user is verified'
  end

  def blog_owner
    context[:owner]
  end

  def post_owner
    context[:post_owner]
  end
end
