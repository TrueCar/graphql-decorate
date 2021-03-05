# frozen_string_literal: true

class ImageType < BaseObject
  implements Icon
  decorate_with do |image|
    image[:url] == 'placeholder' ? PlaceHolderImageDecorator : ImageDecorator
  end

  field :url, String, null: false
  field :alternate_text, String, null: false

  def url
    object[:url]
  end
end
