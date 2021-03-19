# frozen_string_literal: true

class BaseObject < GraphQL::Schema::Object
  include GraphQL::Decorate::ObjectIntegration

  field_class BaseField
end
