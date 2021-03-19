# frozen_string_literal: true

class BlogType < BaseObject
  decorate_with BlogDecorator
  decorate_metadata do |metadata|
    metadata.unscoped do |blog|
      {
        active: blog[:active]
      }
    end

    metadata.scoped do |_blog|
      {
        owner: 'Bill Billerson'
      }
    end
  end

  field :owner, String, null: true
  field :active_status, Boolean, null: false
  field :name, String, null: false
  field :title, String, null: false
  field :posts, [PostType], null: false
  field :post_connection, PostType.connection_type, null: false
  field :user, User, null: false

  def posts
    [{ first_name: 'Bob', last_name: 'Boberson', published: true },
     { first_name: 'Tod', last_name: 'Toderson', published: false }]
  end

  def post_connection
    posts
  end

  def user
    { authenticated: true }
  end
end
