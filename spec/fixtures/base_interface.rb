# frozen_string_literal: true

module BaseInterface
  include GraphQL::Schema::Interface
  field_class BaseField
end
