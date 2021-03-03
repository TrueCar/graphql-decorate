# frozen_string_literal: true

class BaseField < GraphQL::Schema::Field
  include GraphQL::Decorate::FieldIntegration
end
