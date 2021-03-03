# frozen_string_literal: true

class PostType < BaseObject
  decorate_with PostDecorator
  decorator_context do |post|
    {
      published_status: post[:published]
    }
  end

  scoped_decorator_context do |post|
    {
      post_owner: post[:first_name]
    }
  end

  field :owner, String, method: :post_owner, null: false
  field :blog_owner, String, null: true
  field :published_status, Boolean, null: false
  field :first_name, String, null: false
  field :last_name, String, null: false
  field :name, String, null: false
  field :comments, [CommentType], null: false
  field :comment_connection, CommentType.connection_type, null: false
  field :icon, Icon, null: false

  def comments
    [{ verified_user: true, message: 'My comment 1' }, { verified_user: false, message: 'My comment 2' }]
  end

  def comment_connection
    comments
  end

  def first_name
    object[:first_name]
  end

  def last_name
    object[:last_name]
  end

  def icon
    { url: 'https://www.image.com' }
  end
end
