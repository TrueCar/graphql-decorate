# frozen_string_literal: true
module Icon
  include BaseInterface

  definition_methods do
    def resolve_type(object, _context)
      object[:url] ? ImageType : FileType
    end
  end
end
