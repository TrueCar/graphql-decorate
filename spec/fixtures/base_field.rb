class BaseField < GraphQL::Schema::Field
  include GraphQL::Decorate::FieldIntegration
end
