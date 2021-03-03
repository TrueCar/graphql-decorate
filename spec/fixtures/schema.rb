class Schema < GraphQL::Schema
  use GraphQL::Backtrace
  query ::Query

  orphan_types ImageType
end
