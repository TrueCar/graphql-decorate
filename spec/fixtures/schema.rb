# frozen_string_literal: true

class Schema < GraphQL::Schema
  use GraphQL::Backtrace
  query ::Query

  orphan_types ImageType

  use GraphQL::Decorate

  def self.resolve_type(_type, _obj, _ctx)
    AuthenticatedUser
  end
end
