# frozen_string_literal: true
class BlogDecorator < Decorator
  def name
    object[:name]
  end

  def title
    object[:name].downcase.split(' ').join('-')
  end

  def active_status
    context[:active]
  end

  def owner
    context[:owner]
  end
end
