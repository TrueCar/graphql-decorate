# frozen_string_literal: true
class CommentType < BaseObject
  decorate_when do |comment|
    comment[:verified_user] ? VerifiedCommentDecorator : UnverifiedCommentDecorator
  end

  field :post_owner, String, null: false
  field :blog_owner, String, null: true
  field :verified_user, Boolean, null: false
  field :disclaimer, String, null: false
  field :message, String, null: false
  field :reaction, ReactionType, null: false

  def reaction
    'Wow!'
  end
end
