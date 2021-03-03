class Query < BaseObject
  field :blog, BlogType, null: false

  def blog
    { name: 'My Blog', active: true }
  end
end
