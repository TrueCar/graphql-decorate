# frozen_string_literal: true

module Icon
  include BaseInterface

  definition_methods do
    def resolve_type(object, _context)
      if object[:url]
        ImageType
      elsif object[:file_path]
        FileType
      else
        MissingType
      end
    end
  end
end
