# frozen_string_literal: true

# Allows extraction of a type class from a particular field.
module ExtractType
  private

  def extract_type(field)
    if field.respond_to?(:of_type)
      extract_type(field.of_type)
    else
      field
    end
  end
end
