# frozen_string_literal: true

class User < GraphQL::Schema::Union
  possible_types AuthenticatedUser, UnauthenticatedUser
end
