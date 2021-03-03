# frozen_string_literal: true

class PostDecorator < Decorator
  def published_status
    context[:published_status]
  end

  def name
    "#{object[:first_name]} #{object[:last_name]}"
  end

  def blog_owner
    context[:owner]
  end

  def post_owner
    context[:post_owner]
  end
end
