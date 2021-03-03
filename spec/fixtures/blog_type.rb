# frozen_string_literal: true
class BlogType < BaseObject
  decorate_with BlogDecorator
  decorator_context do |blog|
    {
      active: blog[:active]
    }
  end

  scoped_decorator_context do |_blog|
    {
      owner: 'Bill Billerson'
    }
  end

  field :owner, String, null: true
  field :active_status, Boolean, null: false
  field :name, String, null: false
  field :title, String, null: false
  field :posts, [PostType], null: false
  field :post_connection, PostType.connection_type, null: false

  def posts
    [{ first_name: 'Bob', last_name: 'Boberson', published: true }, { first_name: 'Tod', last_name: 'Toderson', published: false }]
  end

  def post_connection
    posts
  end
end
