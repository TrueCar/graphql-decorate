# frozen_string_literal: true
class CustomCollection
  def initialize(collection)
    @collection = collection
  end

  def map(&block)
    @collection.map(&block)
  end
end
