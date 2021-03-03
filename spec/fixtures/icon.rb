# frozen_string_literal: true
module Icon
  include BaseInterface

  definition_methods do
    def resolve_type(_object, _context)
      ImageType
    end
  end
end
