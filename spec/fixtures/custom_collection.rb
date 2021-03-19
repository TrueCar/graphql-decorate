# frozen_string_literal: true

class CustomCollection
  def initialize(collection)
    @collection = collection
  end

  def map(&block)
    @collection.map(&block)
  end

  def first
    @collection.first
  end

  def each_with_index(&block)
    @collection.each_with_index(&block)
  end
end
